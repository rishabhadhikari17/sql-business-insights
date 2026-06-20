with customer_orders as (
select c.customer_id
, o.order_id
, o.created_at::date as order_date
, lead(o.created_at::date) over(partition by c.customer_id order by o.created_at::date asc) as next_order_date
from ecom.customers c 
join ecom.orders o 
on c.customer_id = o.customer_id
where lower(o.status) != 'cancelled'
)
, row_level_summary as (
select customer_id
, order_id
, order_date
, next_order_date
, next_order_date-order_date as days_to_next_order
from 
customer_orders
where order_date != next_order_date
and next_order_date is not null
)

select avg(days_to_next_order) as avg_days_to_next_order
, percentile_cont(0.5) within group (order by days_to_next_order) as median_days_to_next_order
, percentile_cont(0.9) within group (order by days_to_next_order) as p90_days_to_next_order
, count(distinct customer_id) as customers_with_repeat_order
from row_level_summary
