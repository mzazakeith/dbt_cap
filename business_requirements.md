# Business Requirements: Monthly CHW Activity Aggregation

## Overview

The analytics team needs a monthly summary table showing Community Health Worker (CHW) performance. This table will power dashboards that track CHW productivity and help identify high/low performers.

---

## Source Data

**Source Table**: `marts.fct_chv_activity`

This fact table contains one row per CHW activity/visit with details about:
- Which CHW performed the activity
- When it occurred (date + timestamp)
- What type of activity (pregnancy visit, child assessment, family planning, etc.)
- Which household was visited
- Which patient was served

See `schema_documentation.md` for full column list.

---

## Output Requirements

### Target Model Name
`metrics.chw_activity_monthly`

### Grain (Uniqueness)
One row per **CHW per month**

### Primary Key
Composite: `(chw_id, report_month)`

---

## Metrics to Calculate

For each CHW for each month, calculate:

### 1. **Total Activities** (`total_activities`)
- **Definition**: Count of all activities performed by the CHW in that month
- **Notes**: Include all activity types

### 2. **Unique Households Visited** (`unique_households_visited`)
- **Definition**: Number of distinct households the CHW visited
- **Notes**: One household may be visited multiple times, count it once

### 3. **Unique Patients Served** (`unique_patients_served`)
- **Definition**: Number of distinct patients/individuals served
- **Notes**: Same patient may be seen multiple times, count once

### 4. **Pregnancy Visits** (`pregnancy_visits`)
- **Definition**: Count of activities where `activity_type = 'pregnancy_visit'`

### 5. **Child Assessments** (`child_assessments`)
- **Definition**: Count of activities where `activity_type = 'child_assessment'`

### 6. **Family Planning Visits** (`family_planning_visits`)
- **Definition**: Count of activities where `activity_type = 'family_planning'`

---

## Special Business Rules

###  Month Assignment Logic

**Rule**: Activities are NOT always assigned to the month they occurred in.

**Month Assignment Rule**:
- If `activity_date` is on or after the **26th of the month** → Assign to the **NEXT month**
- If `activity_date` is before the 26th → Assign to the **CURRENT month**

**Why?**: Field data collection for some regions often continues into the first days of the next month for the previous month's activities. This ensures activities are attributed to the correct reporting period.

**Examples**:
- Activity on 2025-01-15 → Assigned to **2025-01-01** (January)
- Activity on 2025-01-26 → Assigned to **2025-02-01** (February)
- Activity on 2025-01-31 → Assigned to **2025-02-01** (February)
- Activity on 2025-12-26 → Assigned to **2026-01-01** (January of next year)

**Implementation**:
You must create a macro called `month_assignment(date_column)` that implements this logic.

---

## Filters & Exclusions

### Include:
- All activity types
- All CHWs (even if they had zero activities that month - handled by dbt incremental)
- Activities from all regions

### Exclude:
- Rows where `activity_date` is NULL (these are invalid records)
- Rows where `is_deleted = TRUE` (soft-deleted records)
- Rows where `chv_id` is NULL (data quality issue)

---

## Performance Considerations

This table will be queried frequently by dashboards, so:

1. **Materialization**: Use incremental table (not view)
2. **Unique Key**: Set to `['chv_id', 'report_month']` to handle updates
3. **Incremental Strategy**: Use `delete+insert` to allow reprocessing of historical months if late data arrives

---

## Data Quality Requirements

The model must ensure:

1. **No Duplicates**: Each CHW-month combination appears exactly once
2. **No NULLs in Key Fields**: `chv_id` and `report_month` must never be NULL
3. **Logical Metrics**: All count metrics should be >= 0

Add appropriate dbt tests to verify these.

---

## Example Calculation

**Scenario**: CHW "CHV001" had the following activities in January 2025:

| activity_date | activity_type | household_id | patient_id |
|--------------|---------------|--------------|------------|
| 2025-01-05 | pregnancy_visit | HH001 | PAT001 |
| 2025-01-12 | child_assessment | HH002 | PAT002 |
| 2025-01-15 | pregnancy_visit | HH001 | PAT001 |
| 2025-01-28 | family_planning | HH003 | PAT003 |

**Expected Output Row**:

| chv_id | report_month | total_activities | unique_households_visited | unique_patients_served | pregnancy_visits | child_assessments | family_planning_visits |
|--------|--------------|------------------|---------------------------|------------------------|------------------|-------------------|------------------------|
| CHV001 | 2025-01-01 | 3 | 2 | 2 | 2 | 1 | 0 |
| CHV001 | 2025-02-01 | 1 | 1 | 1 | 0 | 0 | 1 |

**Note**: The 2025-01-28 activity is assigned to February because it's on/after the 26th

---

**Summary Checklist**:
- Aggregate by CHW and month
- Use special month assignment logic (26th cutoff)
- Calculate 6 metrics
- Exclude NULL dates, deleted records, NULL CHV IDs
- Ensure no duplicates
- Use incremental + delete+insert strategy
