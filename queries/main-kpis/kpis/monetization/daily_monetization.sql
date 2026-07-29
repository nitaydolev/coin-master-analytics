-- MONETIZATION
-- ============    
-- KPIs: Daily Revenue, daily conversion to payers, ARPDAU, ARPPU.
-- Grain: one row per calendar day.
-- A single day mixes users who installed yesterday with users who installed a year ago.

-- ARPDAU, not ARPU: the denominator is daily active users, so the figure is per active day.
-- Lifetime ARPU per user is a separate metric with a different denominator.

-- SAFE_DIVIDE on ARPPU because days with no payers would divide by zero. NULL is correct there:
-- no payers means there is no average to compute, which is not the same as an average of zero.

-- Small denominators make conversion jump: on days with roughly 100 DAU, three payers reads as
-- 2.5% while the same three on 600 DAU reads as 0.5%. Always read conversion next to dau.

-- Revenue only counts validated purchases; the InApp_Purchase_Canceled exclusion is handled
-- upstream in build/user_day_summary.sql.

WITH
  daily AS (
    SELECT
      activity_date,
      COUNT(DISTINCT uid) AS dau,
      COUNT(DISTINCT CASE WHEN purchases > 0 THEN uid END) AS daily_payers,
      SUM(revenue) AS daily_revenue
    FROM `my-project-nitay.coin_master_project.user_day_summary`
    GROUP BY activity_date
  )
SELECT
  activity_date,
  dau,
  daily_payers,
  ROUND(daily_revenue, 2) AS daily_revenue_round,
  ROUND(100 * daily_payers / dau, 2) AS daily_conversion_pct,
  ROUND(daily_revenue / dau, 4) AS arpdau,
  ROUND(SAFE_DIVIDE(daily_revenue, daily_payers), 2) AS arppu
FROM daily
ORDER BY activity_date;
