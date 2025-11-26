-- ============================================================================
-- NASM Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for certification business model
-- All columns verified against NASM business requirements
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- CERTIFICATION_TYPES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CERTIFICATION_TYPES (
    certification_type_id VARCHAR(20) PRIMARY KEY,
    certification_code VARCHAR(10) NOT NULL,
    certification_name VARCHAR(200) NOT NULL,
    certification_category VARCHAR(50) NOT NULL,
    description VARCHAR(2000),
    prerequisites VARCHAR(1000),
    exam_required BOOLEAN DEFAULT TRUE,
    exam_duration_minutes NUMBER(4,0),
    passing_score NUMBER(5,2),
    total_questions NUMBER(4,0),
    ceu_required_for_recert NUMBER(4,0) DEFAULT 20,
    recert_period_years NUMBER(2,0) DEFAULT 2,
    base_price NUMBER(10,2) NOT NULL,
    is_ncca_accredited BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    launch_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- STUDENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE STUDENTS (
    student_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(30),
    date_of_birth DATE,
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    education_level VARCHAR(50),
    current_occupation VARCHAR(100),
    years_in_fitness NUMBER(3,0) DEFAULT 0,
    gym_affiliation VARCHAR(200),
    student_type VARCHAR(30) DEFAULT 'INDIVIDUAL',
    account_status VARCHAR(30) DEFAULT 'ACTIVE',
    marketing_opt_in BOOLEAN DEFAULT TRUE,
    referral_source VARCHAR(100),
    first_enrollment_date DATE,
    last_activity_date DATE,
    total_courses_completed NUMBER(5,0) DEFAULT 0,
    total_certifications NUMBER(3,0) DEFAULT 0,
    total_spend NUMBER(12,2) DEFAULT 0.00,
    lifetime_ceus_earned NUMBER(6,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- ENROLLMENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ENROLLMENTS (
    enrollment_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    certification_type_id VARCHAR(20) NOT NULL,
    order_id VARCHAR(30),
    enrollment_date DATE NOT NULL,
    enrollment_status VARCHAR(30) DEFAULT 'ACTIVE',
    access_start_date DATE NOT NULL,
    access_end_date DATE,
    study_progress_pct NUMBER(5,2) DEFAULT 0.00,
    modules_completed NUMBER(4,0) DEFAULT 0,
    total_modules NUMBER(4,0),
    total_study_hours NUMBER(6,2) DEFAULT 0.00,
    last_access_date TIMESTAMP_NTZ,
    exam_eligibility_date DATE,
    is_exam_eligible BOOLEAN DEFAULT FALSE,
    bundle_id VARCHAR(30),
    promo_code VARCHAR(30),
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    net_price NUMBER(10,2) NOT NULL,
    payment_plan VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id)
);

-- ============================================================================
-- EXAMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EXAMS (
    exam_id VARCHAR(30) PRIMARY KEY,
    enrollment_id VARCHAR(30) NOT NULL,
    student_id VARCHAR(30) NOT NULL,
    certification_type_id VARCHAR(20) NOT NULL,
    exam_date TIMESTAMP_NTZ NOT NULL,
    exam_type VARCHAR(30) DEFAULT 'ONLINE',
    exam_location VARCHAR(200),
    proctor_id VARCHAR(30),
    raw_score NUMBER(5,2),
    scaled_score NUMBER(5,2),
    passing_score NUMBER(5,2),
    passed BOOLEAN,
    attempt_number NUMBER(2,0) DEFAULT 1,
    time_taken_minutes NUMBER(4,0),
    sections_breakdown VARCHAR(2000),
    exam_status VARCHAR(30) DEFAULT 'COMPLETED',
    certification_issued_date DATE,
    certification_expiry_date DATE,
    is_certified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id)
);

-- ============================================================================
-- CERTIFICATIONS TABLE (Active Certifications Held by Students)
-- ============================================================================
CREATE OR REPLACE TABLE CERTIFICATIONS (
    certification_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    certification_type_id VARCHAR(20) NOT NULL,
    exam_id VARCHAR(30),
    certification_number VARCHAR(50) NOT NULL,
    issued_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    certification_status VARCHAR(30) DEFAULT 'ACTIVE',
    ceus_earned NUMBER(5,0) DEFAULT 0,
    ceus_required NUMBER(5,0) NOT NULL,
    recertification_date DATE,
    renewal_count NUMBER(3,0) DEFAULT 0,
    is_primary_credential BOOLEAN DEFAULT FALSE,
    specialty_areas VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id),
    FOREIGN KEY (exam_id) REFERENCES EXAMS(exam_id)
);

