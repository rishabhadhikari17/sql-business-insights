with customers as (
select c.customer_id
, min(o.created_at::date) as first_order_date
, max(o.created_at::date) as last_order_date
, count(o.order_id) as total_orders
, sum(o.total) as total_revenue
from ecom.customers c
left join 
ecom.orders o
on c.customer_id = o.customer_id and lower(o.status) != 'cancelled'
group by 1
)
, customer_ltv as (
select customer_id
, first_order_date
, last_order_date
, total_orders
, total_revenue
, total_revenue::numeric/nullif(total_orders::numeric,0) as aov
, case  
		when total_revenue < 1000 then '0-999'    -- to handel total revenue like 999.[something]
		when total_revenue >= 1000 and total_revenue <5000 then '1000-4999'
		when total_revenue >= 5000 and total_revenue <20000 then '5000-19999'
		when total_revenue >=20000 then '20000+'
 end as ltv_bucket
 from customers
)
select *
, sum(total_revenue) over(partition by ltv_bucket)::numeric / sum(total_revenue) over() as ltv_share_of_bucket
from customer_ltv
