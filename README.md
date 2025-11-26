<img src="Snowflake_Logo.svg" width="200">

# NASM (National Academy of Sports Medicine) Intelligence Agent Solution

## About NASM

The National Academy of Sports Medicine (NASM) is a leading certification organization for fitness, wellness, and sports professionals. Founded in 1987, NASM provides industry-recognized certifications, continuing education, and career development programs for personal trainers, wellness coaches, and fitness specialists worldwide.

### Key Business Areas

- **Certifications**: Professional credentials for fitness industry careers
  - CPT (Certified Personal Trainer) - Flagship certification
  - CES (Corrective Exercise Specialist)
  - PES (Performance Enhancement Specialist)
  - FNS (Fitness Nutrition Specialist)
  - CNC (Certified Nutrition Coach)
  - WLS (Weight Loss Specialist)
  - GFS (Group Fitness Specialist)
  - YES (Youth Exercise Specialist)
- **Continuing Education**: CEU courses for recertification
- **Online Learning**: Self-paced digital courses and study materials
- **Live Events**: Workshops, conferences, and seminars
- **Career Services**: Job placement and career development resources

### Market Position

- One of the most recognized fitness certifications globally
- NCCA-accredited certification programs
- 500,000+ certified professionals worldwide
- Industry-leading Optimum Performance Training (OPT) model

## Project Overview

This Snowflake Intelligence solution demonstrates how NASM can leverage AI agents to analyze:

- **Student Intelligence**: Student profiles, enrollment patterns, progress tracking
- **Certification Analytics**: Exam pass rates, completion rates, certification trends
- **Revenue Operations**: Course sales, bundle performance, renewal rates
- **Continuing Education**: CEU completion, recertification compliance
- **Learning Analytics**: Course engagement, assessment performance, study patterns
- **Marketing Intelligence**: Campaign effectiveness, lead conversion, student acquisition
- **Customer Satisfaction**: Student feedback, NPS scores, support interactions
- **Unstructured Data Search**: Semantic search over course content, FAQs, and student feedback using Cortex Search

## Database Schema

The solution includes:

1. **RAW Schema**: Core business tables
   - STUDENTS: Student profiles and account information
   - CERTIFICATIONS: Available certification programs
   - CERTIFICATION_TYPES: Certification categories and requirements
   - ENROLLMENTS: Student course enrollments
   - EXAMS: Exam attempts and scores
   - CEU_COURSES: Continuing education course catalog
   - CEU_COMPLETIONS: Student CEU progress
   - ORDERS: Purchase transactions
   - ORDER_ITEMS: Individual course/product purchases
   - SUBSCRIPTIONS: Membership and subscription data
   - INSTRUCTORS: Course instructor profiles
   - SUPPORT_TICKETS: Customer support interactions
   - STUDENT_FEEDBACK: Satisfaction surveys and ratings
   - MARKETING_CAMPAIGNS: Campaign tracking
   - LEAD_INTERACTIONS: Lead and prospect data
   - COURSE_CONTENT: Course module information (unstructured)
   - FAQ_DOCUMENTS: Help center content (unstructured)
   - STUDENT_REVIEWS: Course reviews and testimonials (unstructured)

2. **ANALYTICS Schema**: Curated views and semantic models
   - Student 360 views
   - Certification analytics
   - Revenue metrics
   - Learning performance
   - Semantic views for AI agents

3. **Cortex Search Services**: Semantic search over unstructured data
   - STUDENT_REVIEWS_SEARCH: Search 10K student reviews
   - COURSE_CONTENT_SEARCH: Search course materials and descriptions
   - FAQ_SEARCH: Search help center and FAQ documents

## Files

### Core Files
- `README.md`: This comprehensive solution documentation
- `docs/AGENT_SETUP.md`: Complete agent configuration instructions
- `docs/questions.md`: 15 test questions (5 simple, 5 complex, 5 ML)

