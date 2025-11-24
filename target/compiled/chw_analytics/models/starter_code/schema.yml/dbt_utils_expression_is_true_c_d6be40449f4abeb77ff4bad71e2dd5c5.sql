



select
    1
from "chw_analytics"."marts_metrics"."chw_activity_monthly"

where not(pregnancy_visits >= 0)

