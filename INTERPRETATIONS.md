## Q1 — Daily Business Summary with DoD and Same-Weekday WoW

**What the query does (1 sentence):** 
Builds a daily business summary : revenue, order count, AOV, paid/cancelled rates, refunds and layers on day-over-day and same-weekday week-over-week revenue deltas using window functions.

**Pattern choice (1–2 sentences):**
Two CTEs (daily_orders, daily_refunds) pre-aggregate before the join, avoiding double-counting refunds against multi-row order data. LAG(revenue, 1) and LAG(revenue, 7) in one pass give DoD and same-weekday WoW without a self-join, and the lag(7) choice (vs. just lag(1) repeated) correctly controls for weekday seasonality rather than comparing, say, a Saturday to a Friday.

**Business interpretation (2–3 sentences):** 
Revenue has collapsed across the window — daily average fell from ₹4.46M in March to ₹1.46M in June (a ~67% decline), with the last 7 days averaging ₹1.37M vs. ₹4.71M in the first 7 days. Separately, paid_order_rate sits at just ~9.8% on average (max 15.4%) — meaning over 90% of orders created never reach "paid" status, which is either a normal "orders start pending and get paid later" lifecycle or a significant leak depending on what other statuses exist. One day, 2026-05-13, has a cancelled_order_rate of 52.7% (vs. a ~5.6% average) paired with the lowest paid rate in the dataset (4.7%) — that's not noise, something broke that day (payment gateway outage, bad release, bulk test orders).

**What I'd ask next:**
- What does the full status distribution look like (pending/processing/failed/etc.) so "paid_order_rate" can be read in context rather than assumed to mean a 90% failure rate?
- What happened operationally on 2026-05-13?
- Is the March→June revenue decline a seasonal pattern (post-launch fade, fewer shopping days) or a sustained downtrend — and is 2026-06-14's 75 orders a real day or a partial/incomplete data pull, since it's an outlier even against the already-depressed June baseline?


## Q2 — Monthly Signup Cohort Retention

**What the query does (1 sentence):** 
Builds monthly signup cohorts and measures what fraction of each cohort placed a non-cancelled order in the 1st, 2nd, and 3rd month after signup.

**Pattern choice (1–2 sentences):**
Three separate LEFT JOINs (M1/M2/M3) against the same customer_activity CTE, each with a different interval offset, rather than a single join plus a date_diff/CASE pivot — it's readable for a fixed 3-month window but doesn't scale (every additional month needs another join + another count(distinct) column). Pre-filtering customer_activity to exclude cancelled orders is the right call — it means retention reflects real repeat purchases, not just repeat checkout attempts.

**Business interpretation (2–3 sentences):** 
 Cohort size also roughly doubled from March (1,664) to April (3,382) then flattened in May (3,461) before dropping in June (1,493) — the June drop is very likely the same partial-month artifact rather than a real signup collapse.
 
**What I'd ask next:**
- is the genuine March→April M1 drop (50%→43%) tied to the bigger acquisition volume (more signups but lower quality channel mix), or something product-side?


## Q3 — Funnel Conversion by Acquisition Channel

**What the query does (1 sentence):** 
Builds a product-view → ATC → checkout → purchase funnel by session, split by acquisition channel, restricted to sessions on or after 2026-04-19.

**Pattern choice (1–2 sentences):**
OUNT(DISTINCT session_id) FILTER (WHERE event_type = ...) across four stages in a single pass over session_events is the right call here — a 4-stage funnel via separate LEFT JOINs would multiply rows per session and risk double-counting, while this keeps it to one scan. COALESCE(sc.channel, 'direct') correctly buckets unmapped sessions instead of silently dropping them, though that bucket deserves scrutiny (see below).

**Business interpretation (2–3 sentences):** 
direct" has only 60 sessions (0.1% of total) and a 0% add-to-cart rate — not low, literally zero out of 60 — while every other channel shows ~40% view-to-cart.At the volume level, organic (39.7% of sessions) and paid (34.9%) are the two real revenue engines, jointly driving ~75% of the 13,824 purchases in this window.

