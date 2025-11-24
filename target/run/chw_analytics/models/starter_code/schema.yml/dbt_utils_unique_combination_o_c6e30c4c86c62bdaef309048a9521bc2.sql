
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        chv_id, report_month
    from "chw_analytics"."marts_metrics"."chw_activity_monthly"
    group by chv_id, report_month
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test