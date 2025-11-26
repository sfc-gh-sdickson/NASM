<img src="../Snowflake_Logo.svg" width="200">

# NASM Intelligence Agent - Setup Guide

This document provides step-by-step instructions to set up and configure the NASM Intelligence Agent in Snowflake.

## Prerequisites

Before starting, ensure you have:

1. **Snowflake Account** with appropriate permissions:
   - ACCOUNTADMIN role (or equivalent for creating databases, warehouses, agents)
   - Access to Snowflake Cortex features (Cortex Analyst, Cortex Search)
   
2. **Snowflake Features Enabled**:
   - Snowflake Intelligence Agents (Private Preview or GA)
   - Cortex Analyst
   - Cortex Search
   - Model Registry

3. **Snowsight Access** for agent configuration and testing

---

## Step 1: Create Database and Warehouse

Run the database setup script to create the foundation:

```sql
-- Execute the setup script
-- File: sql/setup/01_database_and_schema.sql

CREATE DATABASE IF NOT EXISTS NASM_INTELLIGENCE;
USE DATABASE NASM_INTELLIGENCE;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

CREATE OR REPLACE WAREHOUSE NASM_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE NASM_WH;
```

**Expected Result:** Database, schemas, and warehouse created successfully.

---

## Step 2: Create Tables

Run the table creation script:

```sql
-- File: sql/setup/02_create_tables.sql

-- This creates all tables including:
-- STUDENTS, CERTIFICATION_TYPES, ENROLLMENTS, EXAMS, CERTIFICATIONS,
-- CEU_COURSES, CEU_COMPLETIONS, PRODUCTS, ORDERS, ORDER_ITEMS,
-- SUBSCRIPTIONS, INSTRUCTORS, SUPPORT_TICKETS, STUDENT_FEEDBACK,
-- MARKETING_CAMPAIGNS, LEAD_INTERACTIONS, STUDY_SESSIONS, PRACTICE_EXAMS
```

**Expected Result:** All tables created with proper primary/foreign key relationships.

---

## Step 3: Generate Synthetic Data

Run the data generation script:

```sql
-- File: sql/data/03_generate_synthetic_data.sql

-- This generates realistic certification business data including:
-- - 50,000 students
-- - 15 certification types
-- - 100,000 enrollments
-- - 75,000 exam attempts
-- - 150,000 CEU completions
-- - 200,000 orders
-- - And more...
```

**Expected Result:** All tables populated with synthetic data.

**Note:** This script may take 10-20 minutes to complete due to data volume.

---

## Step 4: Create Analytical Views

Run the views creation script:

```sql
-- File: sql/views/04_create_views.sql

-- Creates views for common analytics:
-- V_STUDENT_360, V_CERTIFICATION_ANALYTICS, V_MONTHLY_REVENUE, etc.
```

**Expected Result:** 10 analytical views created in the ANALYTICS schema.

---

## Step 5: Create Semantic Views

Run the semantic views script (critical for Cortex Analyst):

```sql
-- File: sql/views/05_create_semantic_views.sql

-- Creates 3 semantic views:
-- 1. SV_STUDENT_CERTIFICATION_INTELLIGENCE
-- 2. SV_REVENUE_OPERATIONS_INTELLIGENCE
-- 3. SV_LEARNING_EXPERIENCE_INTELLIGENCE
```

**Syntax Verification Notes:**
- Clause order: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
- All synonyms are globally unique across semantic views
- Verified against: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view

**Expected Result:** 3 semantic views created and ready for Cortex Analyst.

---

## Step 6: Set Up Cortex Search Services

Run the Cortex Search setup script:

```sql
-- File: sql/search/06_create_cortex_search.sql

-- Creates 3 tables for unstructured data:
-- STUDENT_REVIEWS, COURSE_CONTENT, FAQ_DOCUMENTS

-- Creates 3 Cortex Search services:
-- STUDENT_REVIEWS_SEARCH, COURSE_CONTENT_SEARCH, FAQ_SEARCH
```

**Syntax Verification Notes:**
- Change tracking enabled on all source tables
- Verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search

**Expected Result:** Unstructured data tables and Cortex Search services created.

**Note:** This script may take 5-10 minutes to complete.

---

## Step 7: Train and Register ML Models

Open the Snowflake Notebook and run all cells:

```
File: notebooks/nasm_ml_models.ipynb
```

This notebook trains and registers 3 ML models:

| Model Name | Type | Purpose |
|------------|------|---------|
| EXAM_SUCCESS_PREDICTOR | Random Forest Classifier | Predict exam pass likelihood |
| ENROLLMENT_DEMAND_FORECASTER | Linear Regression | Forecast enrollment demand |
| STUDENT_CHURN_PREDICTOR | Random Forest Classifier | Identify churn risk |

