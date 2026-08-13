-- DASHBOARD
-- =========
-- Table name: retention
-- Retention cohort table for the pivot chart.
-- Grain: one row per install date, country and day in game.

-- Kept as counts, not percentages: Data Studio divides after filtering,
-- so the country slicer shrinks numerator and denominator together.

CREATE OR REPLACE TABLE `my-project-nitay.playpltx.retention_cohort` AS

-- Adds each user's age in days, so activity can be measured from install rather than by calendar date.
WITH base AS (
  SELECT
    userId,
    countryCode,
    country,
    install_date,
    DATE_DIFF(dt, install_date, DAY) + 1 AS day_in_game
  FROM `my-project-nitay.playpltx.daily_dashboard`
),

-- Counts how many users each cohort started with. This is the denominator, and it must stay fixed.
cohort_size AS (
  SELECT
    install_date,
    countryCode,
    country,
    COUNT(DISTINCT userId) AS cohort_size
  FROM base
  WHERE day_in_game = 1
  GROUP BY install_date, countryCode, country
),

-- Forces a row for every cohort, country and day, so a day with no activity still carries its cohort size into the denominator.
scaffold AS (
  SELECT 
  c.install_date, 
  c.countryCode, 
  c.country, 
  c.cohort_size, 
  n AS day_in_game
  FROM cohort_size AS c
  CROSS JOIN UNNEST(GENERATE_ARRAY(1, 30)) AS n
),

-- Counts how many users were still active on each day. This is the numerator.
retained AS (
  SELECT
    install_date,
    countryCode,
    day_in_game,
    COUNT(DISTINCT userId) AS retained
  FROM base
  GROUP BY install_date, countryCode, day_in_game
)

SELECT
  s.install_date,
  s.day_in_game,
  s.countryCode,
  s.country,
  s.cohort_size,
  IFNULL(r.retained, 0) AS retained
FROM scaffold s
LEFT JOIN retained r USING (install_date, countryCode, day_in_game)
ORDER BY s.install_date, s.countryCode, s.day_in_game;