-- ============================================================================
-- NASM Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- CRITICAL SYNTAX RULE:
-- Dimensions/Metrics: <table_alias>.<semantic_name> AS <sql_expression>
--   - semantic_name = the NAME you want for the dimension/metric
--   - sql_expression = the SQL to compute it (column name or expression)
-- 
-- Clause order is MANDATORY: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
-- All synonyms are GLOBALLY UNIQUE across all semantic views
-- ============================================================================

USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- Semantic View 1: Student & Certification Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_STUDENT_CERTIFICATION_INTELLIGENCE
  TABLES (
    students AS RAW.STUDENTS
      PRIMARY KEY (student_id)
      WITH SYNONYMS ('fitness students', 'trainees', 'learners')
      COMMENT = 'Student profiles and account information',
    enrollments AS RAW.ENROLLMENTS
      PRIMARY KEY (enrollment_id)
      WITH SYNONYMS ('course enrollments', 'program registrations', 'signups')
      COMMENT = 'Student course enrollment details',
    certification_types AS RAW.CERTIFICATION_TYPES
      PRIMARY KEY (certification_type_id)
      WITH SYNONYMS ('cert programs', 'credential types', 'certification programs')
      COMMENT = 'Certification program catalog',
    exams AS RAW.EXAMS
      PRIMARY KEY (exam_id)
      WITH SYNONYMS ('exam attempts', 'certification exams', 'tests')
      COMMENT = 'Exam attempt records and scores',
    certifications AS RAW.CERTIFICATIONS
      PRIMARY KEY (certification_id)
      WITH SYNONYMS ('credentials', 'active certs', 'earned certifications')
      COMMENT = 'Certifications held by students',
    feedback AS RAW.STUDENT_FEEDBACK
      PRIMARY KEY (feedback_id)
      WITH SYNONYMS ('course feedback', 'student reviews', 'satisfaction surveys')
      COMMENT = 'Student satisfaction feedback and ratings'
  )
  RELATIONSHIPS (
    enrollments(student_id) REFERENCES students(student_id),
    enrollments(certification_type_id) REFERENCES certification_types(certification_type_id),
    exams(student_id) REFERENCES students(student_id),
    exams(enrollment_id) REFERENCES enrollments(enrollment_id),
    exams(certification_type_id) REFERENCES certification_types(certification_type_id),
    certifications(student_id) REFERENCES students(student_id),
    certifications(certification_type_id) REFERENCES certification_types(certification_type_id),
    certifications(exam_id) REFERENCES exams(exam_id),
    feedback(student_id) REFERENCES students(student_id),
    feedback(enrollment_id) REFERENCES enrollments(enrollment_id),
    feedback(certification_type_id) REFERENCES certification_types(certification_type_id)
  )
  DIMENSIONS (
    -- Student dimensions (semantic_name AS sql_expression)
    students.student_id AS student_id
      WITH SYNONYMS ('learner id', 'trainee id')
      COMMENT = 'Unique student identifier',
    students.student_first_name AS first_name
      WITH SYNONYMS ('given name', 'student first name')
      COMMENT = 'Student first name',
    students.student_last_name AS last_name
      WITH SYNONYMS ('surname', 'family name', 'student last name')
      COMMENT = 'Student last name',
    students.student_city AS city
      WITH SYNONYMS ('home city', 'student location')
      COMMENT = 'Student home city',
    students.student_state AS state
      WITH SYNONYMS ('home state', 'student state')
      COMMENT = 'Student home state',
    students.student_country AS country
      WITH SYNONYMS ('home country', 'student country')
      COMMENT = 'Student home country',
    students.education_level AS education_level
      WITH SYNONYMS ('degree level', 'academic level')
      COMMENT = 'Student education level',
    students.current_occupation AS occupation
      WITH SYNONYMS ('job title', 'current job', 'profession')
      COMMENT = 'Student current occupation',
    students.gym_affiliation AS gym_affiliation
      WITH SYNONYMS ('gym employer', 'fitness facility')
      COMMENT = 'Gym or facility affiliation',
    students.student_type AS student_type
      WITH SYNONYMS ('learner type', 'account type')
      COMMENT = 'Student type: INDIVIDUAL, CORPORATE, MILITARY',
    students.account_status AS account_status
      WITH SYNONYMS ('profile status', 'student status')
      COMMENT = 'Account status: ACTIVE, INACTIVE, SUSPENDED',
    -- Enrollment dimensions
    enrollments.enrollment_status AS enrollment_status
      WITH SYNONYMS ('registration status', 'course status')
      COMMENT = 'Status: ACTIVE, COMPLETED, EXPIRED, CANCELLED',
    enrollments.enrollment_date AS enrollment_date
      WITH SYNONYMS ('registration date', 'signup date')
      COMMENT = 'Date of enrollment',
    enrollments.exam_eligible AS is_exam_eligible
      WITH SYNONYMS ('ready for exam', 'can take exam')
      COMMENT = 'Whether student is eligible to take exam',
    enrollments.payment_plan AS payment_plan
      WITH SYNONYMS ('financing option', 'installment plan')
      COMMENT = 'Payment plan if applicable',
    -- Certification type dimensions
    certification_types.cert_code AS certification_code
      WITH SYNONYMS ('program code', 'credential code')
      COMMENT = 'Certification code: CPT, CES, PES, etc.',
    certification_types.cert_name AS certification_name
      WITH SYNONYMS ('program name', 'credential name')
      COMMENT = 'Full certification name',
    certification_types.cert_category AS certification_category
      WITH SYNONYMS ('program category', 'credential type')
      COMMENT = 'Category: PRIMARY, SPECIALIZATION',
    certification_types.ncca_accredited AS is_ncca_accredited
      WITH SYNONYMS ('accredited', 'ncca certified')
      COMMENT = 'Whether certification is NCCA accredited',
    -- Exam dimensions
    exams.exam_type AS exam_type
      WITH SYNONYMS ('test type', 'exam format')
      COMMENT = 'Exam type: ONLINE, IN_PERSON',
    exams.exam_passed AS passed
      WITH SYNONYMS ('passed exam', 'exam success')
      COMMENT = 'Whether student passed the exam',
    exams.certified_status AS is_certified
      WITH SYNONYMS ('certification issued', 'credential awarded')
      COMMENT = 'Whether certification was issued',
    exams.exam_attempt AS attempt_number
      WITH SYNONYMS ('try number', 'attempt count')
      COMMENT = 'Which attempt this was',
    -- Certification dimensions
    certifications.credential_status AS certification_status
      WITH SYNONYMS ('cert status', 'certification state')
      COMMENT = 'Status: ACTIVE, EXPIRING_SOON, EXPIRED',
    certifications.cert_expiry_date AS expiry_date
      WITH SYNONYMS ('credential expiration', 'cert end date')
      COMMENT = 'When certification expires',
    -- Feedback dimensions
    feedback.feedback_type AS feedback_type
      WITH SYNONYMS ('survey type', 'review type')
      COMMENT = 'Type: POST_COURSE, POST_EXAM, NPS_SURVEY',
    feedback.would_recommend AS would_recommend
      WITH SYNONYMS ('recommends nasm', 'promoter status')
      COMMENT = 'Whether student would recommend NASM'
  )
  METRICS (
    -- Student metrics (semantic_name AS aggregation_expression)
    students.total_students AS COUNT(DISTINCT student_id)
      WITH SYNONYMS ('student count', 'learner count', 'trainee count')
      COMMENT = 'Total number of students',
    students.avg_years_in_fitness AS AVG(years_in_fitness)
      WITH SYNONYMS ('average fitness experience', 'mean years experience')
      COMMENT = 'Average years of fitness industry experience',
    students.total_student_spend AS SUM(total_spend)
      WITH SYNONYMS ('cumulative student spend', 'total revenue from students')
      COMMENT = 'Sum of all student spending',
    students.avg_student_spend AS AVG(total_spend)
      WITH SYNONYMS ('average spend per student', 'mean student value')
      COMMENT = 'Average spend per student',
    -- Enrollment metrics
    enrollments.total_enrollments AS COUNT(DISTINCT enrollment_id)
      WITH SYNONYMS ('enrollment count', 'registration count')
      COMMENT = 'Total number of enrollments',
    enrollments.avg_study_progress AS AVG(study_progress_pct)
      WITH SYNONYMS ('average progress', 'mean completion progress')
      COMMENT = 'Average study progress percentage',
    enrollments.avg_study_hours AS AVG(total_study_hours)
      WITH SYNONYMS ('average study time', 'mean hours studied')
      COMMENT = 'Average study hours per enrollment',
    enrollments.total_enrollment_revenue AS SUM(net_price)
      WITH SYNONYMS ('enrollment revenue', 'program sales')
      COMMENT = 'Total enrollment revenue',
    -- Exam metrics
    exams.total_exams AS COUNT(DISTINCT exam_id)
      WITH SYNONYMS ('exam count', 'test attempts')
      COMMENT = 'Total number of exam attempts',
    exams.passed_exams AS SUM(CASE WHEN passed = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('successful exams', 'passing exams')
      COMMENT = 'Number of passed exams',
    exams.avg_exam_score AS AVG(scaled_score)
      WITH SYNONYMS ('average score', 'mean exam score')
      COMMENT = 'Average exam score',
    exams.avg_exam_time AS AVG(time_taken_minutes)
      WITH SYNONYMS ('average test time', 'mean exam duration')
      COMMENT = 'Average exam duration in minutes',
    -- Certification metrics
    certifications.total_certifications AS COUNT(DISTINCT certification_id)
      WITH SYNONYMS ('credential count', 'certs issued')
      COMMENT = 'Total certifications issued',
    certifications.active_certifications AS SUM(CASE WHEN certification_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('current certs', 'valid credentials')
      COMMENT = 'Number of active certifications',
    certifications.avg_ceus_earned AS AVG(ceus_earned)
      WITH SYNONYMS ('average ceu credits', 'mean ceus')
      COMMENT = 'Average CEUs earned per certification',
    -- Feedback metrics
    feedback.total_feedback AS COUNT(DISTINCT feedback_id)
      WITH SYNONYMS ('feedback count', 'survey responses')
      COMMENT = 'Total feedback submissions',
    feedback.avg_overall_rating AS AVG(overall_rating)
      WITH SYNONYMS ('average satisfaction', 'mean rating')
      COMMENT = 'Average overall rating (1-5)',
    feedback.avg_nps AS AVG(likelihood_to_recommend)
      WITH SYNONYMS ('average nps score', 'net promoter score')
      COMMENT = 'Average likelihood to recommend (1-10)'
  )
  COMMENT = 'Student & Certification Intelligence - comprehensive view of students, enrollments, exams, and certifications';

-- ============================================================================
-- Semantic View 2: Revenue & Operations Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_REVENUE_OPERATIONS_INTELLIGENCE
  TABLES (
    students AS RAW.STUDENTS
      PRIMARY KEY (student_id)
      WITH SYNONYMS ('purchasing students', 'customers', 'buyers')
      COMMENT = 'Students making purchases',
    orders AS RAW.ORDERS
      PRIMARY KEY (order_id)
      WITH SYNONYMS ('purchases', 'transactions', 'sales')
      COMMENT = 'Order transactions',
    order_items AS RAW.ORDER_ITEMS
      PRIMARY KEY (order_item_id)
      WITH SYNONYMS ('line items', 'purchased items', 'cart items')
      COMMENT = 'Individual items in orders',
    products AS RAW.PRODUCTS
      PRIMARY KEY (product_id)
      WITH SYNONYMS ('offerings', 'sku items', 'merchandise')
      COMMENT = 'Product catalog',
    subscriptions AS RAW.SUBSCRIPTIONS
      PRIMARY KEY (subscription_id)
      WITH SYNONYMS ('memberships', 'recurring plans', 'subscription plans')
      COMMENT = 'Student subscriptions',
    campaigns AS RAW.MARKETING_CAMPAIGNS
      PRIMARY KEY (campaign_id)
      WITH SYNONYMS ('marketing campaigns', 'promotions', 'advertising')
      COMMENT = 'Marketing campaign data'
  )
  RELATIONSHIPS (
    orders(student_id) REFERENCES students(student_id),
    order_items(order_id) REFERENCES orders(order_id),
    order_items(product_id) REFERENCES products(product_id),
    subscriptions(student_id) REFERENCES students(student_id)
  )
  DIMENSIONS (
    -- Student dimensions for revenue context
    students.revenue_student_type AS student_type
      WITH SYNONYMS ('buyer type', 'customer segment')
      COMMENT = 'Student type for revenue analysis',
    students.revenue_student_state AS state
      WITH SYNONYMS ('customer state', 'buyer location')
      COMMENT = 'State for revenue analysis',
    -- Order dimensions
    orders.order_status AS order_status
      WITH SYNONYMS ('purchase status', 'transaction status')
      COMMENT = 'Status: COMPLETED, REFUNDED, CANCELLED',
    orders.order_date AS order_date
      WITH SYNONYMS ('purchase date', 'transaction date')
      COMMENT = 'Date of order',
    orders.payment_method AS payment_method
      WITH SYNONYMS ('payment type', 'how paid')
      COMMENT = 'Payment method used',
    orders.payment_status AS payment_status
      WITH SYNONYMS ('payment state', 'billing status')
      COMMENT = 'Payment status: PAID, PENDING, FAILED',
    orders.order_channel AS channel
      WITH SYNONYMS ('sales channel', 'purchase channel')
      COMMENT = 'Channel: WEBSITE, MOBILE_APP, PHONE, CHAT',
    orders.has_payment_plan AS is_payment_plan
      WITH SYNONYMS ('financed', 'installment purchase')
      COMMENT = 'Whether order uses payment plan',
    orders.promo_code AS promo_code
      WITH SYNONYMS ('discount code', 'coupon code')
      COMMENT = 'Promotional code applied',
    -- Product dimensions
    products.product_name AS product_name
      WITH SYNONYMS ('item name', 'offering name')
      COMMENT = 'Product name',
    products.product_type AS product_type
      WITH SYNONYMS ('item type', 'offering type')
      COMMENT = 'Type: CERTIFICATION_PROGRAM, SPECIALIZATION, BUNDLE, CEU_BUNDLE',
    products.product_category AS product_category
      WITH SYNONYMS ('item category', 'product group')
      COMMENT = 'Product category',
    products.subscription_product AS is_subscription
      WITH SYNONYMS ('recurring product', 'subscription item')
      COMMENT = 'Whether product is subscription-based',
    -- Subscription dimensions
    subscriptions.subscription_type AS subscription_type
      WITH SYNONYMS ('membership type', 'plan type')
      COMMENT = 'Subscription type: EDGE_MONTHLY, EDGE_ANNUAL, etc.',
    subscriptions.subscription_status AS subscription_status
      WITH SYNONYMS ('membership status', 'plan status')
      COMMENT = 'Status: ACTIVE, CANCELLED, PAUSED, EXPIRED',
    subscriptions.billing_frequency AS billing_frequency
      WITH SYNONYMS ('billing cycle', 'payment frequency')
      COMMENT = 'Billing frequency: MONTHLY, ANNUAL',
    subscriptions.auto_renew_enabled AS auto_renew
      WITH SYNONYMS ('automatic renewal', 'auto renew')
      COMMENT = 'Whether subscription auto-renews',
    -- Campaign dimensions
    campaigns.campaign_name AS campaign_name
      WITH SYNONYMS ('promo name', 'marketing name')
      COMMENT = 'Marketing campaign name',
    campaigns.campaign_type AS campaign_type
      WITH SYNONYMS ('promo type', 'marketing type')
      COMMENT = 'Campaign type: SEASONAL, FLASH_SALE, PARTNER, etc.',
    campaigns.campaign_channel AS campaign_channel
      WITH SYNONYMS ('marketing channel', 'ad channel')
      COMMENT = 'Channel: EMAIL, SOCIAL, PAID_SEARCH, etc.',
    campaigns.campaign_status AS campaign_status
      WITH SYNONYMS ('promo status', 'marketing status')
      COMMENT = 'Campaign status: ACTIVE, COMPLETED'
  )
  METRICS (
    -- Order metrics
    orders.total_orders AS COUNT(DISTINCT order_id)
      WITH SYNONYMS ('order count', 'transaction count', 'purchase count')
      COMMENT = 'Total number of orders',
    orders.gross_revenue AS SUM(subtotal)
      WITH SYNONYMS ('total gross sales', 'revenue before discounts')
      COMMENT = 'Total gross revenue before discounts',
    orders.total_discounts AS SUM(discount_amount)
      WITH SYNONYMS ('discount total', 'promo savings')
      COMMENT = 'Total discount amount',
    orders.net_revenue AS SUM(total_amount)
      WITH SYNONYMS ('total net sales', 'net income')
      COMMENT = 'Net revenue after discounts',
    orders.avg_order_value AS AVG(total_amount)
      WITH SYNONYMS ('aov', 'average purchase', 'mean order value')
      COMMENT = 'Average order value',
    orders.total_refunds AS SUM(refund_amount)
      WITH SYNONYMS ('refund total', 'returned amount')
      COMMENT = 'Total refunded amount',
    -- Order items metrics
    order_items.total_items_sold AS SUM(quantity)
      WITH SYNONYMS ('units sold', 'items purchased')
      COMMENT = 'Total items sold',
    order_items.item_revenue AS SUM(total_price)
      WITH SYNONYMS ('line item revenue', 'product sales')
      COMMENT = 'Revenue from order items',
    -- Subscription metrics
    subscriptions.total_subscriptions AS COUNT(DISTINCT subscription_id)
      WITH SYNONYMS ('subscription count', 'membership count')
      COMMENT = 'Total subscriptions',
    subscriptions.active_subscriptions AS SUM(CASE WHEN subscription_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('current members', 'active memberships')
      COMMENT = 'Active subscription count',
    subscriptions.total_subscription_revenue AS SUM(total_billed)
      WITH SYNONYMS ('membership revenue', 'recurring revenue')
      COMMENT = 'Total subscription revenue',
    subscriptions.avg_monthly_rate AS AVG(monthly_rate)
      WITH SYNONYMS ('average membership fee', 'mean monthly cost')
      COMMENT = 'Average monthly subscription rate',
    -- Campaign metrics
    campaigns.total_campaigns AS COUNT(DISTINCT campaign_id)
      WITH SYNONYMS ('campaign count', 'promo count')
      COMMENT = 'Total marketing campaigns',
    campaigns.total_impressions AS SUM(impressions)
      WITH SYNONYMS ('ad views', 'reach')
      COMMENT = 'Total campaign impressions',
    campaigns.total_clicks AS SUM(clicks)
      WITH SYNONYMS ('click count', 'engagements')
      COMMENT = 'Total campaign clicks',
    campaigns.total_conversions AS SUM(conversions)
      WITH SYNONYMS ('conversion count', 'campaign sales')
      COMMENT = 'Total campaign conversions',
    campaigns.total_campaign_revenue AS SUM(revenue_attributed)
      WITH SYNONYMS ('attributed revenue', 'marketing revenue')
      COMMENT = 'Revenue attributed to campaigns',
    campaigns.avg_roi AS AVG(roi_percentage)
      WITH SYNONYMS ('average return on investment', 'mean roi')
      COMMENT = 'Average campaign ROI'
  )
  COMMENT = 'Revenue & Operations Intelligence - comprehensive view of orders, products, subscriptions, and marketing';

-- ============================================================================
-- Semantic View 3: Learning Experience Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_LEARNING_EXPERIENCE_INTELLIGENCE
  TABLES (
    students AS RAW.STUDENTS
      PRIMARY KEY (student_id)
      WITH SYNONYMS ('learning students', 'course takers', 'participants')
      COMMENT = 'Students for learning analysis',
    ceu_courses AS RAW.CEU_COURSES
      PRIMARY KEY (ceu_course_id)
      WITH SYNONYMS ('continuing education', 'ceu programs', 'recert courses')
      COMMENT = 'CEU course catalog',
    ceu_completions AS RAW.CEU_COMPLETIONS
      PRIMARY KEY (completion_id)
      WITH SYNONYMS ('ceu progress', 'course completions', 'ceu records')
      COMMENT = 'CEU completion records',
    support AS RAW.SUPPORT_TICKETS
      PRIMARY KEY (ticket_id)
      WITH SYNONYMS ('support requests', 'help tickets', 'customer service')
      COMMENT = 'Support ticket records',
    instructors AS RAW.INSTRUCTORS
      PRIMARY KEY (instructor_id)
      WITH SYNONYMS ('teachers', 'course authors', 'educators')
      COMMENT = 'Course instructors',
    feedback AS RAW.STUDENT_FEEDBACK
      PRIMARY KEY (feedback_id)
      WITH SYNONYMS ('learning feedback', 'course reviews', 'student ratings')
      COMMENT = 'Student feedback on learning experience'
  )
  RELATIONSHIPS (
    ceu_completions(student_id) REFERENCES students(student_id),
    ceu_completions(ceu_course_id) REFERENCES ceu_courses(ceu_course_id),
    support(student_id) REFERENCES students(student_id),
    feedback(student_id) REFERENCES students(student_id),
    feedback(ceu_course_id) REFERENCES ceu_courses(ceu_course_id)
  )
  DIMENSIONS (
    -- Student learning dimensions
    students.learning_student_type AS student_type
      WITH SYNONYMS ('learner category', 'participant type')
      COMMENT = 'Student type for learning analysis',
    students.learning_account_status AS account_status
      WITH SYNONYMS ('learner status', 'participation status')
      COMMENT = 'Account status for learning context',
    -- CEU course dimensions
    ceu_courses.course_name AS ceu_course_name
      WITH SYNONYMS ('ceu title', 'continuing ed course')
      COMMENT = 'CEU course name',
    ceu_courses.course_category AS ceu_category
      WITH SYNONYMS ('ceu type', 'continuing ed category')
      COMMENT = 'CEU category: CORRECTIVE_EXERCISE, NUTRITION, etc.',
    ceu_courses.course_format AS ceu_format
      WITH SYNONYMS ('delivery method', 'course delivery')
      COMMENT = 'Format: ONLINE, WEBINAR, IN_PERSON',
    ceu_courses.difficulty_level AS difficulty
      WITH SYNONYMS ('course level', 'complexity')
      COMMENT = 'Difficulty: BEGINNER, INTERMEDIATE, ADVANCED',
    ceu_courses.ceu_credits AS credits_available
      WITH SYNONYMS ('credit value', 'ceu points')
      COMMENT = 'Number of CEU credits offered',
    -- CEU completion dimensions
    ceu_completions.completion_status AS ceu_completion_status
      WITH SYNONYMS ('course progress status', 'ceu status')
      COMMENT = 'Status: COMPLETED, IN_PROGRESS, NOT_STARTED',
    ceu_completions.quiz_passed AS quiz_passed
      WITH SYNONYMS ('passed quiz', 'quiz success')
      COMMENT = 'Whether course quiz was passed',
    ceu_completions.certificate_issued AS ceu_certificate_issued
      WITH SYNONYMS ('completion cert issued', 'ceu cert given')
      COMMENT = 'Whether completion certificate was issued',
    -- Support dimensions
    support.ticket_type AS ticket_type
      WITH SYNONYMS ('issue type', 'support category')
      COMMENT = 'Ticket type: TECHNICAL, BILLING, CERTIFICATION, etc.',
    support.category AS support_category
      WITH SYNONYMS ('issue category', 'help category')
      COMMENT = 'Support ticket category',
    support.priority AS ticket_priority
      WITH SYNONYMS ('urgency level', 'issue priority')
      COMMENT = 'Priority: LOW, MEDIUM, HIGH, URGENT',
    support.ticket_status AS ticket_status
      WITH SYNONYMS ('case status', 'support status')
      COMMENT = 'Status: OPEN, PENDING, RESOLVED',
    support.channel AS support_channel
      WITH SYNONYMS ('contact method', 'how contacted')
      COMMENT = 'Channel: EMAIL, PHONE, CHAT, SOCIAL',
    -- Instructor dimensions
    instructors.instructor_type AS instructor_type
      WITH SYNONYMS ('educator type', 'teacher category')
      COMMENT = 'Type: COURSE_AUTHOR, LIVE_INSTRUCTOR, MASTER_TRAINER',
    instructors.specialty_areas AS instructor_specialty
      WITH SYNONYMS ('teaching specialty', 'expertise area')
      COMMENT = 'Instructor specialty areas',
    -- Feedback dimensions
    feedback.learning_feedback_type AS feedback_type
      WITH SYNONYMS ('evaluation type', 'assessment type')
      COMMENT = 'Feedback type for learning context'
  )
  METRICS (
    -- CEU course metrics
    ceu_courses.total_ceu_courses AS COUNT(DISTINCT ceu_course_id)
      WITH SYNONYMS ('ceu course count', 'continuing ed offerings')
      COMMENT = 'Total CEU courses available',
    ceu_courses.avg_course_rating AS AVG(avg_rating)
      WITH SYNONYMS ('average ceu rating', 'mean course rating')
      COMMENT = 'Average course rating',
    ceu_courses.total_ceu_enrollments AS SUM(total_enrollments)
      WITH SYNONYMS ('ceu signups', 'continuing ed registrations')
      COMMENT = 'Total CEU course enrollments',
    -- CEU completion metrics
    ceu_completions.total_ceu_completions AS COUNT(DISTINCT completion_id)
      WITH SYNONYMS ('completed ceus', 'finished courses')
      COMMENT = 'Total CEU course completions',
    ceu_completions.total_ceus_earned AS SUM(ceus_earned)
      WITH SYNONYMS ('credits earned', 'ceu points earned')
      COMMENT = 'Total CEU credits earned',
    ceu_completions.avg_quiz_score AS AVG(quiz_score)
      WITH SYNONYMS ('average ceu quiz', 'mean quiz performance')
      COMMENT = 'Average CEU quiz score',
    ceu_completions.avg_time_spent AS AVG(time_spent_minutes)
      WITH SYNONYMS ('average learning time', 'mean time in course')
      COMMENT = 'Average time spent on CEU courses',
    ceu_completions.ceu_completion_rate AS (SUM(CASE WHEN completion_status = 'COMPLETED' THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(DISTINCT completion_id), 0) * 100)
      WITH SYNONYMS ('course finish rate', 'ceu success rate')
      COMMENT = 'CEU course completion rate percentage',
    -- Support metrics
    support.total_tickets AS COUNT(DISTINCT ticket_id)
      WITH SYNONYMS ('ticket count', 'support cases')
      COMMENT = 'Total support tickets',
    support.resolved_tickets AS SUM(CASE WHEN ticket_status = 'RESOLVED' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('closed tickets', 'resolved cases')
      COMMENT = 'Number of resolved tickets',
    support.avg_satisfaction AS AVG(satisfaction_rating)
      WITH SYNONYMS ('support satisfaction', 'service rating')
      COMMENT = 'Average support satisfaction rating',
    support.open_tickets AS SUM(CASE WHEN ticket_status = 'OPEN' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('pending tickets', 'unresolved cases')
      COMMENT = 'Number of open tickets',
    -- Instructor metrics
    instructors.total_instructors AS COUNT(DISTINCT instructor_id)
      WITH SYNONYMS ('educator count', 'teacher count')
      COMMENT = 'Total number of instructors',
    instructors.avg_instructor_rating AS AVG(avg_course_rating)
      WITH SYNONYMS ('average teacher rating', 'mean instructor score')
      COMMENT = 'Average instructor rating',
    -- Feedback metrics
    feedback.learning_feedback_count AS COUNT(DISTINCT feedback_id)
      WITH SYNONYMS ('learning reviews', 'course evaluations')
      COMMENT = 'Total learning feedback records',
    feedback.avg_content_rating AS AVG(content_rating)
      WITH SYNONYMS ('content score', 'material rating')
      COMMENT = 'Average content rating',
    feedback.avg_instructor_rating AS AVG(instructor_rating)
      WITH SYNONYMS ('teacher score', 'educator rating')
      COMMENT = 'Average instructor rating from feedback',
    feedback.avg_platform_rating AS AVG(platform_rating)
      WITH SYNONYMS ('system rating', 'lms rating')
      COMMENT = 'Average platform rating',
    feedback.avg_value_rating AS AVG(value_rating)
      WITH SYNONYMS ('worth rating', 'value for money')
      COMMENT = 'Average value rating'
  )
  COMMENT = 'Learning Experience Intelligence - comprehensive view of CEU courses, completions, support, and learning feedback';

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All semantic views created successfully' AS status;