### SQL Files
- `sql/setup/01_database_and_schema.sql`: Database and schema creation
- `sql/setup/02_create_tables.sql`: Table definitions with proper constraints
- `sql/data/03_generate_synthetic_data.sql`: Realistic certification business sample data
- `sql/views/04_create_views.sql`: Analytical views
- `sql/views/05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `sql/search/06_create_cortex_search.sql`: Unstructured data tables and Cortex Search services
- `sql/ml/07_create_model_wrapper_functions.sql`: ML model wrapper procedures
- `sql/agent/08_create_intelligence_agent.sql`: Create Snowflake Intelligence Agent

### ML Models
- `notebooks/nasm_ml_models.ipynb`: Snowflake Notebook for training ML models

## Setup Instructions

### Quick Start (Simplified Agent - No ML)
```sql
-- Execute in order:
-- 1. Run sql/setup/01_database_and_schema.sql
-- 2. Run sql/setup/02_create_tables.sql
-- 3. Run sql/data/03_generate_synthetic_data.sql (10-20 min)
-- 4. Run sql/views/04_create_views.sql
-- 5. Run sql/views/05_create_semantic_views.sql
-- 6. Run sql/search/06_create_cortex_search.sql (5-10 min)
-- 7. Run sql/agent/08_create_intelligence_agent.sql
-- 8. Access agent in Snowsight: AI & ML > Agents > NASM_INTELLIGENCE_AGENT
```

### Complete Setup (Full Agent with ML)
```sql
-- Execute quick start steps 1-6, then:
-- 7. Upload and run notebooks/nasm_ml_models.ipynb in Snowflake
-- 8. Run sql/ml/07_create_model_wrapper_functions.sql
-- 9. Run sql/agent/08_create_intelligence_agent.sql
-- 10. Access agent in Snowsight: AI & ML > Agents > NASM_INTELLIGENCE_AGENT
```

### Detailed Instructions
- See **docs/AGENT_SETUP.md** for step-by-step configuration guide
- Test with questions from **docs/questions.md**

## Data Model Highlights

### Structured Data
- Realistic certification business scenarios
- 50K students with detailed profiles
- 100K enrollments with progress tracking
- 75K exam attempts with scores
- 150K CEU completions
- 200K orders with revenue data
- 30K support tickets
- 25K student feedback records
- 100K marketing interactions

### Unstructured Data
- 10,000 student reviews with sentiment variations
- Comprehensive course content documents
- FAQ and help center articles
- Semantic search powered by Snowflake Cortex Search
- RAG (Retrieval Augmented Generation) ready for AI agents

## Key Features

✅ **Hybrid Data Architecture**: Combines structured tables with unstructured content  
✅ **Semantic Search**: Find similar student issues and solutions by meaning, not keywords  
✅ **RAG-Ready**: Agent can retrieve context from reviews and course materials  
✅ **Production-Ready Syntax**: All SQL verified against Snowflake documentation  
✅ **Comprehensive Demo**: 50K students, 100K enrollments, 10K reviews  
✅ **Verified Syntax**: CREATE SEMANTIC VIEW and CREATE CORTEX SEARCH SERVICE syntax verified against official Snowflake documentation  
✅ **No Duplicate Synonyms**: All semantic view synonyms globally unique across all three views

## Sample Questions

The agent can answer sophisticated questions like:

### Structured Data Analysis (Semantic Views)
1. **Enrollment Analysis**: Certification enrollment trends by program and period
2. **Pass Rate Trends**: Exam performance analysis over time
3. **Student Segmentation**: Active vs lapsed students, recertification patterns
4. **Revenue Performance**: Course sales and bundle revenue
5. **CEU Completion**: Continuing education compliance rates
6. **Instructor Performance**: Course ratings by instructor
7. **Marketing ROI**: Campaign effectiveness and lead conversion

### Unstructured Data Search (Cortex Search)
8. **Student Reviews**: Common feedback patterns and sentiment
9. **Course Content**: Find specific training topics and materials
10. **FAQ Answers**: Policy guidance, recertification requirements

### ML Model Predictions
11. **Exam Success**: Predict likelihood of passing certification exam
12. **Churn Risk**: Identify students at risk of not recertifying
13. **Course Demand**: Forecast enrollment for upcoming periods

## Semantic Views

The solution includes three verified semantic views:

1. **SV_STUDENT_CERTIFICATION_INTELLIGENCE**: Comprehensive view of students, enrollments, exams, and certifications
2. **SV_REVENUE_OPERATIONS_INTELLIGENCE**: Orders, subscriptions, products, and revenue metrics
3. **SV_LEARNING_EXPERIENCE_INTELLIGENCE**: Course engagement, CEU completion, feedback, and support

All semantic views follow the verified syntax structure:
- TABLES clause with PRIMARY KEY definitions
- RELATIONSHIPS clause defining foreign keys
- DIMENSIONS clause with synonyms and comments
- METRICS clause with aggregations and calculations
- Proper clause ordering (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT)
- **NO DUPLICATE SYNONYMS** - All synonyms globally unique

## Cortex Search Services

Three Cortex Search services enable semantic search over unstructured data:

1. **STUDENT_REVIEWS_SEARCH**: Search 10,000 student reviews
   - Find similar student feedback and sentiment
   - Identify course quality patterns
   - Analyze satisfaction trends
   - Searchable attributes: student_id, certification_type, rating, review_date

2. **COURSE_CONTENT_SEARCH**: Search course materials
   - Retrieve training content and modules
   - Find specific exercise techniques or concepts
   - Access OPT model information
   - Searchable attributes: course_id, module_name, content_type

3. **FAQ_SEARCH**: Search FAQ and help documents
   - Find recertification requirements
   - Access policy information
   - Retrieve how-to guides
   - Searchable attributes: category, topic, document_type

## Syntax Verification

All SQL syntax has been verified against official Snowflake documentation:

- **CREATE SEMANTIC VIEW**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **CREATE CORTEX SEARCH SERVICE**: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
- **Cortex Search Overview**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview

Key verification points:
- ✅ Clause order is mandatory (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS)
- ✅ PRIMARY KEY columns verified to exist in source tables
- ✅ No self-referencing or cyclic relationships
- ✅ Semantic expression format: `name AS expression`
- ✅ Change tracking enabled for Cortex Search tables
- ✅ Correct ATTRIBUTES syntax for filterable columns
- ✅ All column references verified against table definitions
- ✅ No duplicate synonyms across all three semantic views

## Data Volumes

- **Students**: 50,000
- **Certification Types**: 15 programs
- **Enrollments**: 100,000
- **Exam Attempts**: 75,000
- **CEU Courses**: 200+ courses
- **CEU Completions**: 150,000
- **Orders**: 200,000
- **Support Tickets**: 30,000
- **Student Feedback**: 25,000
- **Marketing Campaigns**: 100
- **Lead Interactions**: 100,000
- **Student Reviews**: 10,000 (unstructured)
- **Course Content Docs**: 500+ modules
- **FAQ Documents**: 200+ articles

## Support

For questions or issues:
- Review `docs/AGENT_SETUP.md` for detailed setup instructions
- Check `docs/questions.md` for example questions
- Refer to Snowflake documentation for syntax verification
- Contact your Snowflake account team for assistance

## Version History

- **v1.0** (November 2025): Initial release
  - Verified semantic view syntax
  - Verified Cortex Search syntax
  - 50K students, 100K enrollments, 200K orders
  - 10K student reviews with semantic search
  - Course content and FAQ documents
  - 15 test questions (5 simple + 5 complex + 5 ML)
  - Comprehensive documentation

## License

This solution is provided as a template for building Snowflake Intelligence agents. Adapt as needed for your specific use case.

---

**Created**: November 2025  
**Snowflake Documentation**: Syntax verified against official documentation  
**Target Use Case**: NASM certification and education business intelligence

**NO GUESSING - ALL SYNTAX VERIFIED** ✅  
**NO DUPLICATE SYNONYMS - ALL GLOBALLY UNIQUE** ✅

