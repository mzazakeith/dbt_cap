# Main Task: Monthly CHW Activity Aggregation Model

**Estimated Time: 40 minutes**

---

## Background

You're working on a health data analytics platform that tracks Community Health Worker (CHW) activities across multiple regions in Kenya. CHWs visit households to provide maternal health services, child health assessments, and family planning services.

The analytics team needs a monthly aggregated view of CHW performance to power their dashboards. Currently, they have a detailed fact table with every visit/activity, but they need monthly rollups for better performance and analysis.

---

## Your Task

Build a dbt model that aggregates CHW activity data by month and CHW, calculating key performance metrics.

---

## Deliverables

You need to create/complete **three files**:

### 1. **dbt Model**: `starter_code/chw_activity_monthly.sql`
   - Aggregate data from the fact table
   - Calculate required metrics
   - Use proper dbt incremental strategy
   - Add appropriate configurations

### 2. **Macro**: `macros/month_assignment.sql`
   - Implement the month assignment logic (see business requirements)
   - Make it reusable across models

### 3. **Tests & Documentation**: Create `schema.yml` in the same folder
   - Document the model and columns
   - Add data quality tests

---

## Files to Reference

Before you start coding, review these files:

1. **`business_requirements.md`** - What metrics to calculate and business rules
2. **`schema_documentation.md`** - Source table schemas and column descriptions
3. **`sample_data.sql`** - Sample data showing what the source tables contain
4. **`expected_output.md`** - What your final model output should look like

---

## Step-by-Step Approach

### Step 1: Understand the Requirements 
- Read `business_requirements.md` carefully
- Note the special month assignment rule (26th cutoff)
- Identify which source columns you need

### Step 2: Build the Macro 
- Open `macros/month_assignment.sql`
- Implement the month assignment logic
- Handle edge cases (NULL dates, year boundaries)

### Step 3: Complete the dbt Model 
- Open `starter_code/chw_activity_monthly.sql`
- Add proper dbt config block
- Write SQL to aggregate data
- Use your macro for month assignment
- Add GROUP BY and aggregation logic

### Step 4: Add Tests & Documentation 
- Create `schema.yml` file
- Document model purpose and columns
- Add at least 3 tests (not_null, unique, relationships, etc.)

---

## Technical Requirements

### dbt Model Configuration
Your model should:
- Materialize as an **incremental table**
- Use `delete+insert` incremental strategy
- Set `unique_key` to prevent duplicates
- Handle late-arriving data properly
- Be performant 

### SQL Quality
Your SQL should:
- Be readable and well-formatted
- Use CTEs (Common Table Expressions) for clarity
- Handle NULL values appropriately
-  Use the `ref()` function to reference source tables
- Comment complex logic

### Data Quality
Your solution should:
- Not create duplicates (same CHW + month appears once)
- Handle edge cases (NULL dates, deleted records, etc.)
- Include appropriate tests in schema.yml

---

## Hints & Tips

💡 **Month Assignment Logic**:  Activities on/after the 26th of a month are assigned to the NEXT month.

💡 **Incremental Strategy**: `delete+insert` is best when you need to handle late-arriving data or updates to historical records.

💡 **Window Functions**: You might need these for deduplication or ranking (though not required for basic solution).

💡 **Testing**: Think about what could go wrong. Duplicates? NULLs in key fields? Negative counts?

---

## Starter Code Provided

You'll find a skleton dbt model in `starter_code/chw_activity_monthly.sql`. It has:
- Basic structure
- Some starter SQL to build upon

You'll find a **macro template** in `macros/month_assignment.sql` with:
- Function signature

---

## When You're Done

1. Ensure all three files are complete
2. Review your code for obvious errors
3. Check that you've addressed all business requirements



