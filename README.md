This repo contains 10 analytical SQL queries written against an e-commerce dataset (ecom schema), their raw outputs, and a structured interpretation of each — covering what the query computes, why it's written the way it is, what the numbers mean for the business, and what's still unresolved or worth a follow-up.

## Schema reference (tables referenced across queries)

ecom.orders, ecom.order_items, ecom.refunds, ecom.return_requests, ecom.return_items, ecom.customers, ecom.products, ecom.product_variants, ecom.categories, ecom.session_events, ecom.session_channels, ecom.attribution_touches, ecom.payment_intents, ecom.payment_methods, ecom.payment_transactions, ecom.shipments, ecom.shipping_carriers, ecom.shipping_methods

This analysis covers 10 SQL queries written against an e-commerce dataset, spanning:

- Revenue & growth: daily business performance with day-over-day and week-over-week trends
- Retention: monthly signup cohort retention
- Funnel: product-view → cart → checkout → purchase conversion by acquisition channel
- Product economics: top products by net revenue after refunds
- Category health: purchases vs. returns by category
- Payments: payment failure rates and top error reasons by method
- Logistics: delivery SLA breach by carrier and shipping method
- Customer value: LTV bucketing and revenue concentration
- Repeat behavior: time between a customer's consecutive orders
- Marketing attribution: first-touch vs. last-touch revenue by channel
