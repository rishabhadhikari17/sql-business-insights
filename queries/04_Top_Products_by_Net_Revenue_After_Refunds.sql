with product_orders as (
select
    p.product_id
    , p.product_name
    , c.category_name
    , oi.order_id
    , sum(oi.qty) as qty
    , sum(oi.qty * oi.unit_price) as line_revenue
from ecom.products p
left join ecom.categories c
    on p.category_id = c.category_id
left join ecom.product_variants pv
    on p.product_id = pv.product_id
left join ecom.order_items oi
    on pv.variant_id = oi.variant_id
group by 1,2,3,4
)

, order_totals as (
select
    order_id
    , sum(line_revenue) as order_revenue
from product_orders
group by 1
)

, order_refunds as (
select
    order_id
    , sum(amount) as refund_amount
from ecom.refunds
where lower(status) = 'succeeded'
group by 1
)

, order_returns as (
select
    order_id
    , count(distinct return_id) as return_count
from ecom.return_requests
where lower(status) = 'approved'
group by 1
)

, product_order_metrics as (
select
    po.*
    , ot.order_revenue
    , coalesce(ref.refund_amount, 0) as refund_amount
    , po.line_revenue
        / nullif(ot.order_revenue, 0)
        * coalesce(ref.refund_amount, 0) as allocated_refund
    , coalesce(orr.return_count, 0) as return_count
from product_orders po
left join order_totals ot
    on po.order_id = ot.order_id
left join order_refunds ref
    on po.order_id = ref.order_id
left join order_returns orr
    on po.order_id = orr.order_id
)

select
    product_id
    , product_name
    , category_name
    , sum(line_revenue) as gross_revenue
    , count(distinct order_id) as order_count
    , sum(qty) as units_sold
    , sum(return_count) as returns_count
    , sum(return_count)::numeric
        / nullif(count(distinct order_id), 0) as return_rate
    , round(sum(allocated_refund), 2) as refund_amount
    , round(
        sum(line_revenue) - sum(allocated_refund)
        , 2
    ) as net_revenue
from product_order_metrics
group by 1,2,3
order by net_revenue desc;


-- select * from ecom.order_items
-- select * from ecom.product_variants order by product_id
-- select * from ecom.products
-- select * from ecom.categories

-- with product_info as (
-- select p.product_id
-- , p.product_name
-- , c.category_name
-- , pv.variant_id
-- , oi.order_id
-- , qty
-- , unit_price
-- , line_total
-- from ecom.products p 
-- left JOIN
-- ecom.categories c
-- on p.category_id = c.category_id
-- left JOIN
-- ecom.product_variants pv
-- on p.product_id = pv.product_id
-- left join ecom.order_items oi
-- on pv.variant_id = oi.variant_id
-- order by oi.order_id
-- )

-- , product_refunds as (
-- select pi.product_id, pi.order_id, r.amount as refund_amount
-- from product_info pi 
-- left JOIN
-- ecom.refunds r
-- on pi.order_id = r.order_id
-- where lower(r.status) = 'succeeded'
-- )
-- , product_returns as (
-- select pi.product_id , pi.order_id , rr.return_id
-- from product_info pi 
-- left join 
-- ecom.return_requests rr
-- on pi.order_id = rr.order_id
-- where lower(rr.status) = 'approved'
-- )
-- , product_metrics as (
-- select pi.product_id
-- , pi.product_name
-- , pi.category_name
-- , pi.order_id
-- , pi.qty
-- , pi.qty*pi.unit_price as revenue
-- , ppr.return_id
-- , pr.refund_amount
-- from product_info pi 
-- left join product_refunds pr
-- on pi.order_id = pr.order_id
-- left join product_returns ppr
-- on pi.order_id = ppr.order_id
-- )

-- select
-- product_id
-- ,product_name
-- ,category_name
-- ,sum(revenue) as gross_revenue
-- ,count(DISTINCT order_id) as order_count
-- ,sum(qty) as units_sold
-- ,count(distinct return_id) as returns_count
-- ,count(distinct return_id)::numeric/(count(DISTINCT order_id)) as return_rate
-- ,max(refund_amount) as refund_amount
-- ,sum(revenue)-max(refund_amount) as net_revenue
-- from product_metrics
-- group by 1,2,3


-- with product_orders as (
--   select
--     p.product_id
--    ,p.product_name
--    ,c.category_name
--    ,oi.order_id
--    ,sum(oi.qty) as qty
--    ,sum(oi.qty * oi.unit_price) as line_revenue
--   from ecom.products p
--   left join ecom.categories c
--     on p.category_id = c.category_id
--   left join ecom.product_variants pv
--     on p.product_id = pv.product_id
--   left join ecom.order_items oi
--     on pv.variant_id = oi.variant_id
--   group by 1,2,3,4
-- )
-- , order_refunds as (
--   select
--     order_id
--    ,sum(amount) as refund_amount
--   from ecom.refunds
--   where lower(status) = 'succeeded'
--   group by 1
-- )
-- , order_returns as (
--   -- one row per order — count of approved returns for that order
--   select
--     order_id
--    ,count(distinct return_id) as return_count
--   from ecom.return_requests
--   where lower(status) = 'approved'
--   group by 1
-- )
-- select
--    po.product_id
--   ,po.product_name
--   ,po.category_name
--   ,sum(po.line_revenue) as gross_revenue
--   ,count(distinct po.order_id) as order_count
--   ,sum(po.qty) as units_sold
--   ,sum(coalesce(orr.return_count,0)) as returns_count
--   ,sum(coalesce(orr.return_count,0))::numeric / nullif(count(distinct po.order_id),0) as return_rate
--   ,sum(coalesce(ref.refund_amount,0)) as refund_amount
--   ,sum(po.line_revenue) - sum(coalesce(ref.refund_amount,0)) as net_revenue
-- from product_orders po
-- left join order_refunds ref
--   on po.order_id = ref.order_id
-- left join order_returns orr
--   on po.order_id = orr.order_id
-- group by 1,2,3
-- order by net_revenue desc