**Expected Result:** 3 models registered in the Model Registry.

---

## Step 8: Create Model Wrapper Functions

Run the wrapper functions script:

```sql
-- File: sql/ml/07_create_model_wrapper_functions.sql

-- Creates 3 stored procedures:
-- PREDICT_EXAM_SUCCESS(VARCHAR)
-- FORECAST_ENROLLMENT_DEMAND(INT)
-- PREDICT_STUDENT_CHURN(INT)
```

**Expected Result:** 3 stored procedures created to wrap ML models.

---

## Step 9: Create the Intelligence Agent

Run the agent creation script:

```sql
-- File: sql/agent/08_create_intelligence_agent.sql

-- This script:
-- 1. Grants required permissions
-- 2. Creates NASM_INTELLIGENCE_AGENT
-- 3. Configures all tools (Cortex Analyst, Cortex Search, ML Models)
```

**Expected Result:** Intelligence Agent created and configured.

---

## Step 10: Test the Agent

### Option A: Test in Snowsight

1. Navigate to **AI & ML → Agents**
2. Select **NASM_INTELLIGENCE_AGENT**
3. Click **Chat** to open the conversation interface
4. Try these sample questions:

**Structured Data (Cortex Analyst):**
```
What is the exam pass rate by certification type?
Show me total revenue by product category.
How many students are at risk of not recertifying?
```

**Unstructured Data (Cortex Search):**
```
Search student reviews for comments about the CPT exam.
Find FAQ information about recertification requirements.
Search course content about the OPT model.
```

**Predictive (ML Models):**
```
Predict exam success rates for CPT students.
Forecast enrollment demand for the next 3 months.
Identify students at risk of churning in 90 days.
```

### Option B: Test via SQL

```sql
-- Test agent invocation
SELECT SNOWFLAKE.CORTEX.AGENT(
    'NASM_INTELLIGENCE_AGENT',
    'What is the overall exam pass rate?'
);
```

---

## Troubleshooting

### Common Issues

1. **"Semantic view not found" error**
   - Ensure semantic views are created in ANALYTICS schema
   - Verify REFERENCES and SELECT grants on semantic views

2. **"Cortex Search service not responding"**
   - Check that change tracking is enabled on source tables
   - Verify the search service is in the RAW schema

3. **"ML model not found" error**
   - Run the notebook to register models
   - Verify models are visible in Model Registry

4. **Permission errors**
   - Ensure ACCOUNTADMIN role or equivalent
   - Run the GRANT statements in 08_create_intelligence_agent.sql

### Useful Diagnostic Commands

```sql
-- Check semantic views
SHOW SEMANTIC VIEWS IN SCHEMA NASM_INTELLIGENCE.ANALYTICS;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA NASM_INTELLIGENCE.RAW;

-- Check ML models
SHOW MODELS IN SCHEMA NASM_INTELLIGENCE.ANALYTICS;

-- Check agent status
SHOW AGENTS LIKE 'NASM_INTELLIGENCE_AGENT';
DESCRIBE AGENT NASM_INTELLIGENCE_AGENT;
```

---

## Granting Access to Other Users

To allow other users to interact with the agent:

```sql
-- Grant usage on the agent
GRANT USAGE ON AGENT NASM_INTELLIGENCE.ANALYTICS.NASM_INTELLIGENCE_AGENT 
TO ROLE <role_name>;

-- Grant usage on required objects
GRANT USAGE ON DATABASE NASM_INTELLIGENCE TO ROLE <role_name>;
GRANT USAGE ON SCHEMA NASM_INTELLIGENCE.ANALYTICS TO ROLE <role_name>;
GRANT USAGE ON SCHEMA NASM_INTELLIGENCE.RAW TO ROLE <role_name>;
GRANT USAGE ON WAREHOUSE NASM_WH TO ROLE <role_name>;
```

---

## Next Steps

1. **Customize the Agent**: Modify the agent specification in `08_create_intelligence_agent.sql` to add custom instructions or tools.

2. **Add More Data Sources**: Extend semantic views with additional tables or metrics.

3. **Enhance ML Models**: Retrain models with production data for better accuracy.

4. **Monitor Usage**: Track agent usage and performance through Snowflake Query History.

---

## Support

For issues with:
- **Snowflake Intelligence Agents**: Consult Snowflake documentation or support
- **This Demo Solution**: Review the files in the repository for additional context

**Documentation Links:**
- [Snowflake Intelligence Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Model Registry](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)

