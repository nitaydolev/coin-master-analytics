-- RETENTION
-- ==========
-- KPI: Day-N Retention by install cohort (D1, D7, D30)
-- Grain: one row per install_date and day_number. Day 0 is the install day.

WITH
  -- Users active on exactly day 1, 7 or 30 after their install.
  days_from_install AS (
    SELECT
      uid,
      install_date,
      DATE_DIFF(activity_date, install_date, DAY) AS day_number
    FROM `my-project-nitay.coin_master_project.user_day_summary`
    WHERE DATE_DIFF(activity_date, install_date, DAY) IN (1, 7, 30)
  ),
    -- Denominator: cohort size per install day.
  cohorts AS (
    SELECT
      install_date,
      COUNT(DISTINCT uid) AS cohort_size
    FROM `my-project-nitay.coin_master_project.user_day_summary`
    GROUP BY install_date
  ),
    -- All cohort n day combinations, so cohorts with no returning users still show a zero row.
  scaffold_n_day_cohort AS (
    SELECT
      day_number,
      c.install_date,
      c.cohort_size
    FROM UNNEST([1, 7, 30]) AS day_number
    CROSS JOIN cohorts AS c
  )
  -- LEFT JOIN keeps every scaffold row. The day_number condition must sit in ON.
SELECT
  sndc.install_date,
  sndc.day_number,
  sndc.cohort_size,
  COUNT(DISTINCT dfi.uid) AS retained_users,
  ROUND(100 * COUNT(DISTINCT dfi.uid) / sndc.cohort_size, 2) AS retention_pct
FROM scaffold_n_day_cohort AS sndc
LEFT JOIN days_from_install AS dfi
  ON
    sndc.install_date = dfi.install_date
    AND sndc.day_number = dfi.day_number
GROUP BY sndc.install_date, sndc.day_number, sndc.cohort_size
ORDER BY sndc.install_date, sndc.day_number;
