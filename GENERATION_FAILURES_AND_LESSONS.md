# AI Generation Failures and Lessons Learned

## Project: Fontainebleau Las Vegas Intelligence Agent / NASM Intelligence Agent
## Date: November 26, 2025

This document catalogs all AI generation failures during this project to prevent repeating them in future sessions.

---

## CRITICAL RULE: Snowflake SQL is NOT Generic SQL

**NEVER assume syntax from other databases works in Snowflake. ALWAYS verify against Snowflake SQL Reference.**

---

## Failure Category 1: Snowflake Function Constraints

### 1.1 UNIFORM() Function - Arguments Must Be Constants

**What I did wrong:**
```sql
-- WRONG: Column values as arguments
UNIFORM(0, res.nights, RANDOM())
UNIFORM(0, res.nights - 1, RANDOM())
UNIFORM(1, s.max_guests, RANDOM())
```

**What I should have done:**
```sql
-- CORRECT: Use MOD with RANDOM or LEAST with constant UNIFORM
MOD(ABS(RANDOM()), GREATEST(res.nights, 1))
LEAST(UNIFORM(1, 10, RANDOM()), s.max_guests)
```

**Rule:** `UNIFORM(min, max, generator)` - min and max MUST be constant literal values, not column references.

---

### 1.2 SEQ4() Function - Only Valid in GENERATOR Context

**What I did wrong:**
```sql
-- WRONG: SEQ4() in regular SELECT without GENERATOR
SELECT
    'LOY' || LPAD(SEQ4(), 10, '0') AS loyalty_id,
    ...
FROM GUESTS g
```

**What I should have done:**
```sql
-- CORRECT: Use ROW_NUMBER() for non-GENERATOR contexts
SELECT
    'LOY' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id), 10, '0') AS loyalty_id,
    ...
FROM GUESTS g

-- OR use SEQ4() only with GENERATOR
SELECT SEQ4() FROM TABLE(GENERATOR(ROWCOUNT => 100))
```

**Rule:** `SEQ4()` is ONLY valid when selecting from `TABLE(GENERATOR(...))`. For all other contexts, use `ROW_NUMBER() OVER (ORDER BY ...)`.

---

### 1.3 GENERATOR() Function - ROWCOUNT Must Be Constant

**What I did wrong (potential):**
```sql
-- WRONG: Variable rowcount
TABLE(GENERATOR(ROWCOUNT => some_variable))
```

**What I should have done:**
```sql
-- CORRECT: Constant rowcount
TABLE(GENERATOR(ROWCOUNT => 1000))
```

**Rule:** `GENERATOR(ROWCOUNT => n)` - n MUST be a constant integer literal.

---

## Failure Category 2: ML Model Wrapper Procedures

### 2.1 Changing Working Code When Not Asked

**What I did wrong:**
- User asked me to fix ONLY procedure 2 (FORECAST_ROOM_OCCUPANCY)
- I changed ALL THREE procedures, breaking procedures 1 and 3 that were working

**What I should have done:**
- Touch ONLY the code the user asked me to fix
- Leave working code completely untouched
- If I think other code needs changes, ASK first

**Rule:** Never modify working code unless explicitly asked. If you think something else needs fixing, ask the user first.

---

### 2.2 Data Type Mismatches with ML Models

**What I did wrong:**
```sql
-- WRONG: Cast to FLOAT when model expects INTEGER
MONTH(...)::FLOAT AS MONTH_NUM
```

**Error received:**
```
Data Validation Error in feature MONTH_NUM: Feature type DataType.INT8 is not met by column MONTH_NUM because of its original type DoubleType()
```

**What I should have done:**
1. Look at the EXACT training data query in the notebook
2. Match data types EXACTLY - if notebook uses `MONTH(x) AS month_num` (no cast), don't add a cast
3. Only cast columns that were cast in training

**Rule:** ML model input columns must have the EXACT same data types as the training data. Check the notebook training query and match it precisely.

---

### 2.3 Not Handling NULL Values

**What I did wrong:**
- Queries could return NULL values when no historical data matched
- Model cannot handle NULL inputs

**What I should have done:**
```sql
-- Use COALESCE with sensible defaults
COALESCE(AVG(column), default_value)::FLOAT AS column_name
```

**Rule:** Always use COALESCE to handle potential NULL values in ML model input queries.

---

## Failure Category 3: Process Failures

### 3.1 Not Verifying Before Committing

**What I did wrong:**
- Made changes and committed without verifying they would work
- Had to make multiple commits to fix errors

**What I should have done:**
1. Read the source data (notebook training code) carefully
2. Match column names, data types, and query structure exactly
3. Consider edge cases (NULL values, empty results)
4. Only then write the code

