-- MONETIZATION
-- ============
-- KPI: LTV (Lifetime Value)
-- Definition: cumulative revenue per install, up to a stated horizon.

-- There is no single LTV, only LTV at a horizon, so this returns a curve:
--   D0 $0.058   D7 $0.070   D30 $0.110   D90 $0.230   D365 $0.473

-- The horizons CTE is a scaffold. It is needed because the groups overlap: revenue from
-- day 5 counts toward D7, D14, D30 and every later horizon. The CROSS JOIN pairs each
-- user-day with every horizon, and the CASE keeps only the revenue at or before it.

-- Denominator is all 26,576 users at every horizon. Safe only because installs span
-- 70 days while activity runs to 2025-09-13, so every user was observed at least 1,285
-- days against a 365-day maximum horizon.

WITH
  user_days AS (
    SELECT
      uid,
      DATE_DIFF(activity_date, install_date, DAY) AS day_number,
      revenue
    FROM `my-project-nitay.coin_master_project.user_day_summary`
  ),
  horizons AS (
    SELECT horizon FROM UNNEST([0, 1, 7, 14, 30, 60, 90, 180, 365]) AS horizon
  )
SELECT
  h.horizon,
  COUNT(DISTINCT ud.uid) AS total_users,
  SUM(CASE WHEN ud.day_number <= h.horizon THEN ud.revenue ELSE 0 END) AS revenue_to_horizon,
  ROUND(SUM(CASE WHEN ud.day_number <= h.horizon THEN ud.revenue ELSE 0 END)
        / COUNT(DISTINCT ud.uid), 4) AS ltv
FROM horizons AS h
CROSS JOIN user_days AS ud
GROUP BY h.horizon
ORDER BY h.horizon;