-- ============================================================================
-- CEU_COURSES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CEU_COURSES (
    ceu_course_id VARCHAR(30) PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(300) NOT NULL,
    course_category VARCHAR(50) NOT NULL,
    description VARCHAR(3000),
    ceu_credits NUMBER(4,2) NOT NULL,
    course_format VARCHAR(30) DEFAULT 'ONLINE',
    duration_hours NUMBER(5,2),
    difficulty_level VARCHAR(20),
    instructor_id VARCHAR(30),
    price NUMBER(10,2) NOT NULL,
    is_free_for_members BOOLEAN DEFAULT FALSE,
    applicable_certifications VARCHAR(500),
    prerequisites VARCHAR(500),
    learning_objectives VARCHAR(2000),
    course_status VARCHAR(30) DEFAULT 'ACTIVE',
    launch_date DATE,
    avg_rating NUMBER(3,2),
    total_enrollments NUMBER(8,0) DEFAULT 0,
    completion_rate NUMBER(5,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CEU_COMPLETIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CEU_COMPLETIONS (
    completion_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    ceu_course_id VARCHAR(30) NOT NULL,
    certification_id VARCHAR(30),
    enrollment_date DATE NOT NULL,
    start_date DATE,
    completion_date DATE,
    completion_status VARCHAR(30) DEFAULT 'IN_PROGRESS',
    progress_pct NUMBER(5,2) DEFAULT 0.00,
    quiz_score NUMBER(5,2),
    quiz_passed BOOLEAN,
    ceus_earned NUMBER(4,2) DEFAULT 0.00,
    time_spent_minutes NUMBER(6,0) DEFAULT 0,
    certificate_issued BOOLEAN DEFAULT FALSE,
    order_id VARCHAR(30),
    price_paid NUMBER(10,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (ceu_course_id) REFERENCES CEU_COURSES(ceu_course_id),
    FOREIGN KEY (certification_id) REFERENCES CERTIFICATIONS(certification_id)
);

-- ============================================================================
-- PRODUCTS TABLE (Bundles, Materials, etc.)
-- ============================================================================
CREATE OR REPLACE TABLE PRODUCTS (
    product_id VARCHAR(30) PRIMARY KEY,
    product_code VARCHAR(30) NOT NULL,
    product_name VARCHAR(300) NOT NULL,
    product_type VARCHAR(50) NOT NULL,
    product_category VARCHAR(50),
    description VARCHAR(2000),
    base_price NUMBER(10,2) NOT NULL,
    sale_price NUMBER(10,2),
    is_subscription BOOLEAN DEFAULT FALSE,
    subscription_period_months NUMBER(3,0),
    includes_exam BOOLEAN DEFAULT FALSE,
    includes_retest BOOLEAN DEFAULT FALSE,
    includes_materials BOOLEAN DEFAULT TRUE,
    certification_type_id VARCHAR(20),
    product_status VARCHAR(30) DEFAULT 'ACTIVE',
    launch_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id)
);

-- ============================================================================
-- ORDERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ORDERS (
    order_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    order_date TIMESTAMP_NTZ NOT NULL,
    order_number VARCHAR(30) NOT NULL,
    order_status VARCHAR(30) DEFAULT 'COMPLETED',
    subtotal NUMBER(12,2) NOT NULL,
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    tax_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(12,2) NOT NULL,
    promo_code VARCHAR(30),
    payment_method VARCHAR(50),
    payment_status VARCHAR(30) DEFAULT 'PAID',
    billing_address VARCHAR(500),
    is_payment_plan BOOLEAN DEFAULT FALSE,
    payment_plan_months NUMBER(3,0),
    monthly_payment NUMBER(10,2),
    channel VARCHAR(50) DEFAULT 'WEBSITE',
    campaign_id VARCHAR(30),
    affiliate_id VARCHAR(30),
    refund_amount NUMBER(10,2) DEFAULT 0.00,
    refund_date TIMESTAMP_NTZ,
    refund_reason VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id)
);

-- ============================================================================
-- ORDER_ITEMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ORDER_ITEMS (
    order_item_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    product_id VARCHAR(30) NOT NULL,
    quantity NUMBER(5,0) DEFAULT 1,
    unit_price NUMBER(10,2) NOT NULL,
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    total_price NUMBER(10,2) NOT NULL,
    is_bundle_component BOOLEAN DEFAULT FALSE,
    parent_bundle_id VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- ============================================================================
-- SUBSCRIPTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SUBSCRIPTIONS (
    subscription_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    subscription_type VARCHAR(50) NOT NULL,
    subscription_name VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    renewal_date DATE,
    subscription_status VARCHAR(30) DEFAULT 'ACTIVE',
    billing_frequency VARCHAR(20) DEFAULT 'MONTHLY',
    monthly_rate NUMBER(10,2) NOT NULL,
    annual_rate NUMBER(10,2),
    auto_renew BOOLEAN DEFAULT TRUE,
    cancellation_date DATE,
    cancellation_reason VARCHAR(500),
    pause_start_date DATE,
    pause_end_date DATE,
    total_billed NUMBER(12,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id)
);

-- ============================================================================
-- INSTRUCTORS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE INSTRUCTORS (
    instructor_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200),
    bio VARCHAR(3000),
    credentials VARCHAR(500),
    specialty_areas VARCHAR(500),
    photo_url VARCHAR(500),
    instructor_type VARCHAR(30) DEFAULT 'COURSE_AUTHOR',
    total_courses NUMBER(4,0) DEFAULT 0,
    avg_course_rating NUMBER(3,2),
    instructor_status VARCHAR(30) DEFAULT 'ACTIVE',
    hire_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SUPPORT_TICKETS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    ticket_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    ticket_number VARCHAR(20) NOT NULL,
    ticket_date TIMESTAMP_NTZ NOT NULL,
    ticket_type VARCHAR(50) NOT NULL,
    category VARCHAR(50),
    subject VARCHAR(300) NOT NULL,
    description VARCHAR(5000),
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    ticket_status VARCHAR(30) DEFAULT 'OPEN',
    assigned_to VARCHAR(100),
    response_date TIMESTAMP_NTZ,
    resolution_date TIMESTAMP_NTZ,
    resolution_notes VARCHAR(3000),
    satisfaction_rating NUMBER(2,0),
    channel VARCHAR(30) DEFAULT 'EMAIL',
    related_order_id VARCHAR(30),
    related_enrollment_id VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id)
);

