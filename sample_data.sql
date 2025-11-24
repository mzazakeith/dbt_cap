-- Sample Data from marts.fct_chv_activity
-- This shows what the source data looks like
-- You can use this to mentally test your logic

-- CHV001: Active CHW with mixed activities in January
INSERT INTO marts.fct_chv_activity VALUES
('ACT_001', 'CHV001', '2025-01-05', '2025-01-05 09:30:00', 'pregnancy_visit', 'HH001', 'PAT001', 'LOC_BUSIA_01', FALSE, '2025-01-06 08:00:00', '2025-01-06 08:00:00'),
('ACT_002', 'CHV001', '2025-01-05', '2025-01-05 11:00:00', 'pregnancy_visit', 'HH001', 'PAT001', 'LOC_BUSIA_01', FALSE, '2025-01-06 08:00:00', '2025-01-06 08:00:00'),  -- Same household/patient, different visit
('ACT_003', 'CHV001', '2025-01-12', '2025-01-12 10:15:00', 'child_assessment', 'HH002', 'PAT002', 'LOC_BUSIA_01', FALSE, '2025-01-13 08:00:00', '2025-01-13 08:00:00'),
('ACT_004', 'CHV001', '2025-01-15', '2025-01-15 14:20:00', 'pregnancy_visit', 'HH001', 'PAT001', 'LOC_BUSIA_01', FALSE, '2025-01-16 08:00:00', '2025-01-16 08:00:00'),
('ACT_005', 'CHV001', '2025-01-28', '2025-01-28 16:00:00', 'family_planning', 'HH003', 'PAT003', 'LOC_BUSIA_01', FALSE, '2025-01-29 08:00:00', '2025-01-29 08:00:00');  -- After 26th, goes to February!

-- CHV002: Another active CHW
INSERT INTO marts.fct_chv_activity VALUES
('ACT_006', 'CHV002', '2025-01-08', '2025-01-08 09:00:00', 'household_registration', 'HH004', NULL, 'LOC_BUSIA_02', FALSE, '2025-01-09 08:00:00', '2025-01-09 08:00:00'),  -- NULL patient_id is OK for registration
('ACT_007', 'CHV002', '2025-01-10', '2025-01-10 13:30:00', 'child_assessment', 'HH004', 'PAT004', 'LOC_BUSIA_02', FALSE, '2025-01-11 08:00:00', '2025-01-11 08:00:00'),
('ACT_008', 'CHV002', '2025-01-10', '2025-01-10 14:00:00', 'child_assessment', 'HH005', 'PAT005', 'LOC_BUSIA_02', FALSE, '2025-01-11 08:00:00', '2025-01-11 08:00:00'),  -- Same day, different household
('ACT_009', 'CHV002', '2025-01-27', '2025-01-27 11:00:00', 'pregnancy_visit', 'HH006', 'PAT006', 'LOC_BUSIA_02', FALSE, '2025-01-28 08:00:00', '2025-01-28 08:00:00');  -- After 26th, goes to February!

-- CHV003: Edge case - only activities after the 26th
INSERT INTO marts.fct_chv_activity VALUES
('ACT_010', 'CHV003', '2025-01-26', '2025-01-26 10:00:00', 'family_planning', 'HH007', 'PAT007', 'LOC_KISUMU_01', FALSE, '2025-01-27 08:00:00', '2025-01-27 08:00:00'),  -- Exactly on 26th, goes to February
('ACT_011', 'CHV003', '2025-01-31', '2025-01-31 15:00:00', 'family_planning', 'HH007', 'PAT007', 'LOC_KISUMU_01', FALSE, '2025-02-01 08:00:00', '2025-02-01 08:00:00');  -- Last day of month, goes to February

-- Data quality issues (should be filtered out):
INSERT INTO marts.fct_chv_activity VALUES
('ACT_012', NULL, '2025-01-20', '2025-01-20 10:00:00', 'pregnancy_visit', 'HH008', 'PAT008', 'LOC_BUSIA_03', FALSE, '2025-01-21 08:00:00', '2025-01-21 08:00:00'),  -- NULL chv_id - EXCLUDE THIS
('ACT_013', 'CHV004', NULL, NULL, 'child_assessment', 'HH009', 'PAT009', 'LOC_BUSIA_03', FALSE, '2025-01-21 08:00:00', '2025-01-21 08:00:00'),  -- NULL activity_date - EXCLUDE THIS
('ACT_014', 'CHV005', '2025-01-18', '2025-01-18 12:00:00', 'pregnancy_visit', 'HH010', 'PAT010', 'LOC_BUSIA_03', TRUE, '2025-01-19 08:00:00', '2025-01-19 08:00:00');  -- is_deleted = TRUE - EXCLUDE THIS

-- CHV with February activities (for incremental testing)
INSERT INTO marts.fct_chv_activity VALUES
('ACT_015', 'CHV001', '2025-02-05', '2025-02-05 10:00:00', 'pregnancy_visit', 'HH011', 'PAT011', 'LOC_BUSIA_01', FALSE, '2025-02-06 08:00:00', '2025-02-06 08:00:00'),
('ACT_016', 'CHV001', '2025-02-10', '2025-02-10 14:00:00', 'child_assessment', 'HH012', 'PAT012', 'LOC_BUSIA_01', FALSE, '2025-02-11 08:00:00', '2025-02-11 08:00:00');

-- Year boundary edge case (December → January next year)
INSERT INTO marts.fct_chv_activity VALUES
('ACT_017', 'CHV006', '2024-12-26', '2024-12-26 10:00:00', 'pregnancy_visit', 'HH013', 'PAT013', 'LOC_VIHIGA_01', FALSE, '2024-12-27 08:00:00', '2024-12-27 08:00:00'),  -- Goes to 2025-01!
('ACT_018', 'CHV006', '2024-12-31', '2024-12-31 16:00:00', 'child_assessment', 'HH013', 'PAT014', 'LOC_VIHIGA_01', FALSE, '2025-01-02 08:00:00', '2025-01-02 08:00:00');  -- Goes to 2025-01!

/*
SUMMARY OF SAMPLE DATA:

Valid Activities by CHV and Expected Report Month:
- CHV001: 3 activities in Jan (ACT_001-004), 1 in Feb (ACT_005), 2 more in Feb (ACT_015-016)
- CHV002: 3 activities in Jan (ACT_006-008), 1 in Feb (ACT_009)
- CHV003: 2 activities in Feb (ACT_010-011, both after 26th cutoff)
- CHV006: 2 activities in Jan 2025 (ACT_017-018, from Dec 2024 after 26th)

Records to EXCLUDE:
- ACT_012: NULL chv_id
- ACT_013: NULL activity_date
- ACT_014: is_deleted = TRUE

Key Testing Scenarios:
1. ✅ Same household visited multiple times (HH001 by CHV001)
2. ✅ Same patient seen multiple times (PAT001 by CHV001)
3. ✅ Activities on/after 26th assigned to next month (ACT_005, ACT_009-011, ACT_017-018)
4. ✅ NULL patient_id (ACT_006 - household registration)
5. ✅ Multiple activity types for one CHW
6. ✅ Year boundary (Dec 26+ → January next year)
7. ✅ Data quality issues (NULL chv_id, NULL date, deleted records)
*/
