-- ============================================================================
-- NASM Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create analytical views for common business metrics and reporting
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- View 1: Student 360 - Complete student profile
-- ============================================================================
CREATE OR REPLACE VIEW V_STUDENT_360 AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    s.email,
    s.city,
    s.state,
    s.country,
    s.education_level,
    s.current_occupation,
    s.years_in_fitness,
    s.gym_affiliation,
    s.student_type,
    s.account_status,
    s.first_enrollment_date,
    s.last_activity_date,
    s.total_courses_completed,
    s.total_certifications,
    s.total_spend,
    s.lifetime_ceus_earned,
    -- Calculated fields
    DATEDIFF('day', s.first_enrollment_date, CURRENT_DATE()) AS days_as_student,
    DATEDIFF('day', s.last_activity_date, CURRENT_DATE()) AS days_since_last_activity,
    -- Active certifications count
    (SELECT COUNT(*) FROM RAW.CERTIFICATIONS c WHERE c.student_id = s.student_id AND c.certification_status = 'ACTIVE') AS active_certifications,
    -- Enrollment status summary
    (SELECT COUNT(*) FROM RAW.ENROLLMENTS e WHERE e.student_id = s.student_id AND e.enrollment_status = 'ACTIVE') AS active_enrollments,
    -- Recent exam performance
    (SELECT MAX(ex.scaled_score) FROM RAW.EXAMS ex WHERE ex.student_id = s.student_id) AS highest_exam_score,
    -- Support engagement
    (SELECT COUNT(*) FROM RAW.SUPPORT_TICKETS t WHERE t.student_id = s.student_id) AS total_support_tickets
FROM RAW.STUDENTS s;

-- ============================================================================
-- View 2: Certification Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_CERTIFICATION_ANALYTICS AS
SELECT
    ct.certification_type_id,
    ct.certification_code,
    ct.certification_name,
    ct.certification_category,
    ct.base_price,
    ct.is_ncca_accredited,
    -- Enrollment metrics
    COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
    COUNT(DISTINCT CASE WHEN e.enrollment_status = 'COMPLETED' THEN e.enrollment_id END) AS completed_enrollments,
    COUNT(DISTINCT CASE WHEN e.enrollment_status = 'ACTIVE' THEN e.enrollment_id END) AS active_enrollments,
    -- Exam metrics
    COUNT(DISTINCT ex.exam_id) AS total_exams,
    SUM(CASE WHEN ex.passed = TRUE THEN 1 ELSE 0 END) AS passed_exams,
    (SUM(CASE WHEN ex.passed = TRUE THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(DISTINCT ex.exam_id), 0) * 100)::NUMBER(5,2) AS pass_rate,
    AVG(ex.scaled_score)::NUMBER(5,2) AS avg_exam_score,
    -- Active certifications
    COUNT(DISTINCT c.certification_id) AS total_certified,
    COUNT(DISTINCT CASE WHEN c.certification_status = 'ACTIVE' THEN c.certification_id END) AS currently_certified,
    -- Revenue
    SUM(e.net_price)::NUMBER(12,2) AS total_revenue,
    AVG(e.net_price)::NUMBER(10,2) AS avg_enrollment_price
FROM RAW.CERTIFICATION_TYPES ct
LEFT JOIN RAW.ENROLLMENTS e ON ct.certification_type_id = e.certification_type_id
LEFT JOIN RAW.EXAMS ex ON ct.certification_type_id = ex.certification_type_id
LEFT JOIN RAW.CERTIFICATIONS c ON ct.certification_type_id = c.certification_type_id
GROUP BY ct.certification_type_id, ct.certification_code, ct.certification_name, ct.certification_category, ct.base_price, ct.is_ncca_accredited;

-- ============================================================================
-- View 3: Monthly Revenue Summary
-- ============================================================================
CREATE OR REPLACE VIEW V_MONTHLY_REVENUE AS
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS revenue_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.student_id) AS unique_customers,
    SUM(o.subtotal)::NUMBER(15,2) AS gross_revenue,
    SUM(o.discount_amount)::NUMBER(12,2) AS total_discounts,
    SUM(o.total_amount)::NUMBER(15,2) AS net_revenue,
    SUM(o.refund_amount)::NUMBER(12,2) AS total_refunds,
    AVG(o.total_amount)::NUMBER(10,2) AS avg_order_value,
    COUNT(DISTINCT CASE WHEN o.promo_code IS NOT NULL THEN o.order_id END) AS promo_orders,
    COUNT(DISTINCT CASE WHEN o.is_payment_plan = TRUE THEN o.order_id END) AS payment_plan_orders
FROM RAW.ORDERS o
WHERE o.order_status IN ('COMPLETED', 'REFUNDED')
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY revenue_month DESC;

