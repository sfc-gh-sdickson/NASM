-- ============================================================================
-- NASM Intelligence Agent - Create Snowflake Intelligence Agent
-- ============================================================================
-- Purpose: Create and configure Snowflake Intelligence Agent with:
--          - Cortex Analyst tools (Semantic Views)
--          - Cortex Search tools (Unstructured Data)
--          - ML Model tools (Predictions)
-- Execution: Run this after completing steps 01-07 and running the notebook
-- 
-- ML MODELS (from notebook):
--   1. EXAM_SUCCESS_PREDICTOR → PREDICT_EXAM_SUCCESS(VARCHAR)
--   2. ENROLLMENT_DEMAND_FORECASTER → FORECAST_ENROLLMENT_DEMAND(INT)
--   3. STUDENT_CHURN_PREDICTOR → PREDICT_STUDENT_CHURN(INT)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- Step 1: Grant Required Permissions for Cortex Analyst
-- ============================================================================

-- Grant Cortex Analyst user role to your role
-- Replace <your_role> with your actual role name (e.g., SYSADMIN, custom role)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE NASM_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA NASM_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA NASM_INTELLIGENCE.RAW TO ROLE SYSADMIN;

-- Grant privileges on semantic views for Cortex Analyst
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NASM_INTELLIGENCE.ANALYTICS.SV_STUDENT_CERTIFICATION_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NASM_INTELLIGENCE.ANALYTICS.SV_REVENUE_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW NASM_INTELLIGENCE.ANALYTICS.SV_LEARNING_EXPERIENCE_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE NASM_WH TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE NASM_INTELLIGENCE.RAW.STUDENT_REVIEWS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NASM_INTELLIGENCE.RAW.COURSE_CONTENT_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE NASM_INTELLIGENCE.RAW.FAQ_SEARCH TO ROLE SYSADMIN;

