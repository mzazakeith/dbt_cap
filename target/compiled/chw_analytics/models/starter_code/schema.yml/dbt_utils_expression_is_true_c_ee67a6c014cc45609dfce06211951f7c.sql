



select
    1
from "chw_analytics"."marts_metrics"."chw_activity_monthly"

where not(unique_patients_served >= 0)

