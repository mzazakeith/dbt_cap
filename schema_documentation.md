# Schema Documentation

## Source Table: `marts.fct_chv_activity`

### Description
This is a fact table containing one row per CHW (Community Health Volunteer) activity/visit. Each row represents a single interaction between a CHW and a household/patient, including the type of service provided.

### Grain
One row per activity/visit

### Primary Key
`activity_id` (unique identifier for each activity)

---

## Column Definitions

| Column Name | Data Type | Nullable | Description | Example Values |
|------------|-----------|----------|-------------|----------------|
| `activity_id` | VARCHAR(50) | No | Unique identifier for the activity | "ACT_20250115_001" |
| `chv_id` | VARCHAR(50) | Yes* | Identifier for the CHW who performed the activity | "CHV001", "CHV042" |
| `activity_date` | DATE | Yes* | Date the activity occurred | 2025-01-15 |
| `activity_timestamp` | TIMESTAMP | Yes | Full timestamp of activity (if available) | 2025-01-15 14:30:00 |
| `activity_type` | VARCHAR(50) | No | Type of activity performed | "pregnancy_visit", "child_assessment", "family_planning", "household_registration" |
| `household_id` | VARCHAR(50) | Yes | Household that was visited | "HH_12345" |
| `patient_id` | VARCHAR(50) | Yes | Individual patient/client served (if applicable) | "PAT_67890" |
| `location_id` | VARCHAR(50) | Yes | Geographic location (village/area) | "LOC_BUSIA_01" |
| `is_deleted` | BOOLEAN | No | Soft delete flag (TRUE = record is deleted) | TRUE, FALSE |
| `created_at` | TIMESTAMP | No | When this record was created in the warehouse | 2025-01-16 08:00:00 |
| `updated_at` | TIMESTAMP | No | When this record was last updated | 2025-01-16 08:00:00 |

**\*Note**: These fields SHOULD NOT be NULL in valid records, but data quality issues mean some records have NULLs. Your code should filter these out.

---

## Activity Types

The `activity_type` column can contain:

| Activity Type | Description | Typical Frequency |
|--------------|-------------|-------------------|
| `pregnancy_visit` | ANC (Antenatal Care) visit or pregnancy follow-up | High |
| `child_assessment` | U5 (Under-5) child health assessment | High |
| `family_planning` | Family planning counseling or service | Medium |
| `household_registration` | Initial household registration | Low |
| `postnatal_visit` | PNC (Postnatal Care) visit | Medium |
| `nutrition_assessment` | Nutrition screening | Medium |
| `referral_followup` | Following up on facility referrals | Low |
| `other` | Other miscellaneous activities | Low |

---

## Data Quality Notes

### Known Issues:
1. **NULL chv_id**: ~1-2% of records have NULL `chv_id` (data entry errors). These should be excluded.
2. **NULL activity_date**: ~0.5% of records have NULL dates. These should be excluded.
3. **Deleted Records**: Records with `is_deleted = TRUE` should be excluded from analysis.
4. **Duplicate Activities**: Rare, but possible. The `activity_id` is unique, but the same visit might be recorded twice with different IDs.

### Cardinalities:
- **Total Records**: ~500K activities (and growing)
- **Unique CHVs**: ~500 active CHWs
- **Date Range**: 2023-01-01 to present
- **Activity Types**: 8 distinct types

---

## Related Dimension Tables (For Reference Only)

You don't need these for the current task, but they exist in the data model:

### `marts.dim_chv`
- **Description**: CHW master data (name, region, status, etc.)
- **Primary Key**: `chv_id`
- **Relationship**: `fct_chv_activity.chv_id` → `dim_chv.chv_id` (many-to-one)

### `marts.dim_household`
- **Description**: Household master data
- **Primary Key**: `household_id`
- **Relationship**: `fct_chv_activity.household_id` → `dim_household.household_id` (many-to-one)

### `marts.dim_patient`
- **Description**: Patient/individual master data
- **Primary Key**: `patient_id`
- **Relationship**: `fct_chv_activity.patient_id` → `dim_patient.patient_id` (many-to-one)

---

## Indexing & Performance

The source table has indexes on:
- `chv_id`
- `activity_date`
- `created_at`

These help with incremental model performance.

---

## Questions?

If you need clarification on any column, refer to `sample_data.sql` to see actual data examples.
