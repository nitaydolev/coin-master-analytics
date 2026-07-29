-- ENGAGEMENT
-- ==========
-- KPI: MAU (Monthly Active Users)
-- Definition: number of unique users with at least one recorded event in each calendar month.
-- DISTINCT is required here: within a month a user appears on one row per active day.
-- Edge months are partial and will read as artificially low: 2021-12 covers only Dec 29-31,
-- and 2025-09 covers only Sep 13. Not a drop in engagement, just the edges of the data window.
-- Note: this is calendar MAU. The rolling 30-day MAU used for Stickiness is a separate calculation.

SELECT
  FORMAT_DATE('%Y-%m', activity_date) AS month,
  COUNT(DISTINCT uid) AS mau
FROM `my-project-nitay.coin_master_project.user_day_summary`
GROUP BY month
ORDER BY month;