-- Grant execute on ML model wrapper procedures
-- These MUST match the procedure signatures in 07_create_model_wrapper_functions.sql
GRANT USAGE ON PROCEDURE NASM_INTELLIGENCE.ANALYTICS.PREDICT_EXAM_SUCCESS(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NASM_INTELLIGENCE.ANALYTICS.FORECAST_ENROLLMENT_DEMAND(INT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE NASM_INTELLIGENCE.ANALYTICS.PREDICT_STUDENT_CHURN(INT) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create Snowflake Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT NASM_INTELLIGENCE_AGENT
  COMMENT = 'NASM Intelligence Agent for certification and education business intelligence'
  PROFILE = '{"display_name": "NASM Intelligence Agent", "avatar": "education-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
models:
  orchestration: auto

orchestration:
  budget:
    seconds: 60
    tokens: 32000

instructions:
  response: 'You are a specialized analytics assistant for the National Academy of Sports Medicine (NASM), a leading fitness certification organization. For structured data queries use Cortex Analyst semantic views. For unstructured content use Cortex Search services. For predictions use ML model procedures. Keep responses concise and data-driven.'
  orchestration: 'For metrics and KPIs use Cortex Analyst tools. For student reviews, course content, and FAQs use Cortex Search tools. For forecasting and predictions use ML function tools.'
  system: 'You help analyze certification business data including student profiles, enrollments, exams, certifications, CEU completions, revenue, and student satisfaction using structured and unstructured data sources.'
  sample_questions:
    # ========== 5 SIMPLE QUESTIONS (Cortex Analyst) ==========
    - question: 'How many students are in the system?'
      answer: 'I will query the STUDENTS table to count total distinct students.'
    - question: 'What is the overall exam pass rate?'
      answer: 'I will calculate the percentage of passed exams from the EXAMS table.'
    - question: 'List all certification programs and their prices.'
      answer: 'I will query the CERTIFICATION_TYPES table to show programs and base prices.'
    - question: 'How many active certifications are there?'
      answer: 'I will filter certifications by status ACTIVE to get the count.'
    - question: 'What are the top 5 CEU courses by enrollment?'
      answer: 'I will query CEU_COURSES ordered by total_enrollments.'
    # ========== 5 COMPLEX QUESTIONS (Cortex Analyst) ==========
    - question: 'Analyze exam pass rates by certification type. Show total attempts, pass rate, and average score.'
      answer: 'I will join EXAMS with CERTIFICATION_TYPES to calculate metrics by certification.'
    - question: 'Compare revenue performance by product type and payment method.'
      answer: 'I will join ORDERS with ORDER_ITEMS and PRODUCTS to analyze revenue by category.'
    - question: 'Show student engagement trends - enrollment rates, completion rates, and CEU progress.'
      answer: 'I will analyze ENROLLMENTS and CEU_COMPLETIONS for engagement metrics.'
    - question: 'What is the recertification pipeline? Show certifications expiring in the next 90 days with CEU status.'
      answer: 'I will query CERTIFICATIONS filtering by expiry date and analyzing CEU completion.'
    - question: 'Analyze marketing campaign ROI by channel and campaign type.'
      answer: 'I will query MARKETING_CAMPAIGNS to calculate conversions, revenue, and ROI by channel.'
    # ========== 5 ML MODEL QUESTIONS (Predictions) ==========
    - question: 'Predict exam success rates for CPT certification students.'
      answer: 'I will call PREDICT_EXAM_SUCCESS with certification_code_filter=CPT.'
    - question: 'Forecast enrollment demand for the next 3 months.'
      answer: 'I will call FORECAST_ENROLLMENT_DEMAND with months_ahead=3.'
    - question: 'Identify students at risk of churning in the next 90 days.'
      answer: 'I will call PREDICT_STUDENT_CHURN with days_to_expiry_threshold=90.'
    - question: 'What is the predicted exam pass rate across all certifications?'
      answer: 'I will call PREDICT_EXAM_SUCCESS with no filter to analyze all certifications.'
    - question: 'Predict which students might not recertify in the next 30 days.'
      answer: 'I will call PREDICT_STUDENT_CHURN with days_to_expiry_threshold=30.'

tools:
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'StudentCertificationAnalyst'
      description: 'Analyzes student profiles, enrollments, exams, certifications, and student feedback'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'RevenueOperationsAnalyst'
      description: 'Analyzes orders, products, subscriptions, and marketing campaign performance'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'LearningExperienceAnalyst'
      description: 'Analyzes CEU courses, completions, support tickets, and learning feedback'
  - tool_spec:
      type: 'cortex_search'
      name: 'StudentReviewsSearch'
      description: 'Searches 10,000+ student reviews for feedback patterns, course opinions, and testimonials'
  - tool_spec:
      type: 'cortex_search'
      name: 'CourseContentSearch'
      description: 'Searches course materials including OPT model content, training techniques, and educational resources'
  - tool_spec:
      type: 'cortex_search'
      name: 'FAQSearch'
      description: 'Searches FAQ documents for recertification requirements, exam info, and policy guidance'
  - tool_spec:
      type: 'generic'
      name: 'PredictExamSuccess'
      description: 'Predicts likelihood of students passing certification exams based on study behavior'
      input_schema:
        type: 'object'
        properties:
          certification_code_filter:
            type: 'string'
            description: 'Certification code to filter (CPT, CES, PES, CNC, etc.) or null for all'
        required: []
  - tool_spec:
      type: 'generic'
      name: 'ForecastEnrollmentDemand'
      description: 'Forecasts enrollment demand for future months'
      input_schema:
        type: 'object'
        properties:
          months_ahead:
            type: 'integer'
            description: 'Number of months ahead to forecast (1-12)'
        required: ['months_ahead']
  - tool_spec:
      type: 'generic'
      name: 'PredictStudentChurn'
      description: 'Identifies students at risk of not recertifying based on engagement patterns'
      input_schema:
        type: 'object'
        properties:
          days_to_expiry_threshold:
            type: 'integer'
            description: 'Days until certification expiry to analyze (e.g., 30, 60, 90)'
        required: ['days_to_expiry_threshold']

tool_resources:
  StudentCertificationAnalyst:
    semantic_view: 'NASM_INTELLIGENCE.ANALYTICS.SV_STUDENT_CERTIFICATION_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NASM_WH'
      query_timeout: 60
  RevenueOperationsAnalyst:
    semantic_view: 'NASM_INTELLIGENCE.ANALYTICS.SV_REVENUE_OPERATIONS_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NASM_WH'
      query_timeout: 60
  LearningExperienceAnalyst:
    semantic_view: 'NASM_INTELLIGENCE.ANALYTICS.SV_LEARNING_EXPERIENCE_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NASM_WH'
      query_timeout: 60
  StudentReviewsSearch:
    search_service: 'NASM_INTELLIGENCE.RAW.STUDENT_REVIEWS_SEARCH'
    max_results: 10
    title_column: 'review_title'
    id_column: 'review_id'
  CourseContentSearch:
    search_service: 'NASM_INTELLIGENCE.RAW.COURSE_CONTENT_SEARCH'
    max_results: 5
    title_column: 'title'
    id_column: 'content_id'
  FAQSearch:
    search_service: 'NASM_INTELLIGENCE.RAW.FAQ_SEARCH'
    max_results: 5
    title_column: 'title'
    id_column: 'faq_id'
  PredictExamSuccess:
    type: 'procedure'
    identifier: 'NASM_INTELLIGENCE.ANALYTICS.PREDICT_EXAM_SUCCESS'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NASM_WH'
      query_timeout: 60
  ForecastEnrollmentDemand:
    type: 'procedure'
    identifier: 'NASM_INTELLIGENCE.ANALYTICS.FORECAST_ENROLLMENT_DEMAND'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NASM_WH'
      query_timeout: 60
  PredictStudentChurn:
    type: 'procedure'
    identifier: 'NASM_INTELLIGENCE.ANALYTICS.PREDICT_STUDENT_CHURN'
    execution_environment:
      type: 'warehouse'
      warehouse: 'NASM_WH'
      query_timeout: 60
  $$;

-- ============================================================================
-- Step 3: Verify Agent Creation
-- ============================================================================

-- Show created agent
SHOW AGENTS LIKE 'NASM_INTELLIGENCE_AGENT';

-- Describe agent configuration
DESCRIBE AGENT NASM_INTELLIGENCE_AGENT;

-- Grant usage
GRANT USAGE ON AGENT NASM_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

-- ============================================================================
-- Step 4: Test Agent (Examples)
-- ============================================================================

-- Note: After agent creation, you can test it in Snowsight:
-- 1. Go to AI & ML > Agents
-- 2. Select NASM_INTELLIGENCE_AGENT
-- 3. Click "Chat" to interact with the agent

-- Example test queries:
/*
1. Structured queries (Cortex Analyst):
   - "What is the exam pass rate by certification?"
   - "Show me total revenue by product type"
   - "How many students are at risk of not recertifying?"
   - "What is the average student satisfaction rating?"

2. Unstructured queries (Cortex Search):
   - "Search student reviews for comments about the CPT exam"
   - "Find FAQ information about recertification requirements"
   - "Search course content about the OPT model"

3. Predictive queries (ML Models):
   - "Predict exam success for CPT students"
   - "Forecast enrollment demand for the next 3 months"
   - "Identify students at risk of churning in 90 days"
*/

-- ============================================================================
-- Success Message
-- ============================================================================

SELECT 'NASM Intelligence Agent created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

/*
If agent creation fails, verify:

1. Permissions are granted:
   - CORTEX_ANALYST_USER database role
   - REFERENCES and SELECT on all semantic views
   - USAGE on Cortex Search services
   - USAGE on ML procedures

2. All semantic views exist:
   SHOW SEMANTIC VIEWS IN SCHEMA NASM_INTELLIGENCE.ANALYTICS;

3. All Cortex Search services exist and are ready:
   SHOW CORTEX SEARCH SERVICES IN SCHEMA NASM_INTELLIGENCE.RAW;

4. ML wrapper procedures exist:
   SHOW PROCEDURES IN SCHEMA NASM_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- PREDICT_EXAM_SUCCESS(VARCHAR)
   -- FORECAST_ENROLLMENT_DEMAND(NUMBER)
   -- PREDICT_STUDENT_CHURN(NUMBER)

5. Warehouse is running:
   SHOW WAREHOUSES LIKE 'NASM_WH';

6. Models are registered in Model Registry (run notebook first):
   SHOW MODELS IN SCHEMA NASM_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- EXAM_SUCCESS_PREDICTOR
   -- ENROLLMENT_DEMAND_FORECASTER
   -- STUDENT_CHURN_PREDICTOR
*/

