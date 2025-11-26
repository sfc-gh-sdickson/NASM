-- ============================================================================
-- NASM Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for certification business operations
-- Volume: ~50K students, 100K enrollments, 75K exams, 150K CEU completions
-- Syntax: Verified against Snowflake SQL Reference
--
-- CRITICAL RULES FROM LESSONS LEARNED:
-- 1. UNIFORM(min, max, RANDOM()) - min and max MUST be constant literals
-- 2. SEQ4() - ONLY valid with TABLE(GENERATOR(...))
-- 3. Use ROW_NUMBER() OVER (ORDER BY ...) for non-generator contexts
-- 4. GENERATOR(ROWCOUNT => n) - n must be constant integer literal
-- ============================================================================

USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- Step 1: Generate Certification Types
-- ============================================================================
INSERT INTO CERTIFICATION_TYPES VALUES
('CERT001', 'CPT', 'Certified Personal Trainer', 'PRIMARY', 'NASM''s flagship certification for personal trainers. Learn the Optimum Performance Training (OPT) model to help clients achieve their fitness goals.', 'High school diploma or equivalent, CPR/AED certified', TRUE, 120, 70.00, 120, 20, 2, 699.00, TRUE, TRUE, '2010-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT002', 'CES', 'Corrective Exercise Specialist', 'SPECIALIZATION', 'Learn to identify and correct movement compensations and postural imbalances.', 'CPT or equivalent certification', TRUE, 100, 70.00, 100, 20, 2, 599.00, FALSE, TRUE, '2012-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT003', 'PES', 'Performance Enhancement Specialist', 'SPECIALIZATION', 'Master sports performance training to help athletes reach peak performance.', 'CPT or equivalent certification', TRUE, 100, 70.00, 100, 20, 2, 599.00, FALSE, TRUE, '2012-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT004', 'FNS', 'Fitness Nutrition Specialist', 'SPECIALIZATION', 'Develop expertise in nutrition to complement fitness training programs.', 'None', TRUE, 90, 70.00, 80, 20, 2, 499.00, FALSE, TRUE, '2015-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT005', 'CNC', 'Certified Nutrition Coach', 'PRIMARY', 'Comprehensive nutrition coaching certification with behavior change strategies.', 'High school diploma or equivalent', TRUE, 120, 70.00, 120, 20, 2, 699.00, TRUE, TRUE, '2018-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT006', 'WLS', 'Weight Loss Specialist', 'SPECIALIZATION', 'Specialized certification for helping clients achieve sustainable weight loss.', 'CPT or equivalent certification', TRUE, 80, 70.00, 70, 20, 2, 399.00, FALSE, TRUE, '2016-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT007', 'GFS', 'Group Fitness Specialist', 'SPECIALIZATION', 'Learn to design and lead effective group fitness classes.', 'CPT or equivalent certification', TRUE, 90, 70.00, 80, 20, 2, 449.00, FALSE, TRUE, '2014-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT008', 'YES', 'Youth Exercise Specialist', 'SPECIALIZATION', 'Specialized training for working with youth and adolescent clients.', 'CPT or equivalent certification', TRUE, 80, 70.00, 70, 20, 2, 399.00, FALSE, TRUE, '2017-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT009', 'SFS', 'Senior Fitness Specialist', 'SPECIALIZATION', 'Training specialization for working with older adult populations.', 'CPT or equivalent certification', TRUE, 80, 70.00, 70, 20, 2, 399.00, FALSE, TRUE, '2016-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT010', 'BCS', 'Behavior Change Specialist', 'SPECIALIZATION', 'Master the psychology and science of behavior change for better client outcomes.', 'None', TRUE, 90, 70.00, 80, 20, 2, 449.00, FALSE, TRUE, '2019-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT011', 'VCS', 'Virtual Coaching Specialist', 'SPECIALIZATION', 'Learn to deliver effective online and virtual coaching programs.', 'CPT or equivalent certification', TRUE, 60, 70.00, 50, 20, 2, 349.00, FALSE, TRUE, '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT012', 'GES', 'Golf Exercise Specialist', 'SPECIALIZATION', 'Specialized training for golf-specific fitness programming.', 'CPT or equivalent certification', TRUE, 60, 70.00, 50, 20, 2, 349.00, FALSE, TRUE, '2015-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT013', 'WFS', 'Women''s Fitness Specialist', 'SPECIALIZATION', 'Specialized training for women''s health and fitness needs.', 'CPT or equivalent certification', TRUE, 80, 70.00, 70, 20, 2, 399.00, FALSE, TRUE, '2018-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT014', 'MMA', 'MMA Conditioning Specialist', 'SPECIALIZATION', 'Training specialization for mixed martial arts conditioning.', 'CPT or equivalent certification', TRUE, 80, 70.00, 70, 20, 2, 399.00, FALSE, TRUE, '2016-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CERT015', 'GPTS', 'Group Personal Training Specialist', 'SPECIALIZATION', 'Learn to effectively train small groups of clients.', 'CPT or equivalent certification', TRUE, 80, 70.00, 70, 20, 2, 399.00, FALSE, TRUE, '2017-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 2: Generate Students
-- USING ROW_NUMBER() instead of SEQ4() because SEQ4() only works with GENERATOR
-- ============================================================================
INSERT INTO STUDENTS
SELECT
    'STU' || LPAD(SEQ4(), 8, '0') AS student_id,
    ARRAY_CONSTRUCT('James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles',
                    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Barbara', 'Elizabeth', 'Susan', 'Jessica', 'Sarah', 'Karen',
                    'Christopher', 'Daniel', 'Matthew', 'Anthony', 'Mark', 'Donald', 'Steven', 'Paul', 'Andrew', 'Joshua',
                    'Ashley', 'Kimberly', 'Emily', 'Donna', 'Michelle', 'Dorothy', 'Amanda', 'Melissa', 'Stephanie', 'Nicole',
                    'Alexander', 'Benjamin', 'Nicholas', 'Tyler', 'Brandon', 'Jacob', 'Ethan', 'Noah', 'Mason', 'Lucas',
                    'Sophia', 'Isabella', 'Olivia', 'Ava', 'Mia', 'Emma', 'Charlotte', 'Amelia', 'Harper', 'Evelyn')[UNIFORM(0, 59, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                    'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore', 'Jackson', 'Martin', 'Lee', 'Thompson', 'White',
                    'Harris', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Lopez',
                    'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter', 'Mitchell', 'Perez',
                    'Chen', 'Wang', 'Kim', 'Patel', 'Singh', 'Cohen', 'Nakamura', 'Santos', 'Nguyen', 'OBrien')[UNIFORM(0, 49, RANDOM())] AS last_name,
    'student' || SEQ4() || '@' || ARRAY_CONSTRUCT('gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'icloud.com', 'aol.com')[UNIFORM(0, 5, RANDOM())] AS email,
    CONCAT('+1-', LPAD(UNIFORM(200, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(100, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS phone,
    DATEADD('year', -1 * UNIFORM(21, 55, RANDOM()), CURRENT_DATE()) AS date_of_birth,
    UNIFORM(100, 9999, RANDOM()) || ' ' || ARRAY_CONSTRUCT('Main St', 'Oak Ave', 'Park Blvd', 'Cedar Ln', 'Maple Dr', 'Elm St', 'Pine Rd', 'Lake Dr')[UNIFORM(0, 7, RANDOM())] AS address_line1,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'Apt ' || UNIFORM(1, 500, RANDOM()) ELSE NULL END AS address_line2,
    ARRAY_CONSTRUCT('Los Angeles', 'New York', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego',
                    'Dallas', 'San Jose', 'Austin', 'Seattle', 'Denver', 'Boston', 'Miami', 'San Francisco',
                    'Atlanta', 'Las Vegas', 'Portland', 'Detroit', 'Minneapolis', 'Tampa', 'Orlando', 'Charlotte',
                    'Nashville', 'Salt Lake City', 'Raleigh', 'Columbus', 'Indianapolis', 'Kansas City')[UNIFORM(0, 29, RANDOM())] AS city,
    ARRAY_CONSTRUCT('CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI', 'NJ', 'VA', 'WA', 'AZ', 'MA', 
                    'TN', 'IN', 'MO', 'MD', 'WI', 'CO', 'MN', 'SC', 'AL', 'LA', 'NV', 'OR', 'OK', 'CT', 'UT')[UNIFORM(0, 29, RANDOM())] AS state,
    LPAD(UNIFORM(10001, 99999, RANDOM()), 5, '0') AS postal_code,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'USA'
         WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN 'CANADA'
         ELSE ARRAY_CONSTRUCT('UK', 'AUSTRALIA', 'MEXICO', 'GERMANY')[UNIFORM(0, 3, RANDOM())] END AS country,
    ARRAY_CONSTRUCT('High School', 'Some College', 'Associates Degree', 'Bachelors Degree', 'Masters Degree', 'Doctorate')[UNIFORM(0, 5, RANDOM())] AS education_level,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Personal Trainer'
         WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'Fitness Instructor'
         WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'Gym Manager'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'Physical Therapist'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'Strength Coach'
         ELSE ARRAY_CONSTRUCT('Student', 'Career Changer', 'Wellness Coach', 'Yoga Instructor', 'Athlete', 'Nurse')[UNIFORM(0, 5, RANDOM())] END AS current_occupation,
    UNIFORM(0, 20, RANDOM()) AS years_in_fitness,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 
        ARRAY_CONSTRUCT('LA Fitness', 'Planet Fitness', 'Gold''s Gym', 'Equinox', 'YMCA', 'Anytime Fitness', '24 Hour Fitness', 'CrossFit Box', 'Boutique Studio', 'Independent')[UNIFORM(0, 9, RANDOM())]
    ELSE NULL END AS gym_affiliation,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'INDIVIDUAL'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'CORPORATE'
         ELSE 'MILITARY' END AS student_type,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'ACTIVE'
         WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN 'INACTIVE'
         ELSE 'SUSPENDED' END AS account_status,
    UNIFORM(0, 100, RANDOM()) < 75 AS marketing_opt_in,
    ARRAY_CONSTRUCT('Google Search', 'Social Media', 'Friend Referral', 'Gym Recommendation', 'Career Website', 'Email Marketing', 'Podcast', 'YouTube', 'Industry Event', 'Direct')[UNIFORM(0, 9, RANDOM())] AS referral_source,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_DATE()) AS first_enrollment_date,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS last_activity_date,
    UNIFORM(1, 15, RANDOM()) AS total_courses_completed,
    UNIFORM(0, 5, RANDOM()) AS total_certifications,
    (UNIFORM(500, 10000, RANDOM()) * 1.0)::NUMBER(12,2) AS total_spend,
    UNIFORM(0, 100, RANDOM()) AS lifetime_ceus_earned,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- ============================================================================
-- Step 3: Generate Products
-- ============================================================================
INSERT INTO PRODUCTS VALUES
('PROD001', 'CPT-SELF', 'CPT Self-Study', 'CERTIFICATION_PROGRAM', 'SELF_STUDY', 'Complete CPT certification with self-study materials', 699.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT001', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD002', 'CPT-GUIDED', 'CPT Guided Study', 'CERTIFICATION_PROGRAM', 'GUIDED_STUDY', 'CPT certification with guided study and coaching calls', 1099.00, NULL, FALSE, NULL, TRUE, FALSE, TRUE, 'CERT001', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD003', 'CPT-ALL', 'CPT All-Inclusive', 'CERTIFICATION_PROGRAM', 'ALL_INCLUSIVE', 'Complete CPT package with exam, retest, and job guarantee', 1599.00, NULL, FALSE, NULL, TRUE, TRUE, TRUE, 'CERT001', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD004', 'CES-SELF', 'CES Self-Study', 'SPECIALIZATION', 'SELF_STUDY', 'Corrective Exercise Specialist self-study program', 599.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT002', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD005', 'PES-SELF', 'PES Self-Study', 'SPECIALIZATION', 'SELF_STUDY', 'Performance Enhancement Specialist self-study program', 599.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT003', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD006', 'FNS-SELF', 'FNS Self-Study', 'SPECIALIZATION', 'SELF_STUDY', 'Fitness Nutrition Specialist self-study program', 499.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT004', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD007', 'CNC-SELF', 'CNC Self-Study', 'CERTIFICATION_PROGRAM', 'SELF_STUDY', 'Certified Nutrition Coach self-study program', 699.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT005', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD008', 'CNC-GUIDED', 'CNC Guided Study', 'CERTIFICATION_PROGRAM', 'GUIDED_STUDY', 'CNC certification with guided study support', 1099.00, NULL, FALSE, NULL, TRUE, FALSE, TRUE, 'CERT005', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD009', 'WLS-SELF', 'WLS Self-Study', 'SPECIALIZATION', 'SELF_STUDY', 'Weight Loss Specialist self-study program', 399.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT006', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD010', 'GFS-SELF', 'GFS Self-Study', 'SPECIALIZATION', 'SELF_STUDY', 'Group Fitness Specialist self-study program', 449.00, NULL, FALSE, NULL, FALSE, FALSE, TRUE, 'CERT007', 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD011', 'ELITE-BUNDLE', 'NASM Elite Trainer Bundle', 'BUNDLE', 'PREMIUM', 'CPT + CES + PES for the ultimate trainer package', 1999.00, 1799.00, FALSE, NULL, TRUE, TRUE, TRUE, NULL, 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD012', 'RECERT-20', '20 CEU Recertification Pack', 'CEU_BUNDLE', 'RECERTIFICATION', 'Bundle of CEU courses totaling 20 credits', 199.00, NULL, FALSE, NULL, FALSE, FALSE, FALSE, NULL, 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD013', 'EXAM-RETEST', 'Exam Retest', 'EXAM', 'RETEST', 'Additional exam attempt for certification', 199.00, NULL, FALSE, NULL, TRUE, FALSE, FALSE, NULL, 'ACTIVE', '2020-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD014', 'EDGE-MONTHLY', 'NASM Edge Monthly', 'SUBSCRIPTION', 'MONTHLY', 'Monthly access to NASM Edge platform with CEUs', 19.99, NULL, TRUE, 1, FALSE, FALSE, FALSE, NULL, 'ACTIVE', '2021-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD015', 'EDGE-ANNUAL', 'NASM Edge Annual', 'SUBSCRIPTION', 'ANNUAL', 'Annual access to NASM Edge platform with CEUs', 179.88, NULL, TRUE, 12, FALSE, FALSE, FALSE, NULL, 'ACTIVE', '2021-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 4: Generate Instructors
-- ============================================================================
INSERT INTO INSTRUCTORS
SELECT
    'INST' || LPAD(SEQ4(), 5, '0') AS instructor_id,
    ARRAY_CONSTRUCT('Dr. Michael', 'Sarah', 'Brian', 'Lisa', 'Kevin', 'Jennifer', 'Ryan', 'Amanda', 'Marcus', 'Rachel',
                    'Dr. James', 'Nicole', 'Chris', 'Megan', 'Derek', 'Samantha', 'Tony', 'Lauren', 'Brandon', 'Ashley')[UNIFORM(0, 19, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Thompson', 'Anderson', 'Martinez', 'Clark', 'Turner', 'Rodriguez', 'Foster', 'Phillips', 'Campbell', 'Mitchell',
                    'Roberts', 'Jackson', 'White', 'Harris', 'Lewis', 'Young', 'King', 'Scott', 'Green', 'Adams')[UNIFORM(0, 19, RANDOM())] AS last_name,
    'instructor' || SEQ4() || '@nasm.org' AS email,
    CASE (ABS(RANDOM()) % 5)
        WHEN 0 THEN 'NASM Master Instructor with 15+ years of experience in fitness training and education. Specializes in corrective exercise and performance enhancement.'
        WHEN 1 THEN 'Former professional athlete turned fitness educator. Brings real-world experience to evidence-based training methodologies.'
        WHEN 2 THEN 'PhD in Exercise Science with extensive research background. Expert in biomechanics and human movement.'
        WHEN 3 THEN 'Certified Personal Trainer with over a decade of hands-on coaching experience. Passionate about helping trainers succeed.'
        ELSE 'Experienced fitness professional and course developer. Specializes in creating engaging educational content.'
    END AS bio,
    'NASM-CPT, NASM-CES, NASM-PES, ' || ARRAY_CONSTRUCT('CSCS', 'PhD', 'MS', 'ACE-CPT', 'ACSM-EP')[UNIFORM(0, 4, RANDOM())] AS credentials,
    ARRAY_CONSTRUCT('Corrective Exercise', 'Performance Training', 'Nutrition Coaching', 'Behavior Change', 'Group Fitness', 'Youth Fitness', 'Senior Fitness', 'Weight Loss', 'Sports Performance')[UNIFORM(0, 8, RANDOM())] AS specialty_areas,
    NULL AS photo_url,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'COURSE_AUTHOR' 
         WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'LIVE_INSTRUCTOR'
         ELSE 'MASTER_TRAINER' END AS instructor_type,
    UNIFORM(3, 30, RANDOM()) AS total_courses,
    (UNIFORM(35, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS avg_course_rating,
    'ACTIVE' AS instructor_status,
    DATEADD('day', -1 * UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()) AS hire_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- ============================================================================
-- Step 5: Generate CEU Courses
-- ============================================================================
INSERT INTO CEU_COURSES
SELECT
    'CEU' || LPAD(SEQ4(), 6, '0') AS ceu_course_id,
    'CEU-' || LPAD(SEQ4(), 4, '0') AS course_code,
    CASE (ABS(RANDOM()) % 30)
        WHEN 0 THEN 'Advanced Corrective Exercise Strategies'
        WHEN 1 THEN 'Nutrition for Fat Loss'
        WHEN 2 THEN 'High-Intensity Interval Training'
        WHEN 3 THEN 'Mobility and Flexibility Programming'
        WHEN 4 THEN 'Strength Training Fundamentals'
        WHEN 5 THEN 'Core Training Essentials'
        WHEN 6 THEN 'Client Communication Skills'
        WHEN 7 THEN 'Business Building for Trainers'
        WHEN 8 THEN 'Sports Performance Training'
        WHEN 9 THEN 'Senior Fitness Programming'
        WHEN 10 THEN 'Youth Athletic Development'
        WHEN 11 THEN 'Pre and Postnatal Fitness'
        WHEN 12 THEN 'Mindset and Motivation'
        WHEN 13 THEN 'Recovery and Regeneration'
        WHEN 14 THEN 'Functional Movement Patterns'
        WHEN 15 THEN 'Metabolic Conditioning'
        WHEN 16 THEN 'Postural Assessment Techniques'
        WHEN 17 THEN 'Program Design Mastery'
        WHEN 18 THEN 'Cardiovascular Training'
        WHEN 19 THEN 'Resistance Training Progressions'
        WHEN 20 THEN 'Foam Rolling and Self-Myofascial Release'
        WHEN 21 THEN 'Balance and Stability Training'
        WHEN 22 THEN 'Plyometric Training'
        WHEN 23 THEN 'Speed and Agility Development'
        WHEN 24 THEN 'Suspension Training'
        WHEN 25 THEN 'Kettlebell Training'
        WHEN 26 THEN 'Battle Ropes and Unconventional Training'
        WHEN 27 THEN 'Virtual Training Best Practices'
        WHEN 28 THEN 'Client Retention Strategies'
        ELSE 'Advanced Assessment Techniques'
    END AS course_name,
    ARRAY_CONSTRUCT('CORRECTIVE_EXERCISE', 'NUTRITION', 'PERFORMANCE', 'BUSINESS', 'SPECIAL_POPULATIONS', 'BEHAVIOR_CHANGE', 'ASSESSMENT', 'PROGRAMMING')[UNIFORM(0, 7, RANDOM())] AS course_category,
    'This CEU course provides in-depth knowledge and practical skills to enhance your training expertise.' AS description,
    ARRAY_CONSTRUCT(0.5, 1.0, 1.5, 2.0, 2.5, 3.0)[UNIFORM(0, 5, RANDOM())] AS ceu_credits,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'ONLINE'
         WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'WEBINAR'
         ELSE 'IN_PERSON' END AS course_format,
    (UNIFORM(30, 360, RANDOM()) / 60.0)::NUMBER(5,2) AS duration_hours,
    ARRAY_CONSTRUCT('BEGINNER', 'INTERMEDIATE', 'ADVANCED')[UNIFORM(0, 2, RANDOM())] AS difficulty_level,
    'INST' || LPAD(UNIFORM(0, 49, RANDOM()), 5, '0') AS instructor_id,
    (UNIFORM(19, 149, RANDOM()) * 1.0)::NUMBER(10,2) AS price,
    UNIFORM(0, 100, RANDOM()) < 20 AS is_free_for_members,
    'CPT, CES, PES, CNC' AS applicable_certifications,
    NULL AS prerequisites,
    'Upon completion, participants will be able to apply advanced techniques in their training practice.' AS learning_objectives,
    'ACTIVE' AS course_status,
    DATEADD('day', -1 * UNIFORM(30, 1095, RANDOM()), CURRENT_DATE()) AS launch_date,
    (UNIFORM(35, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS avg_rating,
    UNIFORM(100, 10000, RANDOM()) AS total_enrollments,
    (UNIFORM(60, 95, RANDOM()) * 1.0)::NUMBER(5,2) AS completion_rate,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- ============================================================================
-- Step 6: Generate Enrollments
-- ============================================================================
INSERT INTO ENROLLMENTS
SELECT
    'ENR' || LPAD(ROW_NUMBER() OVER (ORDER BY s.student_id, ct.certification_type_id), 10, '0') AS enrollment_id,
    s.student_id,
    ct.certification_type_id,
    NULL AS order_id,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS enrollment_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'COMPLETED'
         WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'ACTIVE'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'EXPIRED'
         ELSE 'CANCELLED' END AS enrollment_status,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS access_start_date,
    DATEADD('day', UNIFORM(180, 365, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE())) AS access_end_date,
    (UNIFORM(0, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS study_progress_pct,
    UNIFORM(0, 20, RANDOM()) AS modules_completed,
    20 AS total_modules,
    (UNIFORM(10, 150, RANDOM()) * 1.0)::NUMBER(6,2) AS total_study_hours,
    DATEADD('day', -1 * UNIFORM(1, 90, RANDOM()), CURRENT_TIMESTAMP()) AS last_access_date,
    DATEADD('day', UNIFORM(30, 90, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE())) AS exam_eligibility_date,
    UNIFORM(0, 100, RANDOM()) < 70 AS is_exam_eligible,
    NULL AS bundle_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN ARRAY_CONSTRUCT('SAVE20', 'NEWYEAR', 'SUMMER25', 'FLASH10', 'MILITARY15')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS promo_code,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN (ct.base_price * UNIFORM(10, 30, RANDOM()) / 100.0)::NUMBER(10,2) ELSE 0.00 END AS discount_amount,
    (ct.base_price * (1 - UNIFORM(0, 30, RANDOM()) / 100.0))::NUMBER(10,2) AS net_price,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'MONTHLY_3'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'MONTHLY_6'
         ELSE NULL END AS payment_plan,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM STUDENTS s
CROSS JOIN CERTIFICATION_TYPES ct
WHERE UNIFORM(0, 100, RANDOM()) < 15
LIMIT 100000;

-- ============================================================================
-- Step 7: Generate Exams
-- ============================================================================
INSERT INTO EXAMS
SELECT
    'EXAM' || LPAD(ROW_NUMBER() OVER (ORDER BY e.enrollment_id), 10, '0') AS exam_id,
    e.enrollment_id,
    e.student_id,
    e.certification_type_id,
    DATEADD('day', UNIFORM(30, 180, RANDOM()), e.enrollment_date) AS exam_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'ONLINE'
         ELSE 'IN_PERSON' END AS exam_type,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'PSI Testing Center' ELSE NULL END AS exam_location,
    NULL AS proctor_id,
    (UNIFORM(50, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS raw_score,
    (UNIFORM(50, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS scaled_score,
    70.00 AS passing_score,
    UNIFORM(0, 100, RANDOM()) < 75 AS passed,
    1 AS attempt_number,
    UNIFORM(60, 120, RANDOM()) AS time_taken_minutes,
    '{"domain1": ' || UNIFORM(50, 100, RANDOM()) || ', "domain2": ' || UNIFORM(50, 100, RANDOM()) || ', "domain3": ' || UNIFORM(50, 100, RANDOM()) || '}' AS sections_breakdown,
    'COMPLETED' AS exam_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), DATEADD('day', UNIFORM(30, 180, RANDOM()), e.enrollment_date)) ELSE NULL END AS certification_issued_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN DATEADD('year', 2, DATEADD('day', UNIFORM(30, 180, RANDOM()), e.enrollment_date)) ELSE NULL END AS certification_expiry_date,
    UNIFORM(0, 100, RANDOM()) < 75 AS is_certified,
    CURRENT_TIMESTAMP() AS created_at
FROM ENROLLMENTS e
WHERE e.enrollment_status IN ('COMPLETED', 'ACTIVE')
  AND UNIFORM(0, 100, RANDOM()) < 80
LIMIT 75000;

-- ============================================================================
-- Step 8: Generate Certifications (from passed exams)
-- ============================================================================
INSERT INTO CERTIFICATIONS
SELECT
    'CERT' || LPAD(ROW_NUMBER() OVER (ORDER BY ex.exam_id), 10, '0') AS certification_id,
    ex.student_id,
    ex.certification_type_id,
    ex.exam_id,
    'NASM-' || UPPER(ct.certification_code) || '-' || LPAD(ROW_NUMBER() OVER (ORDER BY ex.exam_id), 8, '0') AS certification_number,
    ex.certification_issued_date AS issued_date,
    ex.certification_expiry_date AS expiry_date,
    CASE WHEN ex.certification_expiry_date > CURRENT_DATE() THEN 'ACTIVE'
         WHEN DATEADD('month', -3, ex.certification_expiry_date) < CURRENT_DATE() THEN 'EXPIRING_SOON'
         ELSE 'EXPIRED' END AS certification_status,
    UNIFORM(0, 25, RANDOM()) AS ceus_earned,
    ct.ceu_required_for_recert AS ceus_required,
    CASE WHEN ex.certification_expiry_date <= CURRENT_DATE() THEN ex.certification_expiry_date ELSE NULL END AS recertification_date,
    UNIFORM(0, 5, RANDOM()) AS renewal_count,
    CASE WHEN ct.certification_category = 'PRIMARY' THEN TRUE ELSE FALSE END AS is_primary_credential,
    NULL AS specialty_areas,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM EXAMS ex
JOIN CERTIFICATION_TYPES ct ON ex.certification_type_id = ct.certification_type_id
WHERE ex.passed = TRUE
  AND ex.certification_issued_date IS NOT NULL
  AND ex.certification_expiry_date IS NOT NULL;

-- ============================================================================
-- Step 9: Generate CEU Completions
-- ============================================================================
INSERT INTO CEU_COMPLETIONS
SELECT
    'CEUC' || LPAD(ROW_NUMBER() OVER (ORDER BY s.student_id, cc.ceu_course_id), 10, '0') AS completion_id,
    s.student_id,
    cc.ceu_course_id,
    c.certification_id,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS enrollment_date,
    DATEADD('day', -1 * UNIFORM(1, 700, RANDOM()), CURRENT_DATE()) AS start_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) ELSE NULL END AS completion_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN 'COMPLETED'
         WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'IN_PROGRESS'
         ELSE 'NOT_STARTED' END AS completion_status,
    (UNIFORM(0, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS progress_pct,
    (UNIFORM(60, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS quiz_score,
    UNIFORM(0, 100, RANDOM()) < 85 AS quiz_passed,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN cc.ceu_credits ELSE 0.00 END AS ceus_earned,
    UNIFORM(15, 300, RANDOM()) AS time_spent_minutes,
    UNIFORM(0, 100, RANDOM()) < 70 AS certificate_issued,
    NULL AS order_id,
    cc.price AS price_paid,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM STUDENTS s
CROSS JOIN CEU_COURSES cc
LEFT JOIN CERTIFICATIONS c ON s.student_id = c.student_id
WHERE UNIFORM(0, 100, RANDOM()) < 0.6
LIMIT 150000;

-- ============================================================================
-- Step 10: Generate Orders
-- ============================================================================
INSERT INTO ORDERS
SELECT
    'ORD' || LPAD(ROW_NUMBER() OVER (ORDER BY s.student_id), 10, '0') AS order_id,
    s.student_id,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP()) AS order_date,
    'NASM-' || LPAD(UNIFORM(100000, 999999, RANDOM()), 6, '0') AS order_number,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'COMPLETED'
         WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN 'REFUNDED'
         ELSE 'CANCELLED' END AS order_status,
    (UNIFORM(199, 2000, RANDOM()) * 1.0)::NUMBER(12,2) AS subtotal,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN (UNIFORM(50, 400, RANDOM()) * 1.0)::NUMBER(10,2) ELSE 0.00 END AS discount_amount,
    (UNIFORM(10, 150, RANDOM()) * 1.0)::NUMBER(10,2) AS tax_amount,
    0.00 AS total_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN ARRAY_CONSTRUCT('SAVE20', 'NEWYEAR', 'SUMMER25', 'FLASH10', 'MILITARY15')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS promo_code,
    ARRAY_CONSTRUCT('CREDIT_CARD', 'PAYPAL', 'AFFIRM', 'DEBIT_CARD', 'APPLE_PAY')[UNIFORM(0, 4, RANDOM())] AS payment_method,
    'PAID' AS payment_status,
    s.address_line1 || ', ' || s.city || ', ' || s.state || ' ' || s.postal_code AS billing_address,
    UNIFORM(0, 100, RANDOM()) < 15 AS is_payment_plan,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN UNIFORM(3, 12, RANDOM()) ELSE NULL END AS payment_plan_months,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN (UNIFORM(50, 200, RANDOM()) * 1.0)::NUMBER(10,2) ELSE NULL END AS monthly_payment,
    ARRAY_CONSTRUCT('WEBSITE', 'MOBILE_APP', 'PHONE', 'CHAT')[UNIFORM(0, 3, RANDOM())] AS channel,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'CAMP' || LPAD(UNIFORM(1, 100, RANDOM()), 4, '0') ELSE NULL END AS campaign_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'AFF' || LPAD(UNIFORM(1, 500, RANDOM()), 5, '0') ELSE NULL END AS affiliate_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN (UNIFORM(100, 500, RANDOM()) * 1.0)::NUMBER(10,2) ELSE 0.00 END AS refund_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN DATEADD('day', UNIFORM(1, 30, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP())) ELSE NULL END AS refund_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN ARRAY_CONSTRUCT('Changed mind', 'Found cheaper', 'Technical issues', 'Not satisfied', 'Financial reasons')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS refund_reason,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM STUDENTS s
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 4))
WHERE UNIFORM(0, 100, RANDOM()) < 100
LIMIT 200000;

-- Update total amounts
UPDATE ORDERS
SET total_amount = subtotal - discount_amount + tax_amount;

-- ============================================================================
-- Step 11: Generate Support Tickets
-- ============================================================================
INSERT INTO SUPPORT_TICKETS
SELECT
    'TKT' || LPAD(ROW_NUMBER() OVER (ORDER BY s.student_id), 10, '0') AS ticket_id,
    s.student_id,
    'NASM-TKT-' || LPAD(UNIFORM(100000, 999999, RANDOM()), 6, '0') AS ticket_number,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP()) AS ticket_date,
    ARRAY_CONSTRUCT('TECHNICAL', 'BILLING', 'CERTIFICATION', 'EXAM', 'CEU', 'ACCOUNT', 'CONTENT', 'REFUND')[UNIFORM(0, 7, RANDOM())] AS ticket_type,
    ARRAY_CONSTRUCT('Access Issues', 'Payment Questions', 'Recertification', 'Exam Scheduling', 'Course Content', 'Account Management', 'Technical Support', 'General Inquiry')[UNIFORM(0, 7, RANDOM())] AS category,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'Cannot access my course materials'
        WHEN 1 THEN 'Need to reschedule my exam'
        WHEN 2 THEN 'Question about recertification requirements'
        WHEN 3 THEN 'Payment not processing correctly'
        WHEN 4 THEN 'Certificate not received after passing'
        WHEN 5 THEN 'CEU credits not showing in account'
        WHEN 6 THEN 'Video content not loading'
        WHEN 7 THEN 'Request for refund'
        WHEN 8 THEN 'Need to update billing information'
        ELSE 'General question about certification'
    END AS subject,
    'I am experiencing an issue with my account and need assistance resolving it.' AS description,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'URGENT')[UNIFORM(0, 3, RANDOM())] AS priority,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'RESOLVED'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'OPEN'
         ELSE 'PENDING' END AS ticket_status,
    'Support Agent ' || UNIFORM(1, 20, RANDOM()) AS assigned_to,
    DATEADD('hour', UNIFORM(1, 48, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP())) AS response_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN DATEADD('day', UNIFORM(1, 5, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP())) ELSE NULL END AS resolution_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'Issue resolved to customer satisfaction' ELSE NULL END AS resolution_notes,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN UNIFORM(3, 5, RANDOM()) ELSE NULL END AS satisfaction_rating,
    ARRAY_CONSTRUCT('EMAIL', 'PHONE', 'CHAT', 'SOCIAL')[UNIFORM(0, 3, RANDOM())] AS channel,
    NULL AS related_order_id,
    NULL AS related_enrollment_id,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM STUDENTS s
WHERE UNIFORM(0, 100, RANDOM()) < 60
LIMIT 30000;

-- ============================================================================
-- Step 12: Generate Student Feedback
-- ============================================================================
INSERT INTO STUDENT_FEEDBACK
SELECT
    'FDBK' || LPAD(ROW_NUMBER() OVER (ORDER BY e.enrollment_id), 10, '0') AS feedback_id,
    e.student_id,
    e.enrollment_id,
    e.certification_type_id,
    NULL AS ceu_course_id,
    DATEADD('day', UNIFORM(7, 60, RANDOM()), e.enrollment_date) AS feedback_date,
    ARRAY_CONSTRUCT('POST_COURSE', 'POST_EXAM', 'POST_CERTIFICATION', 'NPS_SURVEY', 'REVIEW')[UNIFORM(0, 4, RANDOM())] AS feedback_type,
    UNIFORM(1, 5, RANDOM()) AS overall_rating,
    UNIFORM(1, 5, RANDOM()) AS content_rating,
    UNIFORM(1, 5, RANDOM()) AS instructor_rating,
    UNIFORM(1, 5, RANDOM()) AS platform_rating,
    UNIFORM(1, 5, RANDOM()) AS value_rating,
    UNIFORM(1, 10, RANDOM()) AS likelihood_to_recommend,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'Excellent course content! The OPT model is incredibly valuable.'
        WHEN 1 THEN 'Great preparation for the exam. Passed on my first attempt!'
        WHEN 2 THEN 'The instructors are knowledgeable and engaging.'
        WHEN 3 THEN 'Some sections were too long. Could be more concise.'
        WHEN 4 THEN 'Outstanding value for the certification. Highly recommend!'
        WHEN 5 THEN 'The platform could be more user-friendly.'
        WHEN 6 THEN 'Changed my career. Best investment I ever made.'
        WHEN 7 THEN 'Good content but exam was harder than practice tests.'
        WHEN 8 THEN 'Would appreciate more practical video demonstrations.'
        ELSE 'Overall a solid certification program.'
    END AS feedback_comments,
    UNIFORM(0, 100, RANDOM()) < 80 AS would_recommend,
    NULL AS improvement_suggestions,
    UNIFORM(0, 100, RANDOM()) < 20 AS testimonial_approved,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN DATEADD('day', UNIFORM(1, 14, RANDOM()), DATEADD('day', UNIFORM(7, 60, RANDOM()), e.enrollment_date)) ELSE NULL END AS response_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'Thank you for your feedback!' ELSE NULL END AS response_text,
    ARRAY_CONSTRUCT('EMAIL_SURVEY', 'IN_APP', 'POST_EXAM', 'REVIEW_SITE')[UNIFORM(0, 3, RANDOM())] AS feedback_source,
    'REVIEWED' AS feedback_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM ENROLLMENTS e
WHERE UNIFORM(0, 100, RANDOM()) < 30
LIMIT 25000;

-- ============================================================================
-- Step 13: Generate Marketing Campaigns
-- ============================================================================
INSERT INTO MARKETING_CAMPAIGNS
SELECT
    'CAMP' || LPAD(SEQ4(), 4, '0') AS campaign_id,
    CASE (ABS(RANDOM()) % 10)
        WHEN 0 THEN 'New Year New Career Sale'
        WHEN 1 THEN 'Summer Fitness Challenge'
        WHEN 2 THEN 'Black Friday Mega Deal'
        WHEN 3 THEN 'Military Appreciation Month'
        WHEN 4 THEN 'Back to School Bundle'
        WHEN 5 THEN 'Holiday Gift Certification'
        WHEN 6 THEN 'Flash Sale Weekend'
        WHEN 7 THEN 'Partner Gym Promo'
        WHEN 8 THEN 'Referral Bonus Program'
        ELSE 'Seasonal Promotion'
    END AS campaign_name,
    ARRAY_CONSTRUCT('SEASONAL', 'FLASH_SALE', 'PARTNER', 'REFERRAL', 'LOYALTY', 'RETARGETING', 'AWARENESS', 'LEAD_GEN')[UNIFORM(0, 7, RANDOM())] AS campaign_type,
    ARRAY_CONSTRUCT('EMAIL', 'SOCIAL', 'PAID_SEARCH', 'DISPLAY', 'AFFILIATE', 'PODCAST', 'INFLUENCER', 'DIRECT_MAIL')[UNIFORM(0, 7, RANDOM())] AS campaign_channel,
    ARRAY_CONSTRUCT('ALL', 'NEW_LEADS', 'EXISTING_STUDENTS', 'EXPIRED_CERTS', 'CAREER_CHANGERS', 'GYM_EMPLOYEES', 'MILITARY')[UNIFORM(0, 6, RANDOM())] AS target_audience,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(7, 60, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE())) AS end_date,
    (UNIFORM(5000, 100000, RANDOM()) * 1.0)::NUMBER(12,2) AS budget,
    ARRAY_CONSTRUCT('PERCENTAGE_OFF', 'DOLLAR_OFF', 'BUNDLE_DEAL', 'FREE_EXAM', 'FREE_RETEST', 'EXTENDED_ACCESS')[UNIFORM(0, 5, RANDOM())] AS offer_type,
    UPPER(SUBSTR(MD5(RANDOM()), 1, 8)) AS discount_code,
    (UNIFORM(10, 40, RANDOM()) * 1.0)::NUMBER(5,2) AS discount_percentage,
    (UNIFORM(50, 300, RANDOM()) * 1.0)::NUMBER(10,2) AS discount_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'COMPLETED' ELSE 'ACTIVE' END AS campaign_status,
    UNIFORM(50000, 2000000, RANDOM()) AS impressions,
    UNIFORM(1000, 50000, RANDOM()) AS clicks,
    UNIFORM(100, 5000, RANDOM()) AS leads_generated,
    UNIFORM(50, 1000, RANDOM()) AS conversions,
    (UNIFORM(50000, 500000, RANDOM()) * 1.0)::NUMBER(15,2) AS revenue_attributed,
    (UNIFORM(10, 100, RANDOM()) * 1.0)::NUMBER(10,2) AS cost_per_lead,
    (UNIFORM(100, 500, RANDOM()) * 1.0)::NUMBER(10,2) AS cost_per_acquisition,
    (UNIFORM(100, 500, RANDOM()) * 1.0)::NUMBER(8,2) AS roi_percentage,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- ============================================================================
-- Step 14: Generate Lead Interactions
-- ============================================================================
INSERT INTO LEAD_INTERACTIONS
SELECT
    'LEAD' || LPAD(ROW_NUMBER() OVER (ORDER BY s.student_id), 10, '0') AS interaction_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN s.student_id ELSE NULL END AS student_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'prospect' || UNIFORM(1, 50000, RANDOM()) || '@gmail.com' ELSE s.email END AS lead_email,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'CAMP' || LPAD(UNIFORM(0, 99, RANDOM()), 4, '0') ELSE NULL END AS campaign_id,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP()) AS interaction_date,
    ARRAY_CONSTRUCT('PAGE_VIEW', 'EMAIL_OPEN', 'EMAIL_CLICK', 'FORM_SUBMIT', 'DOWNLOAD', 'CHAT', 'WEBINAR', 'CALL')[UNIFORM(0, 7, RANDOM())] AS interaction_type,
    ARRAY_CONSTRUCT('WEBSITE', 'EMAIL', 'SOCIAL', 'PAID', 'ORGANIC', 'REFERRAL')[UNIFORM(0, 5, RANDOM())] AS interaction_channel,
    ARRAY_CONSTRUCT('/cpt', '/ces', '/nutrition', '/pricing', '/careers', '/blog', '/free-resources', '/about')[UNIFORM(0, 7, RANDOM())] AS page_visited,
    ARRAY_CONSTRUCT('CPT Brochure', 'Career Guide', 'Salary Report', 'Sample Exam', 'OPT Model PDF', 'Webinar Recording')[UNIFORM(0, 5, RANDOM())] AS content_viewed,
    UNIFORM(10, 600, RANDOM()) AS time_on_page_seconds,
    ARRAY_CONSTRUCT('CPT', 'CES', 'PES', 'CNC', 'FNS', 'BUNDLE')[UNIFORM(0, 5, RANDOM())] AS certification_interest,
    UNIFORM(0, 100, RANDOM()) AS lead_score,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'CONVERTED'
         WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'QUALIFIED'
         WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'NURTURING'
         ELSE 'NEW' END AS lead_status,
    UNIFORM(0, 100, RANDOM()) < 30 AS converted,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN DATEADD('day', UNIFORM(1, 60, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE())) ELSE NULL END AS conversion_date,
    NULL AS conversion_order_id,
    ARRAY_CONSTRUCT('google', 'facebook', 'instagram', 'linkedin', 'youtube', 'bing', 'email', 'direct')[UNIFORM(0, 7, RANDOM())] AS utm_source,
    ARRAY_CONSTRUCT('cpc', 'organic', 'social', 'email', 'referral', 'display')[UNIFORM(0, 5, RANDOM())] AS utm_medium,
    ARRAY_CONSTRUCT('spring_sale', 'career_change', 'brand', 'retarget', 'partner')[UNIFORM(0, 4, RANDOM())] AS utm_campaign,
    ARRAY_CONSTRUCT('DESKTOP', 'MOBILE', 'TABLET')[UNIFORM(0, 2, RANDOM())] AS device_type,
    CURRENT_TIMESTAMP() AS created_at
FROM STUDENTS s
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 2))
WHERE UNIFORM(0, 100, RANDOM()) < 100
LIMIT 100000;

-- ============================================================================
-- Step 15: Generate Subscriptions
-- ============================================================================
INSERT INTO SUBSCRIPTIONS
SELECT
    'SUB' || LPAD(ROW_NUMBER() OVER (ORDER BY s.student_id), 8, '0') AS subscription_id,
    s.student_id,
    ARRAY_CONSTRUCT('EDGE_MONTHLY', 'EDGE_ANNUAL', 'CEU_UNLIMITED', 'PREMIUM')[UNIFORM(0, 3, RANDOM())] AS subscription_type,
    CASE (ABS(RANDOM()) % 4)
        WHEN 0 THEN 'NASM Edge Monthly'
        WHEN 1 THEN 'NASM Edge Annual'
        WHEN 2 THEN 'CEU Unlimited Access'
        ELSE 'NASM Premium Membership'
    END AS subscription_name,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS start_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN DATEADD('day', -1 * UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) ELSE NULL END AS end_date,
    DATEADD('month', UNIFORM(1, 12, RANDOM()), CURRENT_DATE()) AS renewal_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'ACTIVE'
         WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'CANCELLED'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'PAUSED'
         ELSE 'EXPIRED' END AS subscription_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'MONTHLY' ELSE 'ANNUAL' END AS billing_frequency,
    ARRAY_CONSTRUCT(19.99, 24.99, 29.99, 39.99)[UNIFORM(0, 3, RANDOM())]::NUMBER(10,2) AS monthly_rate,
    ARRAY_CONSTRUCT(179.88, 239.88, 299.88, 399.88)[UNIFORM(0, 3, RANDOM())]::NUMBER(10,2) AS annual_rate,
    UNIFORM(0, 100, RANDOM()) < 80 AS auto_renew,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN DATEADD('day', -1 * UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) ELSE NULL END AS cancellation_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN ARRAY_CONSTRUCT('Too expensive', 'Not using enough', 'Found alternative', 'Completed certification', 'Financial reasons')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS cancellation_reason,
    NULL AS pause_start_date,
    NULL AS pause_end_date,
    (UNIFORM(50, 1000, RANDOM()) * 1.0)::NUMBER(12,2) AS total_billed,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM STUDENTS s
WHERE UNIFORM(0, 100, RANDOM()) < 20
LIMIT 10000;

-- ============================================================================
-- Display data generation completion summary
-- ============================================================================
SELECT 'Data generation completed successfully' AS status,
       (SELECT COUNT(*) FROM CERTIFICATION_TYPES) AS certification_types,
       (SELECT COUNT(*) FROM STUDENTS) AS students,
       (SELECT COUNT(*) FROM ENROLLMENTS) AS enrollments,
       (SELECT COUNT(*) FROM EXAMS) AS exams,
       (SELECT COUNT(*) FROM CERTIFICATIONS) AS certifications,
       (SELECT COUNT(*) FROM CEU_COURSES) AS ceu_courses,
       (SELECT COUNT(*) FROM CEU_COMPLETIONS) AS ceu_completions,
       (SELECT COUNT(*) FROM ORDERS) AS orders,
       (SELECT COUNT(*) FROM SUPPORT_TICKETS) AS support_tickets,
       (SELECT COUNT(*) FROM STUDENT_FEEDBACK) AS student_feedback,
       (SELECT COUNT(*) FROM MARKETING_CAMPAIGNS) AS marketing_campaigns,
       (SELECT COUNT(*) FROM LEAD_INTERACTIONS) AS lead_interactions;