-- ============================================================================
-- STUDENT_FEEDBACK TABLE
-- ============================================================================
CREATE OR REPLACE TABLE STUDENT_FEEDBACK (
    feedback_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    enrollment_id VARCHAR(30),
    certification_type_id VARCHAR(20),
    ceu_course_id VARCHAR(30),
    feedback_date TIMESTAMP_NTZ NOT NULL,
    feedback_type VARCHAR(50) NOT NULL,
    overall_rating NUMBER(2,0),
    content_rating NUMBER(2,0),
    instructor_rating NUMBER(2,0),
    platform_rating NUMBER(2,0),
    value_rating NUMBER(2,0),
    likelihood_to_recommend NUMBER(3,0),
    feedback_comments VARCHAR(5000),
    would_recommend BOOLEAN,
    improvement_suggestions VARCHAR(3000),
    testimonial_approved BOOLEAN DEFAULT FALSE,
    response_date TIMESTAMP_NTZ,
    response_text VARCHAR(2000),
    feedback_source VARCHAR(50),
    feedback_status VARCHAR(30) DEFAULT 'NEW',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id),
    FOREIGN KEY (ceu_course_id) REFERENCES CEU_COURSES(ceu_course_id)
);

-- ============================================================================
-- MARKETING_CAMPAIGNS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MARKETING_CAMPAIGNS (
    campaign_id VARCHAR(30) PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    campaign_type VARCHAR(50) NOT NULL,
    campaign_channel VARCHAR(50),
    target_audience VARCHAR(200),
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMBER(12,2),
    offer_type VARCHAR(50),
    discount_code VARCHAR(30),
    discount_percentage NUMBER(5,2),
    discount_amount NUMBER(10,2),
    campaign_status VARCHAR(30) DEFAULT 'ACTIVE',
    impressions NUMBER(12,0) DEFAULT 0,
    clicks NUMBER(10,0) DEFAULT 0,
    leads_generated NUMBER(8,0) DEFAULT 0,
    conversions NUMBER(8,0) DEFAULT 0,
    revenue_attributed NUMBER(15,2) DEFAULT 0.00,
    cost_per_lead NUMBER(10,2),
    cost_per_acquisition NUMBER(10,2),
    roi_percentage NUMBER(8,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- LEAD_INTERACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE LEAD_INTERACTIONS (
    interaction_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30),
    lead_email VARCHAR(200),
    campaign_id VARCHAR(30),
    interaction_date TIMESTAMP_NTZ NOT NULL,
    interaction_type VARCHAR(50) NOT NULL,
    interaction_channel VARCHAR(50),
    page_visited VARCHAR(500),
    content_viewed VARCHAR(300),
    time_on_page_seconds NUMBER(8,0),
    certification_interest VARCHAR(100),
    lead_score NUMBER(5,0) DEFAULT 0,
    lead_status VARCHAR(30) DEFAULT 'NEW',
    converted BOOLEAN DEFAULT FALSE,
    conversion_date DATE,
    conversion_order_id VARCHAR(30),
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    device_type VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (campaign_id) REFERENCES MARKETING_CAMPAIGNS(campaign_id)
);

-- ============================================================================
-- STUDY_SESSIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE STUDY_SESSIONS (
    session_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    enrollment_id VARCHAR(30) NOT NULL,
    session_start TIMESTAMP_NTZ NOT NULL,
    session_end TIMESTAMP_NTZ,
    duration_minutes NUMBER(6,0),
    module_id VARCHAR(30),
    module_name VARCHAR(200),
    content_type VARCHAR(50),
    pages_viewed NUMBER(5,0) DEFAULT 0,
    videos_watched NUMBER(5,0) DEFAULT 0,
    quizzes_taken NUMBER(5,0) DEFAULT 0,
    quiz_avg_score NUMBER(5,2),
    device_type VARCHAR(30),
    browser VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id)
);

-- ============================================================================
-- PRACTICE_EXAMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PRACTICE_EXAMS (
    practice_exam_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    enrollment_id VARCHAR(30) NOT NULL,
    certification_type_id VARCHAR(20) NOT NULL,
    exam_date TIMESTAMP_NTZ NOT NULL,
    exam_name VARCHAR(200),
    total_questions NUMBER(4,0),
    correct_answers NUMBER(4,0),
    score_percentage NUMBER(5,2),
    time_taken_minutes NUMBER(4,0),
    domains_performance VARCHAR(2000),
    attempt_number NUMBER(3,0) DEFAULT 1,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id)
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;

