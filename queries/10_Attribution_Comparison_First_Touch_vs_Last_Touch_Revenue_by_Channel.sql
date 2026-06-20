with touches as (
select
o.order_id
,o.customer_id
,o.total as revenue
,at.touch_id
,at.touched_at
,coalesce(sc.channel,'direct') as channel
from ecom.orders o
left join ecom.attribution_touches at
on o.session_id = at.session_id
left join ecom.session_channels sc
on at.session_id = sc.session_id
where lower(o.status) != 'cancelled'
)
, attribution_models as (
select
*
,row_number() over(partition by customer_id order by touched_at asc) as rn_first
,row_number() over(partition by customer_id order by touched_at desc) as rn_last 
from touches
)
,first_touch as (
select
'first_touch' as attribution_model
,channel
,sum(revenue) as revenue
,count(distinct order_id) as orders
from attribution_models
where rn_first = 1
group by 1,2
)
,last_touch as (
select
'last_touch' as attribution_model
,channel
,sum(revenue) as revenue
,count(distinct order_id) as orders
from attribution_models
where rn_last = 1
group by 1,2
)
,all_models as (
select * from first_touch
union all
select * from last_touch
)
select
attribution_model
,channel
,revenue
,orders
,revenue::numeric/ sum(revenue) over(partition by attribution_model)as share_of_revenue
from all_models


