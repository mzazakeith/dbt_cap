



select
    1
from "chw_analytics"."marts_metrics"."chw_activity_monthly"

where not(total_activities >= 0)

