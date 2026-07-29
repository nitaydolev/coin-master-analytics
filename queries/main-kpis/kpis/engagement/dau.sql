-- ENGAGEMENT
-- ==========
-- KPI: DAU (Daily Active Users)
-- Definition: number of unique users with at least one recorded event on each calendar day.
-- The table grain is already one row per user-day, so DISTINCT is not strictly required here.
-- It is kept to state the intent explicitly and to stay safe if the grain ever changes.

SELECT
  activity_date,
  COUNT(DISTINCT uid) AS dau
FROM `my-project-nitay.coin_master_project.user_day_summary`
GROUP BY activity_date
ORDER BY activity_date;
