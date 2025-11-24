
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select chv_id
from "chw_analytics"."marts_metrics"."chw_activity_monthly"
where chv_id is null



  
  
      
    ) dbt_internal_test