**Rule:** Verify correctness BEFORE making changes, not after.

---

### 3.2 Making Assumptions About Snowflake Syntax

**What I did wrong:**
- Assumed UNIFORM() worked like random functions in other databases
- Assumed SEQ4() was a general sequence generator

**What I should have done:**
- Look up every Snowflake-specific function in the documentation
- Verify syntax before using it
- Test understanding against official docs

**Rule:** Never assume. Always verify Snowflake syntax against official documentation.

---

## Verification Checklist for Future Sessions

Before declaring any Snowflake SQL ready:

### Data Generation Scripts
- [ ] All UNIFORM() calls use constant min/max values only
- [ ] All SEQ4() calls are within GENERATOR context only
- [ ] All GENERATOR() calls use constant ROWCOUNT only
- [ ] ARRAY_CONSTRUCT indices are within bounds
- [ ] All date functions use correct Snowflake syntax

### ML Model Wrappers
- [ ] Input column names match notebook training EXACTLY (case-sensitive)
- [ ] Input column data types match notebook training EXACTLY
- [ ] NULL values are handled with COALESCE
- [ ] Empty result sets are handled gracefully
- [ ] Only the requested procedure is modified

### Semantic Views
- [ ] Clause order is correct: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS
- [ ] All synonyms are globally unique
- [ ] Column references match actual table columns

### Cortex Search
- [ ] Change tracking is enabled on source tables
- [ ] ON clause specifies the searchable text column
- [ ] ATTRIBUTES lists metadata columns correctly

---

## Summary of Key Lessons

1. **Snowflake SQL ≠ Generic SQL** - Always verify syntax
2. **Don't touch working code** - Only fix what you're asked to fix
3. **Match ML training data exactly** - Column names, types, structure
4. **Handle edge cases** - NULLs, empty results, missing data
5. **Verify before committing** - Don't iterate with broken code
6. **Read the error messages** - They tell you exactly what's wrong

---

## Files Affected by These Failures

| File | Issues |
|------|--------|
| `sql/data/03_generate_synthetic_data.sql` | UNIFORM with column args, SEQ4 without GENERATOR, NULL in NOT NULL column |
| `sql/search/06_create_cortex_search.sql` | SEQ4 without GENERATOR |
| `sql/ml/07_create_model_wrapper_functions.sql` | Data type mismatches, NULL handling, modifying working code |
| `sql/views/05_create_semantic_views.sql` | 26 invalid identifiers - semantic_name/expression reversed |
| `notebooks/nasm_ml_models.ipynb` | Missing 2 of 3 models, pandas .show() error |

---

## Reference Links

