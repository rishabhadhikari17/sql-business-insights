with product_info as (
select p.product_id
, p.product_name
, c.category_name
, pv.variant_id
, oi.order_id
, qty
, unit_price
, line_total
from ecom.products p 
left JOIN
ecom.categories c
on p.category_id = c.category_id
left JOIN
ecom.product_variants pv
on p.product_id = pv.product_id
left join ecom.order_items oi
on pv.variant_id = oi.variant_id
order by oi.order_id
)

, product_refunds as (
select pi.product_id, pi.order_id, r.amount as refund_amount
from product_info pi 
left JOIN
ecom.refunds r
on pi.order_id = r.order_id
where lower(r.status) = 'succeeded'
)
, product_returns as (
select pi.product_id , pi.order_id , rr.return_id
from product_info pi 
left join 
ecom.return_requests rr
on pi.order_id = rr.order_id
where lower(rr.status) = 'approved'
)
, product_metrics as (
select pi.product_id
, pi.product_name
, pi.category_name
, pi.order_id
, pi.qty
, pi.qty*pi.unit_price as revenue
, ppr.return_id
, pr.refund_amount
from product_info pi 
left join product_refunds pr
on pi.order_id = pr.order_id
left join product_returns ppr
on pi.order_id = ppr.order_id
)

select
product_id
,product_name
,category_name
,sum(revenue) as gross_revenue
,count(DISTINCT order_id) as order_count
,sum(qty) as units_sold
,count(distinct return_id) as returns_count
,count(distinct return_id)::numeric/(count(DISTINCT order_id)) as return_rate
,max(refund_amount) as refund_amount
,sum(revenue)-max(refund_amount) as net_revenue
from product_metrics
group by 1,2,3
