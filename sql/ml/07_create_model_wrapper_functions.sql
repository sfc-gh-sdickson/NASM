-- ============================================================================
-- NASM Intelligence Agent - Model Registry Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that wrap Model Registry models
--          so they can be added as tools to the Intelligence Agent
-- 
-- IMPORTANT: These wrapper functions MUST match the models created in:
--            notebooks/nasm_ml_models.ipynb
--
-- COLUMN VERIFICATION: All column names verified against 02_create_tables.sql
--
-- Models registered by notebook:
--   1. EXAM_SUCCESS_PREDICTOR - Output: PREDICTED_PASS (0, 1)
--   2. ENROLLMENT_DEMAND_FORECASTER - Output: PREDICTED_ENROLLMENTS (float)
--   3. STUDENT_CHURN_PREDICTOR - Output: PREDICTED_CHURN (0, 1)
-- ============================================================================

USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- Procedure 1: Exam Success Prediction Wrapper
-- Matches: EXAM_SUCCESS_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS:
--   STUDENTS: years_in_fitness, education_level, student_type
--   ENROLLMENTS: study_progress_pct, total_study_hours, modules_completed
--   CERTIFICATION_TYPES: certification_category
--   EXAMS: passed, exam_id
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_EXAM_SUCCESS(
    CERTIFICATION_CODE_FILTER VARCHAR
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_exam_success'
COMMENT = 'Calls EXAM_SUCCESS_PREDICTOR model from Model Registry to predict likelihood of passing certification exam'
AS
$$
def predict_exam_success(session, certification_code_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("EXAM_SUCCESS_PREDICTOR").default
    
    # Build query with optional filter
    cert_filter = f"AND ct.certification_code = '{certification_code_filter}'" if certification_code_filter else ""
    
    # Query uses VERIFIED column names from 02_create_tables.sql
    query = f"""
    SELECT
        s.years_in_fitness::FLOAT AS years_experience,
        CASE WHEN s.education_level IN ('Bachelors Degree', 'Masters Degree', 'Doctorate') THEN 1 ELSE 0 END AS has_degree,
        e.study_progress_pct::FLOAT AS study_progress,
        e.total_study_hours::FLOAT AS study_hours,
        e.modules_completed::FLOAT AS modules_done,
        ct.certification_category AS cert_category,
        s.student_type AS student_type,
        1::FLOAT AS attempt_num,
        -- For evaluation
        0 AS passed_exam
    FROM RAW.ENROLLMENTS e
    JOIN RAW.STUDENTS s ON e.student_id = s.student_id
    JOIN RAW.CERTIFICATION_TYPES ct ON e.certification_type_id = ct.certification_type_id
    WHERE e.enrollment_status = 'ACTIVE'
      AND e.is_exam_eligible = TRUE
      {cert_filter}
    LIMIT 25
    """
    
    input_df = session.sql(query)
    
    if input_df.count() == 0:
        return json.dumps({
            "error": "No eligible students found for prediction",
            "certification_filter": certification_code_filter
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Analyze predictions
    result = predictions.select("PREDICTED_PASS").to_pandas()
    
    # Count by predicted outcome
    predicted_pass = int((result['PREDICTED_PASS'] == 1).sum())
    predicted_fail = int((result['PREDICTED_PASS'] == 0).sum())
    total_count = len(result)
    pass_rate = round(predicted_pass / total_count * 100, 2) if total_count > 0 else 0
    
    return json.dumps({
        "certification_filter": certification_code_filter or "ALL",
        "total_students_analyzed": total_count,
        "predicted_to_pass": predicted_pass,
        "predicted_to_fail": predicted_fail,
        "predicted_pass_rate_pct": pass_rate
    })
$$;

-- ============================================================================
-- Procedure 2: Enrollment Demand Forecast Wrapper
-- Matches: ENROLLMENT_DEMAND_FORECASTER model from notebook
-- 
-- VERIFIED COLUMNS:
--   ENROLLMENTS: enrollment_id, student_id, enrollment_date, net_price, enrollment_status
-- ============================================================================

CREATE OR REPLACE PROCEDURE FORECAST_ENROLLMENT_DEMAND(
    MONTHS_AHEAD INT
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'forecast_enrollment'
COMMENT = 'Calls ENROLLMENT_DEMAND_FORECASTER model from Model Registry to predict future enrollment demand'
AS
$$
def forecast_enrollment(session, months_ahead):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("ENROLLMENT_DEMAND_FORECASTER").default
    
    # Query structured to match notebook training data exactly
    # COALESCE ensures we never pass NULL to the model
    query = f"""
    WITH monthly_stats AS (
        SELECT
            MONTH(e.enrollment_date) AS month_num,
            YEAR(e.enrollment_date) AS year_num,
            COUNT(DISTINCT e.enrollment_id)::FLOAT AS total_enrollments,
            COUNT(DISTINCT e.student_id)::FLOAT AS unique_students,
            AVG(e.net_price)::FLOAT AS avg_enrollment_price,
            SUM(e.net_price)::FLOAT AS total_revenue,
            COUNT(DISTINCT e.enrollment_id)::FLOAT AS enrollment_count
        FROM RAW.ENROLLMENTS e
        WHERE e.enrollment_date >= DATEADD('month', -24, CURRENT_DATE())
          AND e.enrollment_status IN ('COMPLETED', 'ACTIVE')
        GROUP BY MONTH(e.enrollment_date), YEAR(e.enrollment_date)
    ),
    target_month_averages AS (
        SELECT
            AVG(unique_students) AS avg_students,
            AVG(avg_enrollment_price) AS avg_price,
            AVG(total_revenue) AS avg_rev,
            AVG(enrollment_count) AS avg_enrollments
        FROM monthly_stats
        WHERE month_num = MONTH(DATEADD('month', {months_ahead}, CURRENT_DATE()))
    )
    SELECT
        MONTH(DATEADD('month', {months_ahead}, CURRENT_DATE())) AS month_num,
        YEAR(DATEADD('month', {months_ahead}, CURRENT_DATE())) AS year_num,
        COALESCE(tma.avg_students, 1000.0)::FLOAT AS unique_students,
        COALESCE(tma.avg_price, 600.0)::FLOAT AS avg_enrollment_price,
        COALESCE(tma.avg_rev, 600000.0)::FLOAT AS total_revenue,
        COALESCE(tma.avg_enrollments, 1000.0)::FLOAT AS enrollment_count
    FROM target_month_averages tma
    """
    
    input_df = session.sql(query)
    
    # Verify we have data before calling model
    if input_df.count() == 0:
        return json.dumps({
            "error": "No data available for prediction",
            "months_ahead": months_ahead
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Get prediction result
    result = predictions.select("ENROLLMENT_COUNT", "PREDICTED_ENROLLMENTS").to_pandas()
    
    if len(result) > 0:
        predicted_enrollments = round(float(result['PREDICTED_ENROLLMENTS'].iloc[0]), 0)
        historical_avg = round(float(result['ENROLLMENT_COUNT'].iloc[0]), 0)
    else:
        predicted_enrollments = 0
        historical_avg = 0
    
    return json.dumps({
        "months_ahead": months_ahead,
        "target_month": f"{months_ahead} months from now",
        "predicted_enrollments": int(predicted_enrollments),
        "historical_avg_for_same_month": int(historical_avg)
    })
$$;

-- ============================================================================
-- Procedure 3: Student Churn Prediction Wrapper
-- Matches: STUDENT_CHURN_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS:
--   STUDENTS: last_activity_date, total_spend, total_courses_completed, lifetime_ceus_earned
--   CERTIFICATIONS: certification_status, ceus_earned, ceus_required, expiry_date, renewal_count
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_STUDENT_CHURN(
    DAYS_TO_EXPIRY_THRESHOLD INT
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_churn'
COMMENT = 'Calls STUDENT_CHURN_PREDICTOR model from Model Registry to identify students at risk of not recertifying'
AS
$$
def predict_churn(session, days_to_expiry_threshold):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("STUDENT_CHURN_PREDICTOR").default
    
    # Query uses VERIFIED columns from STUDENTS and CERTIFICATIONS tables
    query = f"""
    SELECT
        DATEDIFF('day', s.last_activity_date, CURRENT_DATE())::FLOAT AS days_inactive,
        s.total_spend::FLOAT AS lifetime_spend,
        s.total_courses_completed::FLOAT AS courses_completed,
        s.lifetime_ceus_earned::FLOAT AS total_ceus,
        c.ceus_earned::FLOAT AS current_ceus,
        c.ceus_required::FLOAT AS required_ceus,
        COALESCE((c.ceus_earned::FLOAT / NULLIF(c.ceus_required, 0) * 100), 0)::FLOAT AS ceu_completion_pct,
        DATEDIFF('day', CURRENT_DATE(), c.expiry_date)::FLOAT AS days_to_expiry,
        c.renewal_count::FLOAT AS past_renewals,
        -- For evaluation reference
        0 AS churned
    FROM RAW.CERTIFICATIONS c
    JOIN RAW.STUDENTS s ON c.student_id = s.student_id
    WHERE c.certification_status = 'ACTIVE'
      AND DATEDIFF('day', CURRENT_DATE(), c.expiry_date) <= {days_to_expiry_threshold}
      AND DATEDIFF('day', CURRENT_DATE(), c.expiry_date) > 0
    LIMIT 50
    """
    
    input_df = session.sql(query)
    
    if input_df.count() == 0:
        return json.dumps({
            "error": "No certifications expiring within the specified threshold",
            "days_threshold": days_to_expiry_threshold
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Analyze predictions
    result = predictions.select("PREDICTED_CHURN", "DAYS_TO_EXPIRY", "CEU_COMPLETION_PCT").to_pandas()
    
    # Count by predicted outcome
    at_risk = int((result['PREDICTED_CHURN'] == 1).sum())
    likely_to_renew = int((result['PREDICTED_CHURN'] == 0).sum())
    total_count = len(result)
    churn_rate = round(at_risk / total_count * 100, 2) if total_count > 0 else 0
    avg_ceu_completion = round(result['CEU_COMPLETION_PCT'].mean(), 2)
    
    return json.dumps({
        "days_to_expiry_threshold": days_to_expiry_threshold,
        "certifications_analyzed": total_count,
        "at_risk_of_churning": at_risk,
        "likely_to_renew": likely_to_renew,
        "predicted_churn_rate_pct": churn_rate,
        "avg_ceu_completion_pct": avg_ceu_completion
    })
$$;

-- ============================================================================
-- Display confirmation
-- ============================================================================

SELECT 'ML model wrapper functions created successfully' AS status;

-- ============================================================================
-- Test the wrapper procedures (uncomment after models are registered via notebook)
-- ============================================================================
/*
CALL PREDICT_EXAM_SUCCESS('CPT');
CALL PREDICT_EXAM_SUCCESS(NULL);

CALL FORECAST_ENROLLMENT_DEMAND(1);
CALL FORECAST_ENROLLMENT_DEMAND(3);

CALL PREDICT_STUDENT_CHURN(90);
CALL PREDICT_STUDENT_CHURN(30);
*/

SELECT 'Execute notebook first to register models, then uncomment tests above' AS instruction;

