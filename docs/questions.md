# NASM Intelligence Agent - Test Questions

Use these 15 questions to test the NASM Intelligence Agent. The questions are organized by tool type and complexity.

---

## Simple Questions (Cortex Analyst - Semantic Views)

These questions test basic data retrieval from structured data sources.

### 1. Total Student Count
```
How many students are in the NASM system?
```
**Expected Tool:** StudentCertificationAnalyst  
**Expected Metric:** total_students from SV_STUDENT_CERTIFICATION_INTELLIGENCE

---

### 2. Certification Programs
```
List all certification programs with their prices.
```
**Expected Tool:** StudentCertificationAnalyst  
**Expected Data:** CERTIFICATION_TYPES with certification_name and base_price

---

### 3. Active Certifications
```
How many active certifications are there currently?
```
**Expected Tool:** StudentCertificationAnalyst  
**Expected Metric:** active_certifications filtered by status='ACTIVE'

---

### 4. Average Exam Score
```
What is the average exam score across all certification exams?
```
**Expected Tool:** StudentCertificationAnalyst  
**Expected Metric:** avg_exam_score from EXAMS

---

### 5. Top CEU Courses
```
What are the top 5 CEU courses by enrollment?
```
**Expected Tool:** LearningExperienceAnalyst  
**Expected Data:** CEU_COURSES ordered by total_enrollments DESC LIMIT 5

---

## Complex Questions (Cortex Analyst - Joins & Aggregations)

These questions test multi-table analysis and calculated metrics.

### 6. Exam Performance by Certification
```
Analyze exam pass rates by certification type. Show the certification name, total attempts, pass rate percentage, and average score for each.
```
**Expected Tool:** StudentCertificationAnalyst  
**Expected Analysis:** Join EXAMS with CERTIFICATION_TYPES, calculate pass rate

---

### 7. Revenue by Product Type
```
Compare revenue performance by product type. Show total orders, gross revenue, discounts, and net revenue for each product category.
```
**Expected Tool:** RevenueOperationsAnalyst  
**Expected Analysis:** Join ORDERS, ORDER_ITEMS, PRODUCTS; group by product_type

---

### 8. Student Engagement Trends
```
Show me student engagement metrics including average study progress, completion rates, and CEU credits earned over the past year.
```
**Expected Tool:** LearningExperienceAnalyst  
**Expected Metrics:** avg_study_progress, completion rates, total_ceus_earned

---

### 9. Recertification Pipeline
```
What is the recertification pipeline? Show certifications expiring in the next 90 days with their CEU completion status.
```
**Expected Tool:** StudentCertificationAnalyst  
**Expected Analysis:** Filter CERTIFICATIONS by expiry_date, join with CEU progress

---

### 10. Marketing ROI Analysis
```
Analyze marketing campaign ROI by channel. Show campaigns, conversions, revenue attributed, cost per acquisition, and ROI percentage for each channel.
```
**Expected Tool:** RevenueOperationsAnalyst  
**Expected Metrics:** From MARKETING_CAMPAIGNS grouped by campaign_channel

---

## Unstructured Search Questions (Cortex Search)

These questions test semantic search capabilities.

### 11. Student Reviews on CPT Exam
```
Search student reviews for feedback about the CPT certification exam experience.
```
**Expected Tool:** StudentReviewsSearch  
**Expected Source:** STUDENT_REVIEWS_SEARCH service

---

### 12. Recertification Information
```
Find FAQ information about recertification requirements and CEU credits.
```
**Expected Tool:** FAQSearch  
**Expected Source:** FAQ_SEARCH service

---

### 13. OPT Model Content
```
Search course content for information about the OPT model and how it's used in training.
```
**Expected Tool:** CourseContentSearch  
**Expected Source:** COURSE_CONTENT_SEARCH service

---

## ML Prediction Questions (Model Registry)

These questions test ML model inference capabilities.

### 14. Predict Exam Success
```
Predict exam success rates for students studying for the CPT certification.
```
**Expected Tool:** PredictExamSuccess  
**Expected Procedure:** PREDICT_EXAM_SUCCESS('CPT')  
**Expected Output:** Predicted pass rate, students analyzed, at-risk count

---

### 15. Enrollment Forecast
```
Forecast enrollment demand for the next 3 months.
```
**Expected Tool:** ForecastEnrollmentDemand  
**Expected Procedure:** FORECAST_ENROLLMENT_DEMAND(3)  
**Expected Output:** Predicted enrollment count for 3 months ahead

---

## Bonus ML Question

### 16. Churn Risk Identification
```
Identify students at risk of churning within the next 90 days.
```
**Expected Tool:** PredictStudentChurn  
**Expected Procedure:** PREDICT_STUDENT_CHURN(90)  
**Expected Output:** Students at churn risk, churn rate percentage

---

## Testing Guidance

### Success Criteria

For each question, verify:

1. **Correct Tool Selection**: Agent uses the appropriate tool (Cortex Analyst, Cortex Search, or ML procedure)

2. **Accurate Results**: Data returned matches expected metrics/content

3. **Proper Formatting**: Response is clear, concise, and well-organized

4. **Error Handling**: If a query fails, agent provides helpful error message

### Evaluation Template

```
Question: [Question text]
Tool Used: [Tool name]
SQL/Search Generated: [Yes/No/N/A]
Results Returned: [Yes/No]
Response Quality: [1-5]
Notes: [Any observations]
```

### Common Issues to Watch For

1. **Tool confusion**: Agent uses wrong tool for the question type
2. **Metric miscalculation**: Aggregations are incorrect
3. **Missing filters**: Query doesn't apply the right filters
4. **Search relevance**: Cortex Search results don't match query intent
5. **ML errors**: Model procedures fail due to missing data

---

## Quick Reference: Available Tools

| Tool | Type | Purpose |
|------|------|---------|
| StudentCertificationAnalyst | Cortex Analyst | Students, enrollments, exams, certifications |
| RevenueOperationsAnalyst | Cortex Analyst | Orders, products, subscriptions, marketing |
| LearningExperienceAnalyst | Cortex Analyst | CEU courses, completions, support, feedback |
| StudentReviewsSearch | Cortex Search | Student reviews and testimonials |
| CourseContentSearch | Cortex Search | Course materials and content |
| FAQSearch | Cortex Search | FAQ documents and policies |
| PredictExamSuccess | ML Procedure | Exam pass prediction |
| ForecastEnrollmentDemand | ML Procedure | Enrollment demand forecasting |
| PredictStudentChurn | ML Procedure | Churn risk identification |

