with category_sales as (
select 
    c.category_name as category_name
    , count(distinct oi.order_id) as orders_with_category
    , sum(oi.qty) as units_sold
    , sum(oi.unit_price * oi.qty) as revenue
from ecom.order_items oi
join ecom.product_variants pv
    on oi.variant_id = pv.variant_id
join ecom.products p
    on pv.product_id = p.product_id
join ecom.categories c
    on p.category_id = c.category_id
group by 1
)

, category_returns as (
select
    c.category_name as category_name
    , count(distinct ri.return_id) as returns
from ecom.return_items ri
join ecom.product_variants pv
    on ri.variant_id = pv.variant_id
join ecom.products p
    on pv.product_id = p.product_id
join ecom.categories c
    on p.category_id = c.category_id
group by 1
)

select
    cs.category_name
    , cs.orders_with_category
    , cs.units_sold
    , cs.revenue
    , coalesce(cr.returns, 0) as returns
    , round(
        100.00 * coalesce(cr.returns, 0)
        / nullif(cs.orders_with_category, 0)
        , 2
    ) as return_rate_pct
from category_sales cs
left join category_returns cr
    on cs.category_name = cr.category_name
order by return_rate_pct desc;
