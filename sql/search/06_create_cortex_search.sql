-- ============================================================================
-- NASM Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          student reviews, course content, and FAQ documents
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE NASM_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE NASM_WH;

-- ============================================================================
-- Step 1: Create table for student reviews (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE STUDENT_REVIEWS (
    review_id VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(30),
    enrollment_id VARCHAR(30),
    certification_type_id VARCHAR(20),
    review_text VARCHAR(16777216) NOT NULL,
    review_title VARCHAR(500),
    certification_name VARCHAR(200),
    rating NUMBER(3,0),
    review_source VARCHAR(50),
    review_date DATE NOT NULL,
    verified_purchase BOOLEAN DEFAULT TRUE,
    helpful_votes NUMBER(8,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id)
);

-- ============================================================================
-- Step 2: Create table for course content documents
-- ============================================================================
CREATE OR REPLACE TABLE COURSE_CONTENT (
    content_id VARCHAR(30) PRIMARY KEY,
    certification_type_id VARCHAR(20),
    ceu_course_id VARCHAR(30),
    title VARCHAR(500) NOT NULL,
    content VARCHAR(16777216) NOT NULL,
    content_type VARCHAR(50),
    module_name VARCHAR(200),
    chapter_number NUMBER(3,0),
    topic_tags VARCHAR(500),
    difficulty_level VARCHAR(30),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (certification_type_id) REFERENCES CERTIFICATION_TYPES(certification_type_id),
    FOREIGN KEY (ceu_course_id) REFERENCES CEU_COURSES(ceu_course_id)
);

-- ============================================================================
-- Step 3: Create table for FAQ documents
-- ============================================================================
CREATE OR REPLACE TABLE FAQ_DOCUMENTS (
    faq_id VARCHAR(30) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content VARCHAR(16777216) NOT NULL,
    category VARCHAR(50),
    topic VARCHAR(100),
    document_type VARCHAR(50),
    keywords VARCHAR(500),
    related_certification VARCHAR(100),
    effective_date DATE,
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    is_published BOOLEAN DEFAULT TRUE,
    view_count NUMBER(10,0) DEFAULT 0,
    helpful_count NUMBER(8,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE STUDENT_REVIEWS SET CHANGE_TRACKING = TRUE;
ALTER TABLE COURSE_CONTENT SET CHANGE_TRACKING = TRUE;
ALTER TABLE FAQ_DOCUMENTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample student reviews
-- ============================================================================
INSERT INTO STUDENT_REVIEWS
SELECT
    'REV' || LPAD(ROW_NUMBER() OVER (ORDER BY e.enrollment_id), 10, '0') AS review_id,
    e.student_id,
    e.enrollment_id,
    e.certification_type_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'The NASM CPT certification completely transformed my career! The OPT model is revolutionary and gives you a systematic approach to training that really sets you apart from other trainers. The content was comprehensive and the practice exams prepared me well for the actual test. I passed on my first attempt with an 85%. The investment was absolutely worth it. I went from making $15/hour at a big box gym to running my own successful training business making six figures. If you''re serious about a fitness career, NASM is the gold standard. The knowledge I gained has allowed me to help hundreds of clients achieve their goals. Can''t recommend it enough!'
        WHEN 1 THEN 'Just passed my CES exam! The Corrective Exercise Specialist certification has given me incredible tools for assessing and addressing movement dysfunction. My clients with chronic pain are finally seeing results because I can now identify the root cause of their issues. The overhead squat assessment alone was worth the price of the program. The content on muscle imbalances and integrated flexibility is outstanding. I do wish there were more video demonstrations of the techniques, but the written content is thorough. Already seeing a huge impact on my client retention!'
        WHEN 2 THEN 'Mixed feelings about the CPT program. The content itself is excellent - the OPT model makes sense and the science is solid. However, I found the online platform clunky and hard to navigate. Videos would buffer constantly and the quiz interface was frustrating. Customer support was helpful when I reached out but took 3 days to respond. Passed the exam on my second attempt (first time I ran out of time). The certification has opened doors for me career-wise, so ultimately worth it, but the learning experience could be improved.'
        WHEN 3 THEN 'Performance Enhancement Specialist certification exceeded my expectations! As a former college athlete turned trainer, I was looking for science-based sports performance programming, and PES delivered. The content on speed, agility, and power development is exactly what I needed for my athletic clients. The integrated training approach complements my CPT knowledge perfectly. Now I can confidently work with everyone from weekend warriors to competitive athletes. The price is fair for the value you get.'
        WHEN 4 THEN 'Completed my recertification through NASM Edge and it was seamless. The CEU courses are well-organized and I actually learned useful information (not just going through the motions for credits). The behavior change modules were particularly valuable for improving my client communication. The platform tracks everything automatically so I didn''t have to worry about losing my credentials. Would recommend Edge to anyone needing to recertify - it''s convenient and cost-effective.'
        WHEN 5 THEN 'The Fitness Nutrition Specialist course gave me the confidence to have nutrition conversations with my clients. I''m not a dietitian but now I understand macros, meal timing, and how to guide clients toward better eating habits within my scope of practice. The content on supplements and hydration was eye-opening. My only complaint is I wish there was more content on specific diets (keto, vegan, etc.) but overall very practical information. Clients love that I can provide nutrition guidance alongside their training programs.'
        WHEN 6 THEN 'Struggled with the CPT exam despite studying for 4 months. The exam felt much harder than the practice tests. Some questions had scenarios that weren''t covered in the textbook. Failed on first attempt with 68%, but used the free retest that came with my bundle and passed with 73%. The content is good but exam prep could be better. Make sure you do tons of practice questions, not just read the textbook. The forums were helpful for connecting with other students going through the same thing.'
        WHEN 7 THEN 'Certified Nutrition Coach program was comprehensive but dense. Took me 6 months to get through all the material while working full-time. The content on behavior change and coaching psychology was the highlight - helped me understand WHY clients struggle with nutrition changes. The program gave me the credentials I needed to start a nutrition coaching side business. Customer support was responsive when I had questions. Worth the investment if you''re serious about adding nutrition services.'
        WHEN 8 THEN 'The Weight Loss Specialist certification was exactly what I needed for my target clientele. My gym mainly serves clients wanting to lose weight, and now I have specialized knowledge to help them. The content on metabolism, body composition, and psychological aspects of weight loss was valuable. The program is shorter than the main certifications which was perfect for adding a specialization. Wish the exam was proctored online like CPT - had to schedule at a testing center which was inconvenient.'
        WHEN 9 THEN 'Just started the CPT program and so far so good! The NASM app makes it easy to study on my commute. The textbook is well-organized and the videos help clarify complex concepts. Currently on Chapter 8 (Flexibility Training) and feeling confident about the material. The community forums are active and helpful when I have questions. Scheduled my exam for 2 months out. The flashcards included in the package are great for memorizing muscle actions. Will update this review after I take the exam!'
        WHEN 10 THEN 'Been a NASM certified trainer for 5 years now and recertified twice. The quality of the program has improved over the years. The updated content reflects current research and trends. I appreciate that NASM keeps evolving their curriculum. The CEU courses are much better than they used to be - actually engaging content rather than boring text-only modules. The NASM community and name recognition have definitely helped my career. Proud to have those letters after my name.'
        WHEN 11 THEN 'Group Fitness Specialist certification helped me land my dream job as a group ex instructor at Equinox! The program covered class design, cueing, music selection, and group dynamics. I learned how to manage different fitness levels within a single class. The practical components were useful but I wish there was a live workshop option. Passed the exam easily. If you want to teach group fitness classes, this certification will give you the foundation you need. Great add-on to CPT.'
        WHEN 12 THEN 'Disappointed with customer service experience. Had trouble accessing my course materials after purchase and it took over a week to resolve. Once I got access, the content was good and I passed my CPT exam. But the initial frustration almost made me regret my purchase. The certification itself is well-respected in the industry and I''ve already gotten job offers. Just wish the customer experience matched the quality of the educational content. 3 stars for the experience, 5 stars for the actual program.'
        WHEN 13 THEN 'The Senior Fitness Specialist certification opened up a whole new client base for me! As the population ages, there''s huge demand for trainers who understand older adults. The content on age-related changes, common conditions, and appropriate modifications was exactly what I needed. My senior clients appreciate that I have specialized knowledge for their needs. The assessment protocols for balance and mobility are invaluable. Highly recommend for anyone working with 55+ clients.'
        WHEN 14 THEN 'Virtual Coaching Specialist was perfect timing with everything going online. Learned how to conduct effective remote training sessions, use technology for client management, and build an online presence. The pandemic accelerated my online coaching business and this certification gave me the skills to serve clients anywhere. Worth every penny. The content on video platform setup and client communication was practical and immediately applicable. Online coaching is the future!'
        WHEN 15 THEN 'Youth Exercise Specialist certification was essential for my work at a local sports academy. Kids aren''t just small adults, and this program taught me age-appropriate training methods. The content on motor development, fun programming, and working with parents was extremely helpful. I can now confidently train young athletes ages 6-18 with proper progressions for each developmental stage. Important certification if you work with youth sports.'
        WHEN 16 THEN 'The Behavior Change Specialist certification was a game-changer for client retention. Understanding psychology and motivation has helped me help clients stick to their programs. The content on habits, self-efficacy, and goal-setting was outstanding. My clients are now achieving long-term success, not just short-term results. Every trainer should take this course - the physical programming is only half the battle. Behavior change is where the real transformation happens.'
        WHEN 17 THEN 'CPT All-Inclusive package was the way to go. Included the exam, a free retest (which I ended up needing), textbook, and study materials. The job guarantee gave me peace of mind about the investment. Studied for 3 months using the structured study plan and passed on my second attempt. Now training at a boutique gym and loving it. The NASM name opened doors for me in the interview process. Grateful I chose the all-inclusive option.'
        WHEN 18 THEN 'MMA Conditioning Specialist is a niche certification but exactly what I was looking for. I train fighters at a local MMA gym and needed sport-specific knowledge. The content on energy systems, periodization for combat sports, and injury prevention was excellent. My fighters are performing better and staying healthier through camps. If you work with combat athletes, this specialization is worth adding to your CPT. Very specialized but very useful.'
        ELSE 'Great certification program! NASM is well-respected in the industry and the content prepared me well for my career. The OPT model provides a solid foundation for training all populations. Would recommend to anyone considering a fitness career. The investment was worth it for the doors it opened. Passed my exam and now working as a full-time personal trainer!'
    END AS review_text,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Career Transformation - Best Decision Ever!'
        WHEN 1 THEN 'CES Changed How I Train Clients'
        WHEN 2 THEN 'Great Content, Platform Needs Work'
        WHEN 3 THEN 'Perfect for Sports Performance'
        WHEN 4 THEN 'Seamless Recertification Experience'
        WHEN 5 THEN 'Solid Nutrition Knowledge'
        WHEN 6 THEN 'Exam Was Challenging'
        WHEN 7 THEN 'Comprehensive Nutrition Coaching'
        WHEN 8 THEN 'Specialized Weight Loss Knowledge'
        WHEN 9 THEN 'Currently Studying - Looking Good!'
        WHEN 10 THEN '5 Years with NASM - Still Impressed'
        WHEN 11 THEN 'Dream Group Fitness Job!'
        WHEN 12 THEN 'Good Program, Rocky Start'
        WHEN 13 THEN 'Specialized Senior Fitness Knowledge'
        WHEN 14 THEN 'Online Coaching Skills!'
        WHEN 15 THEN 'Essential for Youth Training'
        WHEN 16 THEN 'Behavior Change Game-Changer'
        WHEN 17 THEN 'All-Inclusive Worth It'
        WHEN 18 THEN 'Perfect for MMA Training'
        ELSE 'Solid Certification Program'
    END AS review_title,
    ct.certification_name,
    CASE WHEN ABS(RANDOM()) % 20 IN (2, 6, 12) THEN UNIFORM(3, 4, RANDOM())
         ELSE UNIFORM(4, 5, RANDOM()) END AS rating,
    ARRAY_CONSTRUCT('GOOGLE', 'TRUSTPILOT', 'YELP', 'INDEED', 'DIRECT_SURVEY', 'SOCIAL_MEDIA')[UNIFORM(0, 5, RANDOM())] AS review_source,
    DATEADD('day', UNIFORM(7, 90, RANDOM()), e.enrollment_date) AS review_date,
    TRUE AS verified_purchase,
    UNIFORM(0, 150, RANDOM()) AS helpful_votes,
    CURRENT_TIMESTAMP() AS created_at
FROM RAW.ENROLLMENTS e
JOIN RAW.CERTIFICATION_TYPES ct ON e.certification_type_id = ct.certification_type_id
WHERE e.enrollment_status = 'COMPLETED'
  AND UNIFORM(0, 100, RANDOM()) < 15
LIMIT 10000;

-- ============================================================================
-- Step 6: Generate course content documents
-- ============================================================================
INSERT INTO COURSE_CONTENT VALUES
('CONT001', 'CERT001', NULL, 'Introduction to the OPT Model',
$$THE OPTIMUM PERFORMANCE TRAINING (OPT) MODEL
Chapter 1: Introduction

1.1 OVERVIEW OF THE OPT MODEL

The Optimum Performance Training (OPT) model is NASM's comprehensive training approach that systematically progresses clients through specific phases to achieve optimal results. Developed by Dr. Michael Clark, the OPT model is the foundation of all NASM programming.

1.2 THE THREE LEVELS OF TRAINING

The OPT model consists of three main levels:

LEVEL 1: STABILIZATION
This foundational level focuses on developing muscular endurance, stability, and neuromuscular efficiency. Key characteristics:
- Low to moderate intensity
- High repetitions (12-20)
- Slow, controlled tempos
- Focus on proprioception and core stability
- Corrective exercise integration

LEVEL 2: STRENGTH
Building on stabilization, this level develops muscular strength through progressive overload. Three phases:
- Strength Endurance: Combines strength with stabilization
- Hypertrophy: Maximizes muscle growth
- Maximal Strength: Develops peak force production

LEVEL 3: POWER
The highest level develops explosive power and speed for athletic performance. Combines strength with speed training for maximum force production in minimal time.

1.3 PROGRAM DESIGN PRINCIPLES

When designing OPT programs, consider:
- Client's current fitness level
- Goals and timeline
- Movement quality and compensations
- Available equipment and time
- Progression and regression strategies

1.4 ASSESSMENT INTEGRATION

The OPT model begins with comprehensive assessments:
- Posture assessment
- Movement assessment (overhead squat)
- Performance assessments
- Medical history and lifestyle factors

These assessments inform phase selection and exercise modifications.$$,
'CHAPTER_CONTENT', 'OPT Model Fundamentals', 1, 'OPT model, stabilization, strength, power, program design', 'BEGINNER', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('CONT002', 'CERT001', NULL, 'Flexibility Training Continuum',
$$FLEXIBILITY TRAINING CONTINUUM
Chapter 8: Flexibility Training

8.1 UNDERSTANDING FLEXIBILITY

Flexibility is the normal extensibility of all soft tissues that allow full range of motion of a joint. The flexibility training continuum includes three phases aligned with the OPT model.

8.2 TYPES OF FLEXIBILITY TRAINING

CORRECTIVE FLEXIBILITY (Stabilization Level)
Purpose: Improve muscle imbalances and altered joint motion
Techniques:
- Self-myofascial release (SMR)
- Static stretching
Guidelines: Hold stretches 30 seconds, 1-2 sets per muscle group

ACTIVE FLEXIBILITY (Strength Level)
Purpose: Improve neuromuscular efficiency and extensibility
Techniques:
- Self-myofascial release
- Active-isolated stretching
Guidelines: 5-10 repetitions, 1-2 second holds

FUNCTIONAL FLEXIBILITY (Power Level)
Purpose: Improve multiplanar extensibility with optimal control
Techniques:
- Self-myofascial release
- Dynamic stretching
Guidelines: 1-2 sets, 10-15 repetitions per exercise

8.3 SELF-MYOFASCIAL RELEASE (SMR)

SMR uses pressure from tools like foam rollers to release tension in the fascia. Key points:
- Apply pressure to tender spots
- Hold for 30-90 seconds until tenderness decreases
- Focus on commonly tight areas: IT band, calves, piriformis, lats

8.4 PRACTICAL APPLICATIONS

For clients with postural distortions:
1. Start with SMR on tight/overactive muscles
2. Follow with appropriate stretching technique
3. Progress through continuum as client improves$$,
'CHAPTER_CONTENT', 'Flexibility Training', 8, 'flexibility, SMR, stretching, foam rolling, mobility', 'INTERMEDIATE', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('CONT003', 'CERT002', NULL, 'Corrective Exercise Assessment',
$$CORRECTIVE EXERCISE SPECIALIST
Module 3: Assessment Protocols

3.1 THE OVERHEAD SQUAT ASSESSMENT

The overhead squat assessment is the cornerstone of NASM's movement assessment. It reveals compensations and muscle imbalances throughout the kinetic chain.

PROPER FORM:
- Feet shoulder-width apart, toes pointing forward
- Arms extended overhead, in line with ears
- Descend as if sitting in a chair
- Observe from anterior, lateral, and posterior views

3.2 COMMON COMPENSATIONS

FEET TURN OUT:
Overactive: Soleus, lateral gastrocnemius, biceps femoris
Underactive: Medial gastrocnemius, gracilis, sartorius
Corrective strategy: SMR calves, stretch calves, strengthen tibialis anterior

KNEES CAVE IN (VALGUS):
Overactive: Adductors, TFL, vastus lateralis
Underactive: Gluteus medius, gluteus maximus, VMO
Corrective strategy: SMR adductors and TFL, stretch hip flexors, strengthen glutes

LOW BACK ARCHES:
Overactive: Hip flexors, erector spinae
Underactive: Core, gluteus maximus
Corrective strategy: SMR hip flexors, stretch hip flexors, strengthen core and glutes

ARMS FALL FORWARD:
Overactive: Lats, pectorals
Underactive: Mid/lower trapezius, rhomboids
Corrective strategy: SMR lats, stretch lats and pecs, strengthen back extensors

3.3 CORRECTIVE EXERCISE STRATEGIES

The corrective exercise continuum:
1. INHIBIT: SMR on overactive muscles
2. LENGTHEN: Static stretch overactive muscles
3. ACTIVATE: Isolated strengthening of underactive muscles
4. INTEGRATE: Integrated dynamic movements$$,
'MODULE_CONTENT', 'Assessment Protocols', 3, 'assessment, overhead squat, compensations, muscle imbalances', 'ADVANCED', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('CONT004', 'CERT005', NULL, 'Behavior Change and Nutrition Coaching',
$$CERTIFIED NUTRITION COACH
Chapter 5: Behavior Change Strategies

5.1 THE PSYCHOLOGY OF CHANGE

Successful nutrition coaching requires understanding the psychological factors that influence eating behavior. This chapter covers evidence-based behavior change strategies.

5.2 TRANSTHEORETICAL MODEL (STAGES OF CHANGE)

PRECONTEMPLATION: Not considering change
- Approach: Raise awareness, provide information without pressure

CONTEMPLATION: Considering change
- Approach: Explore ambivalence, discuss pros and cons

PREPARATION: Planning for change
- Approach: Help develop specific action plan

ACTION: Actively making changes
- Approach: Provide support, problem-solve barriers

MAINTENANCE: Sustaining changes
- Approach: Prevent relapse, reinforce new habits

5.3 MOTIVATIONAL INTERVIEWING

Key principles for nutrition coaching conversations:
- Express empathy through reflective listening
- Develop discrepancy between current behavior and goals
- Roll with resistance rather than arguing
- Support self-efficacy and autonomy
- Use open-ended questions

5.4 SMART GOAL SETTING

Effective nutrition goals are:
- Specific: "I will eat vegetables at every dinner"
- Measurable: "I will drink 8 glasses of water daily"
- Achievable: Within client's current capabilities
- Relevant: Aligned with client's values and larger goals
- Time-bound: "For the next 4 weeks"

5.5 HABIT FORMATION

Keys to building lasting nutrition habits:
- Start small (tiny habits)
- Anchor to existing routines
- Make the behavior obvious, attractive, easy, and satisfying
- Track progress and celebrate wins
- Plan for obstacles and setbacks$$,
'CHAPTER_CONTENT', 'Behavior Change Strategies', 5, 'behavior change, motivation, habits, goal setting, coaching', 'INTERMEDIATE', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('CONT005', 'CERT003', NULL, 'Speed and Power Development',
$$PERFORMANCE ENHANCEMENT SPECIALIST
Module 7: Speed, Agility, and Quickness Training

7.1 COMPONENTS OF SPEED

Speed is the ability to move the body in one direction as fast as possible. Components include:
- Stride length: Distance covered per stride
- Stride frequency: Number of strides per unit of time
- Proper running mechanics: Arm action, posture, ground contact

7.2 SPEED TRAINING PROGRESSIONS

Following the OPT model:
STABILIZATION: Marching, skipping, controlled running drills
STRENGTH: Resistance running, sled pushes/pulls
POWER: Sprints, overspeed training, plyometrics

7.3 AGILITY TRAINING

Agility is the ability to accelerate, decelerate, and change direction quickly while maintaining control. Training progressions:

LEVEL 1: Controlled movement patterns
- Ladder drills at slow speeds
- Cone drills with planned routes

LEVEL 2: Increased speed and complexity
- Faster ladder patterns
- More complex cone sequences

LEVEL 3: Reactive agility
- Respond to visual/auditory cues
- Sport-specific scenarios

7.4 QUICKNESS TRAINING

Quickness emphasizes reaction time and first-step explosiveness:
- Ball drops
- Mirror drills
- Reaction lights
- Partner cue-based drills

7.5 PROGRAM DESIGN CONSIDERATIONS

- Rest-to-work ratios: 1:3 to 1:5 for speed/power
- Volume: 4-8 sets, 3-5 reps
- Frequency: 1-3 sessions per week
- Quality over quantity
- Adequate recovery between sessions$$,
'MODULE_CONTENT', 'Speed and Power Development', 7, 'speed training, agility, quickness, SAQ, athletic performance', 'ADVANCED', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 7: Generate FAQ documents
-- ============================================================================
INSERT INTO FAQ_DOCUMENTS VALUES
('FAQ001', 'How do I maintain my NASM certification?',
$$NASM CERTIFICATION RECERTIFICATION GUIDE

To maintain your NASM certification, you must complete 20 continuing education units (CEUs) every two years before your certification expiration date.

EARNING CEUs:

1. NASM CEU Courses: Complete approved continuing education courses through NASM
2. NASM Edge: Subscribe for unlimited access to CEU courses
3. External Providers: Approved third-party CEU providers
4. Live Workshops: Attend NASM-approved live events
5. College Credits: Applicable degree-related coursework

CEU CATEGORIES:
- Primary CEUs: Must complete at least 1.0 CEU in CPR/AED
- General CEUs: Remaining credits in any approved topic

RECERTIFICATION PROCESS:
1. Log into your NASM account
2. Navigate to "My Certifications"
3. Verify your CEU completion status
4. If CEUs are complete, pay the $99 recertification fee
5. Your new certificate will be issued within 24-48 hours

GRACE PERIOD:
If your certification expires, you have a 90-day grace period to complete recertification. During this time:
- You cannot advertise or practice as a NASM-certified trainer
- After 90 days, you must retake the certification exam

NEED HELP?
Contact NASM Support at support@nasm.org or call 1-800-460-NASM$$,
'RECERTIFICATION', 'Maintaining Certification', 'FAQ', 'recertification, CEU, continuing education, renewal', 'ALL', '2024-01-01', CURRENT_TIMESTAMP(), TRUE, 15000, 1200, CURRENT_TIMESTAMP()),

('FAQ002', 'What are the CPT exam requirements and format?',
$$NASM CPT EXAM INFORMATION

EXAM REQUIREMENTS:
- Must be 18 years or older
- Have a high school diploma or equivalent
- Hold current CPR/AED certification
- Complete the NASM CPT program

EXAM FORMAT:
- 120 multiple-choice questions
- 100 scored questions + 20 unscored pilot questions
- 2 hours to complete
- Computer-based testing
- Available online proctored or at PSI testing centers

EXAM DOMAINS:
1. Basic and Applied Sciences (17%)
2. Assessment (18%)
3. Program Design (21%)
4. Exercise Technique and Training Instruction (22%)
5. Client Relations and Behavioral Coaching (12%)
6. Professional Development and Responsibility (10%)

PASSING SCORE:
- Scaled score of 70 or higher required
- Scores range from 0-100
- Results provided immediately upon completion

SCHEDULING:
- Online proctored exams available 24/7
- Testing center appointments through PSI
- Schedule at psiexams.com with your NASM registration

RETAKE POLICY:
- Wait 24 hours before scheduling a retest
- Retake fee: $199 (unless included in bundle)
- No limit on number of attempts$$,
'CERTIFICATION', 'CPT Exam', 'FAQ', 'CPT exam, test format, requirements, passing score', 'CPT', '2024-01-01', CURRENT_TIMESTAMP(), TRUE, 25000, 2000, CURRENT_TIMESTAMP()),

('FAQ003', 'What is the difference between CPT, CES, and PES certifications?',
$$NASM CERTIFICATION COMPARISON

CERTIFIED PERSONAL TRAINER (CPT)
- NASM's flagship certification
- Comprehensive personal training education
- Covers all populations and fitness levels
- Required foundation for specializations
- NCCA accredited
- Ideal for: Anyone starting a fitness career

CORRECTIVE EXERCISE SPECIALIST (CES)
- Specialization for movement assessment
- Focus on identifying and correcting compensations
- In-depth postural and movement analysis
- Corrective programming strategies
- Ideal for: Trainers working with injury-prone clients, pain management

PERFORMANCE ENHANCEMENT SPECIALIST (PES)
- Specialization for athletic performance
- Sports-specific training methodologies
- Speed, agility, and power development
- Periodization for athletes
- Ideal for: Trainers working with athletes at any level

RECOMMENDED PATH:
1. Start with CPT for foundational knowledge
2. Add CES for clinical/corrective focus
3. Add PES for athletic performance focus

ELITE TRAINER BUNDLE:
Get all three (CPT + CES + PES) at a discounted rate for the most comprehensive training education.$$,
'CERTIFICATION', 'Certification Comparison', 'FAQ', 'CPT vs CES vs PES, certification differences, which certification', 'ALL', '2024-01-01', CURRENT_TIMESTAMP(), TRUE, 30000, 2500, CURRENT_TIMESTAMP()),

('FAQ004', 'How do I access my course materials and exams?',
$$ACCESSING YOUR NASM ACCOUNT

LOGGING IN:
1. Go to www.nasm.org
2. Click "Login" in the top right corner
3. Enter your email and password
4. Access your dashboard

COURSE MATERIALS:
- Navigate to "My Courses" from your dashboard
- Click on your enrolled program
- Access textbook, videos, quizzes, and resources
- Track your progress through the module bar

EXAM SCHEDULING:
1. Complete all required coursework
2. Go to "My Certifications"
3. Click "Schedule Exam"
4. Choose online proctored or testing center
5. Select your preferred date and time
6. Complete identity verification

TECHNICAL REQUIREMENTS FOR ONLINE EXAM:
- Stable internet connection (3+ Mbps)
- Webcam and microphone
- Chrome browser with PSI Secure Browser extension
- Quiet, private room with clean desk
- Valid government-issued photo ID

MOBILE ACCESS:
Download the NASM app for iOS or Android to:
- Study on the go
- Access flashcards
- Take practice quizzes
- Track your progress

SUPPORT:
If you experience technical issues:
- Live chat available on NASM.org
- Email: support@nasm.org
- Phone: 1-800-460-NASM (Monday-Friday)$$,
'ACCOUNT', 'Accessing Materials', 'FAQ', 'login, course access, exam scheduling, technical support', 'ALL', '2024-01-01', CURRENT_TIMESTAMP(), TRUE, 40000, 3000, CURRENT_TIMESTAMP()),

('FAQ005', 'What payment options are available for NASM programs?',
$$NASM PAYMENT OPTIONS

PAYMENT METHODS ACCEPTED:
- Credit cards (Visa, Mastercard, Amex, Discover)
- Debit cards
- PayPal
- Affirm financing
- Apple Pay

AFFIRM FINANCING:
- Available for purchases over $150
- Split your payment into 3, 6, or 12 monthly installments
- Interest rates vary based on credit approval
- No hidden fees
- Soft credit check won't affect your credit score
- Apply at checkout

MILITARY DISCOUNT:
- Active duty, veterans, and dependents eligible
- 25% off all certification programs
- Verify eligibility through ID.me at checkout

EMPLOYER REIMBURSEMENT:
Many employers offer tuition reimbursement for professional development. NASM can provide:
- Invoice documentation
- Completion certificates
- CEU records

REFUND POLICY:
- Full refund within 30 days of purchase if no course access
- Partial refunds may be available for unused portions
- Exam fees are non-refundable after scheduling
- Contact support for refund requests

BUNDLE SAVINGS:
Save up to $500 by purchasing certification bundles:
- CPT All-Inclusive: Best value for new trainers
- Elite Trainer Bundle: CPT + CES + PES
- Specialization bundles: Add-on discounts for existing CPTs

FINANCIAL ASSISTANCE:
Contact NASM support to inquire about:
- Extended payment plans
- Scholarship opportunities
- Corporate pricing$$,
'BILLING', 'Payment Options', 'FAQ', 'payment, financing, refund, military discount, affirm', 'ALL', '2024-01-01', CURRENT_TIMESTAMP(), TRUE, 18000, 1400, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 8: Create Cortex Search Service for Student Reviews
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE STUDENT_REVIEWS_SEARCH
  ON review_text
  ATTRIBUTES student_id, certification_name, rating, review_source
  WAREHOUSE = NASM_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for student reviews - enables semantic search across student feedback'
AS
  SELECT
    review_id,
    review_text,
    review_title,
    student_id,
    certification_name,
    rating,
    review_source,
    review_date,
    helpful_votes
  FROM STUDENT_REVIEWS;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Course Content
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE COURSE_CONTENT_SEARCH
  ON content
  ATTRIBUTES certification_type_id, module_name, content_type, difficulty_level
  WAREHOUSE = NASM_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for course content - enables semantic search across training materials'
AS
  SELECT
    content_id,
    content,
    title,
    certification_type_id,
    module_name,
    content_type,
    topic_tags,
    difficulty_level
  FROM COURSE_CONTENT;

-- ============================================================================
-- Step 10: Create Cortex Search Service for FAQ Documents
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE FAQ_SEARCH
  ON content
  ATTRIBUTES category, topic, document_type, related_certification
  WAREHOUSE = NASM_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for FAQ documents - enables semantic search across help center content'
AS
  SELECT
    faq_id,
    content,
    title,
    category,
    topic,
    document_type,
    keywords,
    related_certification,
    view_count,
    helpful_count
  FROM FAQ_DOCUMENTS;

-- ============================================================================
-- Display data generation and search service completion summary
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status,
       (SELECT COUNT(*) FROM STUDENT_REVIEWS) AS student_reviews,
       (SELECT COUNT(*) FROM COURSE_CONTENT) AS course_content_docs,
       (SELECT COUNT(*) FROM FAQ_DOCUMENTS) AS faq_documents;

