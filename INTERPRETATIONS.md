## Q1 — Daily Business Summary with DoD and Same-Weekday WoW

**What the query does (1 sentence):** 
Builds a daily business summary : revenue, order count, AOV, paid/cancelled rates, refunds and layers on day-over-day and same-weekday week-over-week revenue deltas using window functions.

**Pattern choice (1–2 sentences):**
Two CTEs (daily_orders, daily_refunds) pre-aggregate before the join, avoiding double-counting refunds against multi-row order data. LAG(revenue, 1) and LAG(revenue, 7) in one pass give DoD and same-weekday WoW without a self-join, and the lag(7) choice (vs. just lag(1) repeated) correctly controls for weekday seasonality rather than comparing, say, a Saturday to a Friday.

**Business interpretation (2–3 sentences):** 
evenue has collapsed across the window — daily average fell from ₹4.46M in March to ₹1.46M in June (a ~67% decline), with the last 7 days averaging ₹1.37M vs. ₹4.71M in the first 7 days. Separately, paid_order_rate sits at just ~9.8% on average (max 15.4%) — meaning over 90% of orders created never reach "paid" status, which is either a normal "orders start pending and get paid later" lifecycle or a significant leak depending on what other statuses exist. One day, 2026-05-13, has a cancelled_order_rate of 52.7% (vs. a ~5.6% average) paired with the lowest paid rate in the dataset (4.7%) — that's not noise, something broke that day (payment gateway outage, bad release, bulk test orders).

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




