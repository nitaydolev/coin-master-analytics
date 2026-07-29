-- ENGAGEMENT
-- ==========
-- KPI: Stickiness (DAU / MAU)
-- Definition: the share of the monthly active base that shows up on a given day.
-- It measures how often monthly users come back.

-- MAU here is a rolling 30-day window rather than a calendar month, so stickiness can be read
-- daily. This rolling MAU is an internal component of stickiness only; calendar MAU is the
-- standalone KPI and lives in its own file.

-- The query is driven by a date spine, so every calendar day in the observation window gets a
-- row even when no user was active.

-- Caveat: the first 29 days have no full 30-day lookback, so rolling MAU is too small
-- and stickiness reads too high. 2021-12-29 shows 1.00 only because the window holds a single
-- day. The series is comparable from 2022-01-27 onward.

-- CREATE OR REPLACE TABLE is included because Data Studio reads this table directly as a data source.

CREATE OR REPLACE TABLE `my-project-nitay.coin_master_project.stickiness_daily` AS
WITH
  bounds AS (
    SELECT
      MIN(activity_date) AS first_day,
      MAX(activity_date) AS last_day
    FROM `my-project-nitay.coin_master_project.user_day_summary`
  ),
  date_spine AS (
    SELECT day
    FROM bounds
    CROSS JOIN
      UNNEST(GENERATE_DATE_ARRAY(first_day, last_day)) AS day
  ),
  daily_active AS (
    SELECT
      activity_date,
      COUNT(DISTINCT uid) AS dau
    FROM `my-project-nitay.coin_master_project.user_day_summary`
    GROUP BY activity_date
  ),
  rolling_active AS (
    SELECT
      ds.day,
      COUNT(DISTINCT uds.uid) AS rolling_mau_30d
    FROM date_spine AS ds
    LEFT JOIN `my-project-nitay.coin_master_project.user_day_summary` AS uds
      ON uds.activity_date BETWEEN DATE_SUB(ds.day, INTERVAL 29 DAY) AND ds.day
    GROUP BY ds.day
  )
SELECT
  ds.day AS activity_date,
  IFNULL(da.dau, 0) AS dau,
  ra.rolling_mau_30d,
  ROUND(SAFE_DIVIDE(IFNULL(da.dau, 0), ra.rolling_mau_30d), 4) AS stickiness
FROM date_spine AS ds
LEFT JOIN daily_active AS da
  ON ds.day = da.activity_date
LEFT JOIN rolling_active AS ra
  ON ds.day = ra.day
ORDER BY activity_date;
