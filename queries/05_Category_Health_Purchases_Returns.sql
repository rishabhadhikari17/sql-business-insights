with category_sales as (
select oi.order_id 
, oi.variant_id 
, oi.qty
, oi.unit_price
, oi.line_discount
, oi.line_total
, c.category_name
from ecom.order_items oi
join ecom.product_variants pv
on oi.variant_id = pv.variant_id
join ecom.products p
on pv.product_id = p.product_id
join ecom.categories c
on p.category_id = c.category_id
) 
, category_returns as(
select ri.return_id
, c.category_name
from ecom.return_items ri
join ecom.product_variants pv
on ri.variant_id = pv.variant_id
join ecom.products p
on pv.product_id = p.product_id
join ecom.categories c 
on p.category_id = c.category_id
)
select cs.category_name
, count(distinct cs.order_id) as orders_with_category
, sum(cs.qty) as units_sold
, sum(cs.qty*cs.unit_price) as revenue
, count(distinct cr.return_id) as returns
, 100.00*(count(distinct cr.return_id)::numeric/count(distinct cs.order_id)::numeric) as return_rate
from category_sales cs
join category_returns cr
on cs.category_name= cr.category_name
group by 1