-- ============================================================================
-- View 4: Exam Performance Summary
-- ============================================================================
CREATE OR REPLACE VIEW V_EXAM_PERFORMANCE AS
SELECT
    DATE_TRUNC('month', ex.exam_date)::DATE AS exam_month,
    ct.certification_code,
    ct.certification_name,
    COUNT(DISTINCT ex.exam_id) AS total_attempts,
    SUM(CASE WHEN ex.passed = TRUE THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN ex.passed = FALSE THEN 1 ELSE 0 END) AS failed,
    (SUM(CASE WHEN ex.passed = TRUE THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(DISTINCT ex.exam_id), 0) * 100)::NUMBER(5,2) AS pass_rate,
    AVG(ex.scaled_score)::NUMBER(5,2) AS avg_score,
    MIN(ex.scaled_score)::NUMBER(5,2) AS min_score,
    MAX(ex.scaled_score)::NUMBER(5,2) AS max_score,
    AVG(ex.time_taken_minutes)::NUMBER(5,0) AS avg_time_minutes,
    COUNT(DISTINCT CASE WHEN ex.attempt_number > 1 THEN ex.exam_id END) AS retake_attempts
FROM RAW.EXAMS ex
JOIN RAW.CERTIFICATION_TYPES ct ON ex.certification_type_id = ct.certification_type_id
WHERE ex.exam_status = 'COMPLETED'
GROUP BY DATE_TRUNC('month', ex.exam_date), ct.certification_code, ct.certification_name
ORDER BY exam_month DESC, ct.certification_code;

-- ============================================================================
-- View 5: CEU Completion Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_CEU_ANALYTICS AS
SELECT
    cc.ceu_course_id,
    cc.course_code,
    cc.course_name,
    cc.course_category,
    cc.ceu_credits,
    cc.price,
    cc.course_format,
    cc.difficulty_level,
    cc.avg_rating,
    -- Completion metrics
    COUNT(DISTINCT cmp.completion_id) AS total_enrollments,
    COUNT(DISTINCT CASE WHEN cmp.completion_status = 'COMPLETED' THEN cmp.completion_id END) AS completed,
    COUNT(DISTINCT CASE WHEN cmp.completion_status = 'IN_PROGRESS' THEN cmp.completion_id END) AS in_progress,
    (COUNT(DISTINCT CASE WHEN cmp.completion_status = 'COMPLETED' THEN cmp.completion_id END)::FLOAT / NULLIF(COUNT(DISTINCT cmp.completion_id), 0) * 100)::NUMBER(5,2) AS completion_rate,
    AVG(cmp.quiz_score)::NUMBER(5,2) AS avg_quiz_score,
    AVG(cmp.time_spent_minutes)::NUMBER(8,0) AS avg_time_minutes,
    SUM(cmp.ceus_earned)::NUMBER(10,2) AS total_ceus_earned
FROM RAW.CEU_COURSES cc
LEFT JOIN RAW.CEU_COMPLETIONS cmp ON cc.ceu_course_id = cmp.ceu_course_id
GROUP BY cc.ceu_course_id, cc.course_code, cc.course_name, cc.course_category, cc.ceu_credits, cc.price, cc.course_format, cc.difficulty_level, cc.avg_rating;

-- ============================================================================
-- View 6: Student Engagement Summary
-- ============================================================================
CREATE OR REPLACE VIEW V_STUDENT_ENGAGEMENT AS
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    s.account_status,
    s.first_enrollment_date,
    s.last_activity_date,
    DATEDIFF('day', s.last_activity_date, CURRENT_DATE()) AS days_inactive,
    s.total_spend,
    -- Engagement scoring
    CASE 
        WHEN DATEDIFF('day', s.last_activity_date, CURRENT_DATE()) <= 7 THEN 'HIGHLY_ACTIVE'
        WHEN DATEDIFF('day', s.last_activity_date, CURRENT_DATE()) <= 30 THEN 'ACTIVE'
        WHEN DATEDIFF('day', s.last_activity_date, CURRENT_DATE()) <= 90 THEN 'AT_RISK'
        ELSE 'CHURNED'
    END AS engagement_status,
    -- Certification status
    (SELECT COUNT(*) FROM RAW.CERTIFICATIONS c WHERE c.student_id = s.student_id AND c.certification_status = 'ACTIVE') AS active_certs,
    (SELECT COUNT(*) FROM RAW.CERTIFICATIONS c WHERE c.student_id = s.student_id AND c.certification_status = 'EXPIRING_SOON') AS expiring_certs,
    -- CEU progress
    (SELECT SUM(cmp.ceus_earned) FROM RAW.CEU_COMPLETIONS cmp WHERE cmp.student_id = s.student_id) AS total_ceus_earned,
    -- Feedback
    (SELECT AVG(sf.overall_rating) FROM RAW.STUDENT_FEEDBACK sf WHERE sf.student_id = s.student_id) AS avg_satisfaction
FROM RAW.STUDENTS s;

