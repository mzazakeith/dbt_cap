



select
    1
from "chw_analytics"."marts_metrics"."chw_activity_monthly"

where not(unique_households_visited >= 0)

