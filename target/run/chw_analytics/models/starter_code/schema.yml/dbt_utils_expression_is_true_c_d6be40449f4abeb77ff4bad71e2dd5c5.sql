
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from "chw_analytics"."marts_metrics"."chw_activity_monthly"

where not(pregnancy_visits >= 0)


  
  
      
    ) dbt_internal_test