-- ============================================================================
-- View 7: Recertification Pipeline
-- ============================================================================
CREATE OR REPLACE VIEW V_RECERTIFICATION_PIPELINE AS
SELECT
    c.certification_id,
    c.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    s.email,
    ct.certification_code,
    ct.certification_name,
    c.issued_date,
    c.expiry_date,
    c.certification_status,
    c.ceus_earned,
    c.ceus_required,
    (c.ceus_required - c.ceus_earned) AS ceus_remaining,
    DATEDIFF('day', CURRENT_DATE(), c.expiry_date) AS days_until_expiry,
    CASE 
        WHEN c.expiry_date < CURRENT_DATE() THEN 'EXPIRED'
        WHEN DATEDIFF('day', CURRENT_DATE(), c.expiry_date) <= 30 THEN 'URGENT'
        WHEN DATEDIFF('day', CURRENT_DATE(), c.expiry_date) <= 90 THEN 'APPROACHING'
        ELSE 'ON_TRACK'
    END AS recert_urgency,
    CASE 
        WHEN c.ceus_earned >= c.ceus_required THEN 'COMPLETE'
        WHEN c.ceus_earned >= (c.ceus_required * 0.5) THEN 'IN_PROGRESS'
        ELSE 'NEEDS_ATTENTION'
    END AS ceu_status
FROM RAW.CERTIFICATIONS c
JOIN RAW.STUDENTS s ON c.student_id = s.student_id
JOIN RAW.CERTIFICATION_TYPES ct ON c.certification_type_id = ct.certification_type_id
WHERE c.certification_status IN ('ACTIVE', 'EXPIRING_SOON', 'EXPIRED');

-- ============================================================================
-- View 8: Support Ticket Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPORT_ANALYTICS AS
SELECT
    DATE_TRUNC('month', t.ticket_date)::DATE AS ticket_month,
    t.ticket_type,
    t.category,
    t.priority,
    COUNT(DISTINCT t.ticket_id) AS total_tickets,
    COUNT(DISTINCT CASE WHEN t.ticket_status = 'RESOLVED' THEN t.ticket_id END) AS resolved_tickets,
    COUNT(DISTINCT CASE WHEN t.ticket_status = 'OPEN' THEN t.ticket_id END) AS open_tickets,
    (COUNT(DISTINCT CASE WHEN t.ticket_status = 'RESOLVED' THEN t.ticket_id END)::FLOAT / NULLIF(COUNT(DISTINCT t.ticket_id), 0) * 100)::NUMBER(5,2) AS resolution_rate,
    AVG(DATEDIFF('hour', t.ticket_date, t.response_date))::NUMBER(8,1) AS avg_response_hours,
    AVG(DATEDIFF('hour', t.ticket_date, t.resolution_date))::NUMBER(8,1) AS avg_resolution_hours,
    AVG(t.satisfaction_rating)::NUMBER(3,2) AS avg_satisfaction
FROM RAW.SUPPORT_TICKETS t
GROUP BY DATE_TRUNC('month', t.ticket_date), t.ticket_type, t.category, t.priority
ORDER BY ticket_month DESC;

-- ============================================================================
-- View 9: Marketing Campaign Performance
-- ============================================================================
CREATE OR REPLACE VIEW V_CAMPAIGN_PERFORMANCE AS
SELECT
    mc.campaign_id,
    mc.campaign_name,
    mc.campaign_type,
    mc.campaign_channel,
    mc.target_audience,
    mc.start_date,
    mc.end_date,
    mc.budget,
    mc.campaign_status,
    mc.impressions,
    mc.clicks,
    (mc.clicks::FLOAT / NULLIF(mc.impressions, 0) * 100)::NUMBER(5,2) AS click_through_rate,
    mc.leads_generated,
    mc.conversions,
    (mc.conversions::FLOAT / NULLIF(mc.leads_generated, 0) * 100)::NUMBER(5,2) AS conversion_rate,
    mc.revenue_attributed,
    mc.cost_per_lead,
    mc.cost_per_acquisition,
    mc.roi_percentage,
    (mc.revenue_attributed / NULLIF(mc.budget, 0))::NUMBER(8,2) AS roas
FROM RAW.MARKETING_CAMPAIGNS mc;

-- ============================================================================
-- View 10: Product Performance
-- ============================================================================
CREATE OR REPLACE VIEW V_PRODUCT_PERFORMANCE AS
SELECT
    p.product_id,
    p.product_code,
    p.product_name,
    p.product_type,
    p.product_category,
    p.base_price,
    p.sale_price,
    ct.certification_code,
    ct.certification_name,
    COUNT(DISTINCT oi.order_item_id) AS total_sold,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price)::NUMBER(15,2) AS total_revenue,
    AVG(oi.total_price)::NUMBER(10,2) AS avg_sale_price,
    SUM(oi.discount_amount)::NUMBER(12,2) AS total_discounts
FROM RAW.PRODUCTS p
LEFT JOIN RAW.ORDER_ITEMS oi ON p.product_id = oi.product_id
LEFT JOIN RAW.CERTIFICATION_TYPES ct ON p.certification_type_id = ct.certification_type_id
GROUP BY p.product_id, p.product_code, p.product_name, p.product_type, p.product_category, p.base_price, p.sale_price, ct.certification_code, ct.certification_name;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;

