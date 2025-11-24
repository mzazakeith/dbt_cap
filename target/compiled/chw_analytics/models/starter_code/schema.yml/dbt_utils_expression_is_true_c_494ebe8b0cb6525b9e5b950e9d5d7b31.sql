



select
    1
from "chw_analytics"."marts_metrics"."chw_activity_monthly"

where not(family_planning_visits >= 0)

