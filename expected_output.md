# Expected Output

## What Your Model Should Produce

When you run `dbt run --select chw_activity_monthly`, your model should produce a table that looks like this:

---

## Sample Output Rows

Based on the sample data in `sample_data.sql`, your model should produce these rows:

| chv_id | report_month | total_activities | unique_households_visited | unique_patients_served | pregnancy_visits | child_assessments | family_planning_visits |
|--------|--------------|------------------|---------------------------|------------------------|------------------|-------------------|------------------------|
| CHV001 | 2025-01-01   | 3                | 2                         | 2                      | 3                | 1                 | 0                      |
| CHV001 | 2025-02-01   | 3                | 3                         | 3                      | 1                | 1                 | 1                      |
| CHV002 | 2025-01-01   | 3                | 2                         | 2                      | 0                | 2                 | 0                      |
| CHV002 | 2025-02-01   | 1                | 1                         | 1                      | 1                | 0                 | 0                      |
| CHV003 | 2025-02-01   | 2                | 1                         | 1                      | 0                | 0                 | 2                      |
| CHV006 | 2025-01-01   | 2                | 1                         | 2                      | 1                | 1                 | 0                      |

---

## Detailed Breakdown by CHV

### CHV001 - January 2025 (report_month = 2025-01-01)
**Activities included**: ACT_001, ACT_002, ACT_003, ACT_004 (all before Jan 26)

- `total_activities` = **3**
  - Why not 4? ACT_001 and ACT_002 are on same day to same household/patient, but still count separately (4 total, but let me recalculate...)
  - Actually: ACT_001, ACT_002, ACT_003, ACT_004 = 4 activities
  - **CORRECTION: total_activities = 4** (not 3!)

Let me recalculate correctly:

**Corrected breakdown:**

### CHV001 - January 2025
Activities: ACT_001 (Jan 5), ACT_002 (Jan 5), ACT_003 (Jan 12), ACT_004 (Jan 15)
- `total_activities` = **4**
- `unique_households_visited` = **2** (HH001, HH002)
- `unique_patients_served` = **2** (PAT001, PAT002)
- `pregnancy_visits` = **3** (ACT_001, ACT_002, ACT_004)
- `child_assessments` = **1** (ACT_003)
- `family_planning_visits` = **0**

### CHV001 - February 2025
Activities: ACT_005 (Jan 28 → Feb), ACT_015 (Feb 5), ACT_016 (Feb 10)
- `total_activities` = **3**
- `unique_households_visited` = **3** (HH003, HH011, HH012)
- `unique_patients_served` = **3** (PAT003, PAT011, PAT012)
- `pregnancy_visits` = **1** (ACT_015)
- `child_assessments` = **1** (ACT_016)
- `family_planning_visits` = **1** (ACT_005)

### CHV002 - January 2025
Activities: ACT_006 (Jan 8), ACT_007 (Jan 10), ACT_008 (Jan 10)
- `total_activities` = **3**
- `unique_households_visited` = **2** (HH004, HH005)
- `unique_patients_served` = **2** (PAT004, PAT005) - Note: HH registration has NULL patient, so it doesn't count
  - **CORRECTION**: COUNT(DISTINCT patient_id) with NULL patient means 2 unique (PAT004, PAT005)
- `pregnancy_visits` = **0**
- `child_assessments` = **2** (ACT_007, ACT_008)
- `family_planning_visits` = **0**

### CHV002 - February 2025
Activities: ACT_009 (Jan 27 → Feb)
- `total_activities` = **1**
- `unique_households_visited` = **1** (HH006)
- `unique_patients_served` = **1** (PAT006)
- `pregnancy_visits` = **1** (ACT_009)
- `child_assessments` = **0**
- `family_planning_visits` = **0**

### CHV003 - February 2025
Activities: ACT_010 (Jan 26 → Feb), ACT_011 (Jan 31 → Feb)
- `total_activities` = **2**
- `unique_households_visited` = **1** (HH007, visited twice but count once)
- `unique_patients_served` = **1** (PAT007, same patient)
- `pregnancy_visits` = **0**
- `child_assessments` = **0**
- `family_planning_visits` = **2** (ACT_010, ACT_011)

### CHV006 - January 2025
Activities: ACT_017 (Dec 26 2024 → Jan 2025), ACT_018 (Dec 31 2024 → Jan 2025)
- `total_activities` = **2**
- `unique_households_visited` = **1** (HH013)
- `unique_patients_served` = **2** (PAT013, PAT014)
- `pregnancy_visits` = **1** (ACT_017)
- `child_assessments` = **1** (ACT_018)
- `family_planning_visits` = **0**

---

## Corrected Expected Output Table

| chv_id | report_month | total_activities | unique_households_visited | unique_patients_served | pregnancy_visits | child_assessments | family_planning_visits |
|--------|--------------|------------------|---------------------------|------------------------|------------------|-------------------|------------------------|
| CHV001 | 2025-01-01   | 4                | 2                         | 2                      | 3                | 1                 | 0                      |
| CHV001 | 2025-02-01   | 3                | 3                         | 3                      | 1                | 1                 | 1                      |
| CHV002 | 2025-01-01   | 3                | 2                         | 2                      | 0                | 2                 | 0                      |
| CHV002 | 2025-02-01   | 1                | 1                         | 1                      | 1                | 0                 | 0                      |
| CHV003 | 2025-02-01   | 2                | 1                         | 1                      | 0                | 0                 | 2                      |
| CHV006 | 2025-01-01   | 2                | 1                         | 2                      | 1                | 1                 | 0                      |

---

## How to Verify Your Output

1. **Row count**: Should have 6 rows (6 CHV-month combinations)
2. **No NULLs**: No NULL values in `chv_id` or `report_month`
3. **No duplicates**: Each (chv_id, report_month) appears exactly once
4. **Month assignment**: Activities on/after 26th are in the NEXT month
5. **Metric totals**: Sum of activity type columns should equal `total_activities` for each row
6. **Excluded records**: ACT_012, ACT_013, ACT_014 should NOT appear in any aggregation

---

## Column Descriptions

- **chv_id**: Unique identifier for the CHW
- **report_month**: First day of the reporting month (DATE format: YYYY-MM-01)
- **total_activities**: Total number of activities performed by this CHW in this month
- **unique_households_visited**: Number of distinct households visited (one household counted once even if visited multiple times)
- **unique_patients_served**: Number of distinct patients served (NULLs are ignored in DISTINCT count)
- **pregnancy_visits**: Count of `activity_type = 'pregnancy_visit'`
- **child_assessments**: Count of `activity_type = 'child_assessment'`
- **family_planning_visits**: Count of `activity_type = 'family_planning'`

---

## Data Types

Your model should produce these data types:

```sql
chv_id                       VARCHAR(50)
report_month                 DATE
total_activities             INTEGER
unique_households_visited    INTEGER
unique_patients_served       INTEGER
pregnancy_visits             INTEGER
child_assessments            INTEGER
family_planning_visits       INTEGER
```

---

## Testing Your Work

If you have time, you can mentally test your SQL:

1. **For CHV001 in January**: Should find 4 activities (ACT_001-004)
2. **For CHV001 in February**: Should find 3 activities (ACT_005, ACT_015, ACT_016)
3. **Check month assignment**: ACT_005 (Jan 28) should appear in CHV001's February row
4. **Check deduplication**: HH001 visited 3 times by CHV001 in Jan, but counted once in `unique_households_visited`

---

