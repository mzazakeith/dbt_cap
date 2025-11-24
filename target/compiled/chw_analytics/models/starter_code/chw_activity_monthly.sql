/*
Model: chw_activity_monthly
Description: Monthly aggregation of CHW activities for dashboard performance metrics

TODO: Complete this dbt model to aggregate CHW activities by month

Instructions:
1. Add the dbt config block (materialization, unique_key, incremental_strategy)
2. Filter out invalid records (NULL chv_id, NULL activity_date, deleted records)
3. Use the month_assignment macro to calculate report_month
4. Aggregate metrics: total_activities, unique_households_visited, unique_patients_served, pregnancy_visits, child_assessments, family_planning_visits
5. GROUP BY chv_id and report_month
6. Add incremental logic 
*/

-- ============================================
-- dbt Configuration
-- ============================================



-- ============================================
-- Main Query
-- ============================================

with source_data as (

    select
        activity_id,
        chv_id,
        activity_date,
        activity_type,
        household_id,
        patient_id,
        is_deleted,
        created_at,
        updated_at
    from "chw_analytics"."marts"."fct_chv_activity"

    where 1=1
        -- Filter out invalid records as per business requirements
        and chv_id is not null
        and activity_date is not null  
        and is_deleted = false


),

with_report_month as (

    select
        activity_id,
        chv_id,
        activity_date,
        activity_type,
        household_id,
        patient_id,
        -- Use the month_assignment macro to calculate report_month
        


    case 
        -- Activities on/after 26th go to next month
        when extract(day from activity_date) >= 26 then
            date_trunc('month', activity_date + interval '1 month')
        -- Activities before 26th stay in current month  
        else
            date_trunc('month', activity_date)
    end
    

 as report_month

    from source_data

),

aggregated as (

    select
        chv_id,
        report_month,
        -- Calculate all required metrics
        count(*) as total_activities,
        count(distinct household_id) as unique_households_visited,
        count(distinct patient_id) as unique_patients_served,
        count(case when activity_type = 'pregnancy_visit' then 1 end) as pregnancy_visits,
        count(case when activity_type = 'child_assessment' then 1 end) as child_assessments,
        count(case when activity_type = 'family_planning' then 1 end) as family_planning_visits

    from with_report_month
    group by chv_id, report_month

)

-- ============================================
-- Final Select with Incremental Logic
-- ============================================
select * from aggregated


    -- Only reprocess recent months where late-arriving data might appear
    -- This keeps the model performant while handling late data properly
    where report_month >= (
        select date_trunc('month', max(report_month) - interval '2 months')
        from "chw_analytics"."marts_metrics"."chw_activity_monthly"
    )