- [Snowflake UNIFORM Function](https://docs.snowflake.com/en/sql-reference/functions/uniform)
- [Snowflake GENERATOR Function](https://docs.snowflake.com/en/sql-reference/functions/generator)
- [Snowflake SEQ Functions](https://docs.snowflake.com/en/sql-reference/functions/seq1)
- [Snowflake Model Registry](https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry/overview)
- [CREATE SEMANTIC VIEW](https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view)
- [CREATE CORTEX SEARCH SERVICE](https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search)

---

## NASM Project Specific Failures (November 26, 2025)

### 4.1 Semantic View Syntax - Expression vs Semantic Name Reversed

**What I did wrong:**
```sql
-- WRONG: Had the syntax backwards 26 times across 3 semantic views
students.current_occupation AS occupation
certification_types.certification_code AS cert_code
enrollments.is_exam_eligible AS exam_eligible
```

**Error received:**
```
SQL compilation error: error line 87 at position 35 invalid identifier 'OCCUPATION'
SQL compilation error: error line 106 at position 36 invalid identifier 'EXAM_ELIGIBLE'
```

**What I should have done:**
```sql
-- CORRECT: Syntax is table.semantic_name AS actual_column_expression
-- The expression AFTER "AS" must be the actual column name from the table
students.occupation AS current_occupation
certification_types.cert_code AS certification_code
enrollments.exam_eligible AS is_exam_eligible
```

**Rule:** In semantic view DIMENSIONS, the syntax is `table_alias.semantic_name AS sql_expression` where `sql_expression` MUST be an actual column name from the underlying table. The semantic_name is what users will see; the expression is the real column.

**Files affected:** `sql/views/05_create_semantic_views.sql` - 26 invalid identifiers fixed

---

### 4.2 NULL Result in Non-Nullable Column

**What I did wrong:**
```sql
-- WRONG: Inserting rows where expiry_date could be NULL
INSERT INTO RAW.CERTIFICATIONS (certification_id, ..., expiry_date, ...)
SELECT ... ex.certification_expiry_date AS expiry_date ...
FROM ... 
-- No filter to exclude NULL expiry dates
```

**Error received:**
```
DML operation to table CERTIFICATIONS failed on column EXPIRY_DATE with error: NULL result in a non-nullable column
```

**What I should have done:**
```sql
-- CORRECT: Filter out NULL values when inserting into NOT NULL columns
INSERT INTO RAW.CERTIFICATIONS (...)
SELECT ...
FROM ...
WHERE ex.certification_expiry_date IS NOT NULL  -- Add this filter
```

**Rule:** Before inserting data, check the table definition for NOT NULL constraints. Filter source data to exclude NULLs for those columns.

**Files affected:** `sql/data/03_generate_synthetic_data.sql`

---

### 4.3 Pandas DataFrame vs Snowpark DataFrame Methods

**What I did wrong:**
```python
# WRONG: Used Snowpark method on pandas DataFrame
models = reg.show_models()  # Returns pandas DataFrame
models.show()  # .show() is a Snowpark method, not pandas!
```

**Error received:**
```
AttributeError: 'DataFrame' object has no attribute 'show'
```

**What I should have done:**
```python
# CORRECT: Use pandas methods for pandas DataFrames
models = reg.show_models()  # Returns pandas DataFrame
print(models)  # Use print() or display() for pandas
# Or: models.head()
```

**Rule:** Know which library returns which DataFrame type:
- Snowpark DataFrames: use `.show()`, `.collect()`, `.to_pandas()`
- Pandas DataFrames: use `print()`, `.head()`, `.to_string()`
- `Registry.show_models()` returns pandas, NOT Snowpark

**Files affected:** `notebooks/nasm_ml_models.ipynb` Cell 16

---

### 4.4 Incomplete Work - Missing ML Models in Notebook

**What I did wrong:**
- Advertised 3 ML models in documentation
- Only created 1 model (EXAM_SUCCESS_PREDICTOR) in the notebook
- Left ENROLLMENT_DEMAND_FORECASTER and STUDENT_CHURN_PREDICTOR completely missing

**What I should have done:**
- Complete ALL advertised features before declaring done
- Cross-reference wrapper functions against notebook to verify all models exist
- Test that each model can be called by its wrapper

**Rule:** Before declaring work complete:
1. Count the items promised in documentation
2. Count the items actually implemented
3. Verify they match
4. Test each one works

**Files affected:** `notebooks/nasm_ml_models.ipynb` - Added 2 missing models

---

### 4.5 Not Cross-Referencing Generated Code Against Source Tables

**What I did wrong:**
- Generated semantic view dimension definitions without verifying column names
- Invented column names like `occupation`, `cert_code`, `ceu_course_name` that don't exist
- Had to fix the same file 3 times because I didn't do a comprehensive check

**What I should have done:**
```bash
# CORRECT: Extract ALL actual columns from table definitions FIRST
grep -E "^\s+[a-z_]+ (VARCHAR|NUMBER|BOOLEAN|DATE|TIMESTAMP)" sql/setup/02_create_tables.sql

# THEN verify EVERY expression in semantic views against that list
for expr in $(grep -oE " AS [a-z_]+$" semantic_views.sql); do
  # Check if expr exists in actual columns
done
```

**Rule:** When generating code that references table columns:
1. FIRST extract the complete list of actual column names from table definitions
2. THEN write code that ONLY uses those exact column names
3. VERIFY every column reference before committing
4. Do ONE comprehensive check, not multiple partial fixes

---

### 4.6 Redundant Directory Structure

**What I did wrong:**
- Created `/Users/sdickson/NASM/NASM/` nested directory structure
- Put all files one level too deep

**What I should have done:**
- Verify target directory structure before creating files
- Use the workspace root directly, not a subdirectory with the same name

**Rule:** Before creating project structure, confirm the intended root directory with the user.

---

## Updated Verification Checklist

### Semantic Views (EXPANDED)
- [ ] Clause order: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS
- [ ] All synonyms are globally unique
- [ ] **DIMENSION syntax: `table.semantic_name AS actual_column_name`**
- [ ] **Every expression (after AS) exists as actual column in source table**
- [ ] Run comprehensive validation: extract all columns, verify all expressions

### Notebooks
- [ ] All advertised models are actually created
- [ ] Model count in notebook matches wrapper function count
- [ ] Pandas vs Snowpark DataFrame methods are correct
- [ ] `reg.show_models()` returns pandas - use `print()` not `.show()`

### Data Generation
- [ ] NOT NULL columns have filters to exclude NULL source data
- [ ] Check table constraints before INSERT statements

