## Inventory 
select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'ecom'
order by table_name, ordinal_position;
	
<img width="1320" height="6913" alt="image" src="https://github.com/user-attachments/assets/f0ac2bc1-06ab-493d-a652-ad3bbd1c31bf" />
