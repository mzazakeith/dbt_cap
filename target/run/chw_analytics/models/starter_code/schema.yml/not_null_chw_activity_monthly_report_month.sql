
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select report_month
from "chw_analytics"."marts_metrics"."chw_activity_monthly"
where report_month is null



  
  
      
    ) dbt_internal_test