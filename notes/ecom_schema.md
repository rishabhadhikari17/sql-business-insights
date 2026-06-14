## Inventory 
select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'ecom'
order by table_name, ordinal_position;

table_name	column_name	data_type	is_nullable	column_default
addresses	address_id	bigint	NO	nextval('ecom.addresses_address_id_seq'::regclass)
addresses	line1	text	YES	
addresses	line2	text	YES	
addresses	landmark	text	YES	
addresses	city	text	YES	
addresses	state	text	YES	
addresses	country	text	YES	
addresses	postal_code	text	YES	
addresses	latitude	numeric	YES	
addresses	longitude	numeric	YES	
attribution_campaigns	touch_id	bigint	NO	
attribution_campaigns	campaign_id	text	NO	
attribution_campaigns	ad_cost_attributed	numeric	YES	
attribution_touches	touch_id	bigint	NO	nextval('ecom.attribution_touches_touch_id_seq'::regclass)
attribution_touches	session_id	uuid	YES	
attribution_touches	touched_at	timestamp with time zone	NO	
attribution_touches	utm_source	text	YES	
attribution_touches	utm_medium	text	YES	
attribution_touches	utm_campaign	text	YES	
attribution_touches	utm_term	text	YES	
attribution_touches	utm_content	text	YES	
attribution_touches	channel	text	YES	
attribution_touches	referrer	text	YES	
brands	brand_id	bigint	NO	nextval('ecom.brands_brand_id_seq'::regclass)
brands	brand_name	text	NO	
categories	category_id	bigint	NO	nextval('ecom.categories_category_id_seq'::regclass)
categories	category_name	text	NO	
categories	parent_id	bigint	YES	
collection_products	collection_id	bigint	NO	
collection_products	product_id	bigint	NO	
collection_products	position	integer	YES	
collections	collection_id	bigint	NO	nextval('ecom.collections_collection_id_seq'::regclass)
collections	collection_name	text	NO	
collections	created_at	timestamp with time zone	NO	
consents	consent_id	bigint	NO	nextval('ecom.consents_consent_id_seq'::regclass)
consents	customer_id	bigint	YES	
consents	consent_type	text	NO	
consents	status	text	NO	
consents	updated_at	timestamp with time zone	NO	
coupons	coupon_id	bigint	NO	nextval('ecom.coupons_coupon_id_seq'::regclass)
coupons	code	text	NO	
coupons	discount_type	text	NO	
coupons	discount_value	numeric	NO	
coupons	max_uses	integer	YES	
coupons	max_uses_per_customer	integer	YES	
coupons	starts_at	timestamp with time zone	NO	
coupons	ends_at	timestamp with time zone	NO	
coupons	is_active	boolean	YES	true
customer_addresses	customer_id	bigint	NO	
customer_addresses	address_id	bigint	NO	
customer_addresses	address_type	text	NO	
customer_addresses	is_default	boolean	YES	false
customer_addresses	created_at	timestamp with time zone	NO	
customer_segments	segment_id	bigint	NO	nextval('ecom.customer_segments_segment_id_seq'::regclass)
customer_segments	segment_name	text	NO	
customers	customer_id	bigint	NO	nextval('ecom.customers_customer_id_seq'::regclass)
customers	created_at	timestamp with time zone	NO	
customers	first_name	text	YES	
customers	last_name	text	YES	
customers	dob	date	YES	
customers	gender	text	YES	
customers	primary_email	text	YES	
customers	primary_phone	text	YES	
customers	country	text	YES	
customers	state	text	YES	
customers	city	text	YES	
customers	is_email_verified	boolean	YES	false
customers	is_phone_verified	boolean	YES	false
customers	marketing_opt_in	boolean	YES	false
customers	lifecycle_stage	text	YES	
customers	acquisition_channel	text	YES	
customers	source	text	YES	
customers	utm_campaign	text	YES	
customers	utm_medium	text	YES	
customers	utm_source	text	YES	
devices	device_id	bigint	NO	nextval('ecom.devices_device_id_seq'::regclass)
devices	device_type	text	YES	
devices	os	text	YES	
devices	browser	text	YES	
devices	model	text	YES	
experiment_assignments	experiment_id	bigint	NO	
experiment_assignments	exp_variant_id	bigint	YES	
experiment_assignments	session_id	uuid	NO	
experiment_assignments	assigned_at	timestamp with time zone	NO	
experiment_assignments	customer_id	bigint	YES	
experiment_assignments	assignment_source	text	YES	
experiment_variants	variant_id	bigint	NO	nextval('ecom.experiment_variants_variant_id_seq'::regclass)
experiment_variants	experiment_id	bigint	YES	
experiment_variants	variant_name	text	NO	
experiment_variants	allocation_pct	numeric	YES	
experiment_variants	is_control	boolean	YES	
experiments	experiment_id	bigint	NO	nextval('ecom.experiments_experiment_id_seq'::regclass)
experiments	name	text	NO	
experiments	starts_at	timestamp with time zone	NO	
experiments	ends_at	timestamp with time zone	NO	
experiments	hypothesis	text	YES	
experiments	owner	text	YES	
experiments	status	text	YES	
experiments	primary_metric	text	YES	
inventory_items	warehouse_id	bigint	NO	
inventory_items	variant_id	bigint	NO	
inventory_items	on_hand	integer	NO	0
inventory_items	reserved	integer	NO	0
inventory_movements	movement_id	bigint	NO	nextval('ecom.inventory_movements_movement_id_seq'::regclass)
inventory_movements	movement_time	timestamp with time zone	NO	
inventory_movements	warehouse_id	bigint	YES	
inventory_movements	variant_id	bigint	YES	
inventory_movements	direction	text	NO	
inventory_movements	qty	integer	NO	
inventory_movements	reason	text	YES	
inventory_movements	reference	text	YES	
loyalty_accounts	customer_id	bigint	NO	
loyalty_accounts	created_at	timestamp with time zone	NO	
loyalty_accounts	tier	text	NO	
loyalty_transactions	loyalty_txn_id	bigint	NO	nextval('ecom.loyalty_transactions_loyalty_txn_id_seq'::regclass)
loyalty_transactions	customer_id	bigint	YES	
loyalty_transactions	txn_time	timestamp with time zone	NO	
loyalty_transactions	points_delta	integer	NO	
loyalty_transactions	reason	text	YES	
loyalty_transactions	order_id	bigint	YES	
marketing_campaigns	campaign_id	text	NO	
marketing_campaigns	name	text	NO	
marketing_campaigns	channel	text	NO	
marketing_campaigns	budget	numeric	YES	
marketing_campaigns	starts_at	timestamp with time zone	NO	
marketing_campaigns	ends_at	timestamp with time zone	NO	
marketing_campaigns	created_at	timestamp with time zone	NO	now()
notifications	notification_id	bigint	NO	nextval('ecom.notifications_notification_id_seq'::regclass)
notifications	customer_id	bigint	YES	
notifications	created_at	timestamp with time zone	NO	
notifications	channel	text	NO	
notifications	template	text	YES	
notifications	status	text	YES	
notifications	related_session_id	uuid	YES	
notifications	opened_at	timestamp with time zone	YES	
notifications	clicked_at	timestamp with time zone	YES	
order_items	order_id	bigint	NO	
order_items	variant_id	bigint	NO	
order_items	qty	integer	NO	
order_items	unit_price	numeric	NO	
order_items	line_discount	numeric	NO	0
order_items	line_total	numeric	NO	
order_refunds	order_id	bigint	YES	
order_refunds	refund_amount	numeric	YES	
order_status_history	order_id	bigint	NO	
order_status_history	status	text	NO	
order_status_history	changed_at	timestamp with time zone	NO	
order_status_history	reason	text	YES	
orders	order_id	bigint	NO	nextval('ecom.orders_order_id_seq'::regclass)
orders	order_number	text	NO	
orders	created_at	timestamp with time zone	NO	
orders	customer_id	bigint	YES	
orders	session_id	uuid	YES	
orders	cart_id	uuid	YES	
orders	price_list_id	bigint	YES	
orders	status	text	NO	
orders	subtotal	numeric	NO	
orders	discount	numeric	NO	0
orders	tax	numeric	NO	0
orders	shipping_fee	numeric	NO	0
orders	total	numeric	NO	
orders	payment_status	text	NO	
orders	shipping_address_id	bigint	YES	
orders	billing_address_id	bigint	YES	
orders	applied_coupon_id	bigint	YES	
orders	applied_promo_id	bigint	YES	
payment_intents	payment_intent_id	bigint	NO	nextval('ecom.payment_intents_payment_intent_id_seq'::regclass)
payment_intents	order_id	bigint	YES	
payment_intents	created_at	timestamp with time zone	NO	
payment_intents	payment_method_id	bigint	YES	
payment_intents	amount	numeric	NO	
payment_intents	status	text	NO	
payment_methods	payment_method_id	bigint	NO	nextval('ecom.payment_methods_payment_method_id_seq'::regclass)
payment_methods	method_name	text	NO	
payment_transactions	txn_id	bigint	NO	nextval('ecom.payment_transactions_txn_id_seq'::regclass)
payment_transactions	payment_intent_id	bigint	YES	
payment_transactions	txn_time	timestamp with time zone	NO	
payment_transactions	gateway	text	YES	
payment_transactions	status	text	NO	
payment_transactions	error_code	text	YES	
payment_transactions	error_message	text	YES	
price_lists	price_list_id	bigint	NO	nextval('ecom.price_lists_price_list_id_seq'::regclass)
price_lists	name	text	NO	
price_lists	currency	text	NO	
prices	price_list_id	bigint	NO	
prices	variant_id	bigint	NO	
prices	list_price	numeric	NO	
prices	sale_price	numeric	YES	
prices	valid_from	timestamp with time zone	NO	
prices	valid_to	timestamp with time zone	YES	
product_images	image_id	bigint	NO	nextval('ecom.product_images_image_id_seq'::regclass)
product_images	product_id	bigint	YES	
product_images	image_url	text	YES	
product_images	position	integer	YES	
product_reviews	review_id	bigint	NO	nextval('ecom.product_reviews_review_id_seq'::regclass)
product_reviews	customer_id	bigint	YES	
product_reviews	product_id	bigint	YES	
product_reviews	order_id	bigint	YES	
product_reviews	rating	integer	NO	
product_reviews	title	text	YES	
product_reviews	body	text	YES	
product_reviews	created_at	timestamp with time zone	NO	
product_variants	variant_id	bigint	NO	nextval('ecom.product_variants_variant_id_seq'::regclass)
product_variants	product_id	bigint	YES	
product_variants	sku	text	NO	
product_variants	color	text	YES	
product_variants	size	text	YES	
product_variants	attributes	jsonb	YES	
product_variants	is_active	boolean	YES	true
products	product_id	bigint	NO	nextval('ecom.products_product_id_seq'::regclass)
products	created_at	timestamp with time zone	NO	
products	product_name	text	NO	
products	brand_id	bigint	YES	
products	category_id	bigint	YES	
products	description	text	YES	
products	is_active	boolean	YES	true
promotion_rules	rule_id	bigint	NO	nextval('ecom.promotion_rules_rule_id_seq'::regclass)
promotion_rules	promo_id	bigint	YES	
promotion_rules	min_cart_value	numeric	YES	
promotion_rules	category_id	bigint	YES	
promotion_rules	product_id	bigint	YES	
promotions	promo_id	bigint	NO	nextval('ecom.promotions_promo_id_seq'::regclass)
promotions	promo_name	text	NO	
promotions	promo_type	text	NO	
promotions	discount_type	text	NO	
promotions	discount_value	numeric	NO	
promotions	starts_at	timestamp with time zone	NO	
promotions	ends_at	timestamp with time zone	NO	
promotions	is_active	boolean	YES	true
refunds	refund_id	bigint	NO	nextval('ecom.refunds_refund_id_seq'::regclass)
refunds	order_id	bigint	YES	
refunds	created_at	timestamp with time zone	NO	
refunds	amount	numeric	NO	
refunds	reason	text	YES	
refunds	status	text	NO	
return_items	return_id	bigint	NO	
return_items	variant_id	bigint	NO	
return_items	qty	integer	NO	
return_items	reason_id	bigint	YES	
return_reasons	reason_id	bigint	NO	nextval('ecom.return_reasons_reason_id_seq'::regclass)
return_reasons	reason_text	text	NO	
return_requests	return_id	bigint	NO	nextval('ecom.return_requests_return_id_seq'::regclass)
return_requests	order_id	bigint	YES	
return_requests	customer_id	bigint	YES	
return_requests	requested_at	timestamp with time zone	NO	
return_requests	status	text	NO	
segment_memberships	segment_id	bigint	NO	
segment_memberships	customer_id	bigint	NO	
segment_memberships	valid_from	timestamp with time zone	NO	
segment_memberships	valid_to	timestamp with time zone	YES	
session_channels	session_id	uuid	YES	
session_channels	channel	text	YES	
session_events	event_id	bigint	NO	
session_events	session_id	uuid	NO	
session_events	customer_id	bigint	YES	
session_events	event_type	text	NO	
session_events	occurred_at	timestamp with time zone	NO	
session_events	product_id	bigint	YES	
session_events	variant_id	bigint	YES	
session_events	quantity	integer	YES	
session_events	unit_price	numeric	YES	
session_events	order_id	bigint	YES	
sessions	session_id	uuid	NO	gen_random_uuid()
sessions	started_at	timestamp with time zone	NO	
sessions	ended_at	timestamp with time zone	YES	
sessions	customer_id	bigint	YES	
sessions	anonymous_id	uuid	YES	
sessions	device_id	bigint	YES	
sessions	ip_address	inet	YES	
sessions	country	text	YES	
sessions	region	text	YES	
sessions	city	text	YES	
sessions	landing_page	text	YES	
sessions	referrer	text	YES	
shipments	shipment_id	bigint	NO	nextval('ecom.shipments_shipment_id_seq'::regclass)
shipments	order_id	bigint	YES	
shipments	carrier_id	bigint	YES	
shipments	shipping_method_id	bigint	YES	
shipments	shipped_at	timestamp with time zone	YES	
shipments	delivered_at	timestamp with time zone	YES	
shipments	tracking_number	text	YES	
shipments	status	text	NO	
shipping_carriers	carrier_id	bigint	NO	nextval('ecom.shipping_carriers_carrier_id_seq'::regclass)
shipping_carriers	carrier_name	text	NO	
shipping_methods	shipping_method_id	bigint	NO	nextval('ecom.shipping_methods_shipping_method_id_seq'::regclass)
shipping_methods	method_name	text	NO	
shipping_methods	base_fee	numeric	NO	
<img width="1320" height="6913" alt="image" src="https://github.com/user-attachments/assets/f0ac2bc1-06ab-493d-a652-ad3bbd1c31bf" />
