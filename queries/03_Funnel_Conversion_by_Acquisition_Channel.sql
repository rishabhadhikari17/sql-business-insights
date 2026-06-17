with base_info as (
select se.session_id, coalesce(sc.channel,'direct') as channel
, se.event_type
, date_trunc('day',se.occurred_at)::date as event_date 
from ecom.session_events se
left join ecom.session_channels sc
on se.session_id = sc.session_id
where date_trunc('day',se.occurred_at)::date >= '2026-04-19'
)

, funnel as (
select
channel
,count(distinct session_id) as sessions
, count(distinct session_id) filter(where lower(event_type)= 'product_view') as product_view_sessions
, count(distinct session_id) filter(where lower(event_type)= 'add_to_cart') as add_to_cart_sessions
, count(distinct session_id) filter(where lower(event_type)= 'begin_checkout') as begin_checkout_sessions
, count(distinct session_id) filter(where lower(event_type)= 'purchase') as purchase_sessions
from base_info
group by 1
)

select *
, add_to_cart_sessions::numeric/nullif(product_view_sessions,0) as view_to_cart_rate
, begin_checkout_sessions::numeric/nullif(add_to_cart_sessions,0) as cart_to_checkout_rate
,purchase_sessions::numeric/nullif(begin_checkout_sessions,0) as checkout_to_purchase_rate
, purchase_sessions::numeric/nullif(sessions,0) as session_to_purchase_rate
from funnel
