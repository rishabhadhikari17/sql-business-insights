with daily_orders as (
select 
date_trunc('day',created_at)::date as order_date
,sum(total) as revenue
, count(*) as orders
, sum(case when lower(status) = 'paid' then 1 else 0 end) as paid_orders
, sum(case when lower(status) = 'cancelled' then 1 else 0 end) as cancelled_orders
from ecom.orders
group by 1
)

, daily_refunds as (
select date_trunc('day',created_at)::date as order_date
,sum(amount) as refund_amount
from ecom.refunds
where lower(status) = 'succeeded'
group by 1
)

select d.order_date
,d.revenue
,d.orders
,1.0*d.revenue/nullif(d.orders,0) as aov
,1.0*d.paid_orders/nullif(d.orders,0) as paid_order_rate
,1.0*d.cancelled_orders/nullif(d.orders,0) as cancelled_order_rate
,r.refund_amount
,(d.revenue-lag(d.revenue,1) over(order by d.order_date))/nullif(lag(d.revenue,1) over(order by d.order_date),0) as revenue_vs_yesterday_pct
,(d.revenue-lag(d.revenue,7) over(order by d.order_date))/nullif(lag(d.revenue,7) over(order by d.order_date),0) as revenue_vs_weekly_pct
from daily_orders d 
left join daily_refunds r
on d.order_date = r.order_date
order by d.order_date asc