**What I'd ask next:**
Is "direct" supposed to be a meaningful bucket (typed-URL/bookmark traffic) or is it a catch-all for failed attribution joins — and if the latter, how many real direct sessions are hiding inside "organic" or another channel instead?


## Q4 — Top Products by Net Revenue (After Refunds)

**What the query does (1 sentence):** 
Computes gross revenue, refunds, and net revenue per product by pre-aggregating order-level revenue, refunds, and returns separately before joining — answering the CFO's "which products actually make money net of returns."l.
 
**Pattern choice (1–2 sentences):**
 Three independently-aggregated CTEs (product_orders, order_refunds, order_returns) joined on order_id at the end, each already deduplicated to one row per order — matches the spec's pattern note exactly, and COALESCE(...,0) means every product gets a real number instead of NULL.

**Business interpretation (2–3 sentences):** 
Smartwatch and Headphones products own the top of the leaderboard — Eastlight Clarity ANC Headphones leads at ₹9.18L net revenue, with Smartwatch as the single biggest category overall at ₹62.8M net revenue, nearly double Headphones (₹39.9M) and Speakers (₹34.5M). Refund rates split sharply by category: Makeup (4.86%), Haircare (4.68%), Skincare (3.05%), and Accessories (3.06%) 

**What I'd ask next:**
- For those 11 negative-net-revenue products specifically, can we pull the actual order contents to confirm they co-occurred in multi-item orders with a separately-refunded item.


## Q5 — Category Health: Purchases → Returns

**What the query does (1 sentence):**
Aims to summarize category-level health — orders, units, revenue, and return rate — by joining order line items up to category and return line items up to category separately.

**Pattern choice (1–2 sentences):**
Two CTEs (category_sales, category_returns) joined in the final select. Returns aggregate via return_items → product_variants → products → categories. Note the join chain — going through product_variants is required because return_items references variants, not products.

**Business interpretation (2–3 sentences):** 
Smartwatch shows ₹8.01 billion in revenue and Headphones ₹5.74 billion, both wildly out of scale versus the ~₹300M total revenue implied by Q1's daily summary across the same period.

**What I'd ask next:**
- Can this be rebuilt so category_sales and category_returns are each pre-aggregated to one row per category before combining (e.g., two independent GROUP BY category_name CTEs joined together), rather than joining raw line-item rows on a non-unique column?


## Q6 — Payment Failure Analysis (Method × Top Error Code)

**What the query does (1 sentence):** 
- Builds a payment failure rate by method, then attaches each method's single most common error code and single most common error message as "top reason for failure."

**Pattern choice (1–2 sentences):**
DENSE_RANK() OVER (PARTITION BY method_name ORDER BY count DESC) to find the #1 error code and #1 error message is reasonable in isolation, but they're ranked in two separate CTEs and then stitched together by joining on method_name + rn=1 from each — this pairs the most frequent code with the most frequent message independently, not the message that actually co-occurred with that code. There's also a latent fragility: if any method has a tie for rn=1 in either ranking, the rn=1 join fans out into duplicate rows for that method (didn't happen here, but nothing prevents it).

**Business interpretation (2–3 sentences):** 
UPI has both the highest volume (12,801 attempts) and the highest failure rate (5.3%) — clearly the priority method to dig into — while the rest cluster tightly between 4.2–4.8%. One more thing worth a second look: COD shows a top error code of UPI_TIMEOUT, which is odd for a pay-on-delivery method with no online payment processing — possible mislabeling or a backup digital pre-auth flow that isn't obvious from the table names alone.

**What I'd ask next:**
- And separately — what does a COD payment_intent actually represent operationally (a pre-auth, a verification charge?), since "payment failure" on a cash-on-delivery method needs an explanation before it goes into a payments dashboard.


## Q7 — Delivery SLA Breach by Carrier × Shipping Method

**What the query does (1 sentence):** 
Calculates delivery time distribution (avg, median, p90) and a >5-day "late" rate for delivered shipments, broken out by carrier and shipping method.

**Pattern choice (1–2 sentences):**
ingle CTE joining carrier/method names and computing delivered_at::date - shipped_at::date once, then aggregating avg/median/p90 via percentile_cont and a SUM(CASE WHEN...) late-flag in one pass — clean and efficient.

