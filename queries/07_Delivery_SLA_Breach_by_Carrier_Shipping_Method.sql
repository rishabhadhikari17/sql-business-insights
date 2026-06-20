with delivery_info as(
select s.*
,sc.carrier_name as carrier_name
,sm.method_name as shipping_method
, delivered_at::date - shipped_at::date as delivery_days
from ecom.shipments s
join ecom.shipping_carriers sc
on s.carrier_id = sc.carrier_id
join ecom.shipping_methods sm 
on s.shipping_method_id = sm.shipping_method_id
where lower(status) = 'delivered'
)

select carrier_name
, shipping_method 
, count(status) as delivered_orders
, avg(delivery_days) as avg_delivery_days
, percentile_cont(0.5) within group (order by delivery_days) as median_delivery_days
, percentile_cont(0.9) within group (order by delivery_days) as p90_delivery_days
, sum(case when delivery_days>5 then 1 else 0 end) as late_deliveries
, sum(case when delivery_days >5 then 1 else 0 end)::numeric/count(status)::numeric as late_rate
from delivery_info
group by 1,2
