## Inventory 
select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'ecom'
order by table_name, ordinal_position;
	
<img width="1320" height="6913" alt="image" src="https://github.com/user-attachments/assets/f0ac2bc1-06ab-493d-a652-ad3bbd1c31bf" />

## Row Counts
select relname as table_name, n_live_tup as approx_row_count
from pg_stat_user_tables
where schemaname = 'ecom'
order by n_live_tup desc;

<img width="412" height="1129" alt="image" src="https://github.com/user-attachments/assets/57f4fcd3-7990-4a09-a619-40dd2b4e79a6" />

## Columns Distribution
## Status Col
select lower(status), count(*) as n from ecom.orders group by 1 order by n desc;

<img width="292" height="336" alt="image" src="https://github.com/user-attachments/assets/d85fa165-5bb1-4687-88c3-89c61be8b55f" />

## Payment Method
with payment_id_distribution as (
select payment_method_id , count(*) as n from ecom.payment_intents
where status = 'succeeded'
group by 1 order by n desc
)

select method_name , n from ecom.payment_methods pm
join payment_id_distribution pd
on pm.payment_method_id = pd.payment_method_id

<img width="358" height="305" alt="image" src="https://github.com/user-attachments/assets/06172ca8-2c06-4257-9a91-f85a5aa5e803" />

## Attribution Channels
select channel , count(*) as n  from ecom.attribution_touches
group by 1
order by n desc

<img width="286" height="296" alt="image" src="https://github.com/user-attachments/assets/e9404dfc-bca3-4f4b-b388-98378e9e3789" />

## Country
select country , count(*) as n  from ecom.addresses
group by 1 
order by n desc

<img width="307" height="157" alt="image" src="https://github.com/user-attachments/assets/139bf199-05e1-43a0-a75e-76e97df7de59" />





