-- ACQUISITION
-- ===========
-- KPI: Installs per day
-- Definition: number of new users acquired on each calendar day.
-- COUNT(DISTINCT uid) because the table is at user-day grain, so a user appears on every active day.
-- install_date is a proxy: the raw data has no install event, so it is the user's first recorded day.

SELECT
  install_date,
  COUNT(DISTINCT uid) AS installs_per_day
FROM `my-project-nitay.coin_master_project.user_day_summary`
GROUP BY install_date
ORDER BY install_date;
