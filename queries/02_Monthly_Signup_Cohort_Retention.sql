with customer_cohorts as (
select customer_id
, date_trunc('month', created_at) as cohort_month
from ecom.customers
)
, customer_activity as (
select distinct customer_id
,date_trunc('month', created_at) as activity_month
from ecom.orders
where lower(status) != 'cancelled'
order by customer_id
)
, cohort_table as (
select c.cohort_month
, count(distinct c.customer_id) as cohort_size
, count(distinct m1.customer_id) as m1_retained
, count(distinct m2.customer_id) as m2_retained
, count(distinct m3.customer_id) as m3_retained
from customer_cohorts c
left join customer_activity m1
on c.customer_id = m1.customer_id
and m1.activity_month = c.cohort_month + interval '1 Month'
left join customer_activity m2
on c.customer_id = m2.customer_id
and m2.activity_month =c.cohort_month + interval '2 month'
left join customer_activity m3
on c.customer_id = m3.customer_id
and m3.activity_month =
c.cohort_month + interval '3 month'
group by 1
order by 1
)

select *
, m1_retained::numeric/cohort_size::numeric as m1_retention_rate
, m2_retained::numeric/cohort_size::numeric as m2_retention_rate
, m3_retained::numeric/cohort_size::numeric as m3_retention_rate
from cohort_table
