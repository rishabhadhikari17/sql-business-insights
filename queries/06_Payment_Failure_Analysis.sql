with failure as (
select pm.method_name
, count(payment_intent_id) as attempts
, sum(case when lower(status)='failed' then 1 else 0 end) as failures
, sum(case when lower(status)='failed' then 1 else 0 end)::numeric/count(payment_intent_id)::numeric as failure_rate
from ecom.payment_intents pi
join ecom.payment_methods pm
on pi.payment_method_id = pm.payment_method_id
GROUP by 1
)
, error_codes as (
select pm.method_name 
, pt.error_code
, count(pt.error_code) as count_error_code
from ecom.payment_transactions pt
join ecom.payment_intents pi
on pt.payment_intent_id = pi.payment_intent_id
join ecom.payment_methods pm
on pi.payment_method_id = pm.payment_method_id
where lower(pt.status) = 'failed'
group by 1,2
)
, ranked_error_codes as (
select method_name
, error_code
, count_error_code
, dense_rank() over(partition by method_name order by count_error_code desc ) as rn
from error_codes
)
, error_messages as (
select pm.method_name 
, pt.error_message
, count(pt.error_message) as count_error_message
from ecom.payment_transactions pt
join ecom.payment_intents pi
on pt.payment_intent_id = pi.payment_intent_id
join ecom.payment_methods pm
on pi.payment_method_id = pm.payment_method_id
where lower(pt.status) = 'failed'
group by 1,2
)
, ranked_error_messages as ( 
select method_name
, error_message
, count_error_message
, dense_rank() over(partition by method_name order by count_error_message desc ) as rn
from error_messages
)
, errors_messages as (
select rc.method_name 
, rc.error_code
, rc.count_error_code
, rm.error_message
from ranked_error_codes rc JOIN
ranked_error_messages rm
on rc.method_name = rm.method_name and rc.rn=1 and rm.rn=1
)

select f.method_name
, f.attempts 
, f.failures 
, f.failure_rate
, em.error_code as top_error_code
, em.error_message as top_error_message
, em.count_error_code::numeric/f.failures::numeric as top_error_share_of_failures
from failure f
join errors_messages em
on f.method_name = em.method_name
