with first_orders as (
select
    customer_id
    , min(created_at::date) as first_order_date
from ecom.orders
where lower(status) != 'cancelled'
group by 1
)

, customer_cohorts as (
select
    c.customer_id
    , date_trunc(
        'month'
        , least(
            c.created_at::date
            , coalesce(f.first_order_date, c.created_at::date)
        )
    ) as cohort_month
from ecom.customers c
left join first_orders f
    on c.customer_id = f.customer_id
)

, customer_activity as (
select distinct
    customer_id
    , date_trunc('month', created_at) as activity_month
from ecom.orders
where lower(status) != 'cancelled'
)

, cohort_table as (
select
    c.cohort_month
    , count(distinct c.customer_id) as cohort_size
    , count(distinct m1.customer_id) as m1_retained
    , count(distinct m2.customer_id) as m2_retained
    , count(distinct m3.customer_id) as m3_retained
from customer_cohorts c
left join customer_activity m1
    on c.customer_id = m1.customer_id
    and m1.activity_month = c.cohort_month + interval '1 month'
left join customer_activity m2
    on c.customer_id = m2.customer_id
    and m2.activity_month = c.cohort_month + interval '2 month'
left join customer_activity m3
    on c.customer_id = m3.customer_id
    and m3.activity_month = c.cohort_month + interval '3 month'
group by 1
)

, max_month as (
select
    date_trunc('month', max(created_at)) as latest_month
from ecom.orders
)

select
    ct.*
    , case
        when ct.cohort_month + interval '1 month' <= mm.latest_month
            then round(ct.m1_retained::numeric / nullif(ct.cohort_size, 0), 4)
        else null
      end as m1_retention_rate
    , case
        when ct.cohort_month + interval '2 month' <= mm.latest_month
            then round(ct.m2_retained::numeric / nullif(ct.cohort_size, 0), 4)
        else null
      end as m2_retention_rate
    , case
        when ct.cohort_month + interval '3 month' <= mm.latest_month
            then round(ct.m3_retained::numeric / nullif(ct.cohort_size, 0), 4)
        else null
      end as m3_retention_rate
from cohort_table ct
cross join max_month mm
order by ct.cohort_month
;