**Business interpretation (2–3 sentences):** 
EcomExpress's late rate averages ~17.0% across methods vs. Bluedart's 8.6% and Delhivery's 5.8% — roughly 2–3x worse, consistent across all three shipping methods, which is a real and actionable signal.
 
**What I'd ask next:**
- Can the late threshold be parameterized per shipping_method (e.g., same_day SLA = 1 day, express = 2–3 days, standard = 5–7 days) rather than one flat cutoff, since right now the report can't actually tell us whether same-day delivery is working? 


## Q8 — Customer LTV + Bucket Share of Revenue

**What the query does (1 sentence):** 
Computes lifetime order count, revenue, AOV, and an LTV bucket per customer, then uses a window function to show what share of total revenue each LTV bucket represents.

**Pattern choice (1–2 sentences):**
case when for bucketing; bucket-share-of-revenue needs a window: sum(total_revenue) over (partition by ltv_bucket) / sum(total_revenue) over (). Mixing row-level and aggregate-level reasoning is a tier-up signal.

**Business interpretation (2–3 sentences):** 
The 20000+ bucket is 3,349 customers (39.7% of the visible base) but holds 88% of all revenue, while the bottom "0-999" bucket of one-time low-spend customers contributes essentially nothing (0.11% of revenue) — that's a legitimate power-law pattern, just measured against an understated denominator.

**What I'd ask next:**
- Should the cancelled filter move into the ON clause (LEFT JOIN orders o ON c.customer_id = o.customer_id AND lower(o.status) != 'cancelled') so zero-purchase and all-cancelled customers stay in the result with total_revenue = 0?

## Q9 — Repeat Purchase Interval

**What the query does (1 sentence):** 
Measures the time gap between a customer's consecutive orders using LEAD(), then summarizes the distribution (avg/median/p90) of those gaps across all repeat purchasers.

**Pattern choice (1–2 sentences):**
lead(created_at) over (partition by customer_id order by created_at). Filter out the last order per customer (next_order_date IS NULL) from the summary — including them biases the average toward infinity. You will also find a fat cluster of near-zero intervals: customers who split one shopping session into multiple orders minutes apart. Decide whether a same-day follow-up order counts as “coming back” (hint: a win-back email is irrelevant to it), compute the summary both ways, and document the choice — this single decision moves the median by days.

**Business interpretation (2–3 sentences):** 
Median time to repeat purchase is 6 days, but the mean is 10.58 days and P90 is 27 days — the gap distribution is heavily right-skewed, meaning most repeat customers come back within a week, but a meaningful tail takes nearly a month, and that tail is what's pulling the average up

**What I'd ask next:**
-  What's the actual repeat purchase rate — i.e., 3,418 out of how many total customers with a first order — so this gap metric has a denominator to sit alongside?

## Q10 — Attribution Comparison: First-Touch vs Last-Touch Revenue by Channel

**What the query does (1 sentence):** 
uilds first-touch and last-touch attribution models, assigning each order's revenue to the channel of the customer's earliest vs. most recent marketing touchpoint, then compares revenue share by channel across the two models.

**Pattern choice (1–2 sentences):**
Two ROW_NUMBER() windows (rn_first/rn_last) feeding two filtered CTEs unioned together is a clean way to compute both models in one query instead of two separate passes. But the windows are PARTITION BY customer_id, not PARTITION BY order_id

**Business interpretation (2–3 sentences):** 
Organic is the top channel under both models, holding a flat 40% share whether it's the first or last touch — it's equally strong at opening and closing the funnel. Paid is the clear second channel but skews toward opening: it holds 36% of first-touch revenue but drops to 34% on last-touch, suggesting paid does more to bring new traffic in than to close out the final purchase

**What I'd ask next:**
- Given paid and email lean toward opening the funnel while affiliate and direct lean toward closing it, would it make sense to set channel-specific KPIs — e.g., judge paid/email on new-customer reach rather than last-click ROAS, and judge affiliate/direct partly on their role in closing out journeys that started elsewhere?
