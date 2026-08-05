-- MONETIZATION
-- ============
-- KPI: LTV (Lifetime Value)
-- Cumulative revenue per installed user, by day since install.
-- Grain: one row per day_number, from 0 to the last day any user was active.

-- day_number is the number of days between a user's install date and the activity
-- date, so day 0 is install day. The denominator is the full cohort of installed
-- users, held constant: LTV is revenue per installed user, and a user who churned
-- on day 1 stays in the denominator forever.

-- All 26,576 users are treated as one cohort. They installed on different days, but
-- within a single 70 day window and with no installs after it, so the differences in
-- install date are small relative to the horizon being measured.

CREATE OR REPLACE TABLE `my-project-nitay.coin_master_project.cumulative_ltv` AS
WITH cohort AS (
  SELECT COUNT(DISTINCT uid) AS cohort_size
  FROM `my-project-nitay.coin_master_project.user_day_summary`
),
daily AS (
  SELECT
    DATE_DIFF(activity_date, install_date, DAY) AS day_number,
    revenue
  FROM `my-project-nitay.coin_master_project.user_day_summary`
),
agg AS (
  SELECT
    day_number,
    SUM(revenue) AS daily_revenue
  FROM daily
  GROUP BY day_number
)
SELECT
  a.day_number,
  a.daily_revenue,
  SUM(a.daily_revenue) OVER (ORDER BY a.day_number) AS cumulative_revenue,
  ROUND(SUM(a.daily_revenue) OVER (ORDER BY a.day_number) / c.cohort_size, 4) AS cumulative_ltv
FROM agg a
CROSS JOIN cohort c
ORDER BY a.day_number;