-- Validation: cross-midnight session split impact
-- Backs claim in: build/user_day_summary.sql (session_length CTE comment, "under 0.2% of sessions")
-- 
-- Context: session length is computed at a temporary (uid, day, session_number) grain, then
-- aggregated back up to the user-day grain of the table. Including the day in that grain means a
-- session crossing midnight is split into two rows, one per day. This file checks that the split
-- is justified: that it affects very few sessions, that those sessions are artifacts and not real
-- engagement, and that the resulting average is clean.
--
-- Q1: how many sessions cross midnight?            -> 391 of 254,790 = 0.153%
-- Q2: are they real engagement or artifacts?       -> mean 6.1h, max 38.63 days, i.e. artifacts
-- Q3: how much does not splitting inflate the avg? -> 308.86s vs 275.45s, a 12% inflation
-- Q4: is the split average clean (mean ~ median)?  -> split mean 275s vs median 269s (~2%), healthy
--
-- Verdict: the split is correct. It affects a tiny share (0.153%), those sessions are
-- background artifacts (app left open), not splitting inflates the mean by 12%, and after
-- the split the mean sits close to the median, confirming a healthy distribution with no fat tail.


-- Q1: how many sessions cross midnight (touch more than one calendar day)?
WITH whole_sessions AS (
  SELECT
    uid,
    session_number,
    COUNT(DISTINCT DATE(event_time)) AS distinct_days
  FROM `ppltx-ba-course.final_project.fact`
  GROUP BY uid, session_number
)
SELECT
  COUNT(*) AS total_sessions,
  COUNTIF(distinct_days > 1) AS crosses_midnight,
  ROUND(100 * COUNTIF(distinct_days > 1) / COUNT(*), 3) AS pct_crossing
FROM whole_sessions;


-- Q2: are the cross-midnight sessions real engagement or background artifacts?
-- Measured as whole sessions (no day split) to see their true full span.
WITH whole_sessions AS (
  SELECT
    uid,
    session_number,
    COUNT(DISTINCT DATE(event_time)) AS distinct_days,
    TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), SECOND) AS session_seconds
  FROM `ppltx-ba-course.final_project.fact`
  GROUP BY uid, session_number
)
SELECT
  COUNT(*) AS crossing_sessions,
  ROUND(AVG(session_seconds) / 3600, 2) AS mean_hours,
  ROUND(MAX(session_seconds) / 86400, 2) AS max_days
FROM whole_sessions
WHERE distinct_days > 1;


-- Q3 and Q4: mean vs median, split vs whole, side by side.
-- Q3 (inflation): compare split_mean to whole_mean, not splitting inflates the average.
-- Q4 (clean average): compare mean to median within each, close = healthy, far = fat tail.
WITH split_sessions AS (
  SELECT
    uid,
    DATE(event_time) AS activity_date,
    session_number,
    TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), SECOND) AS session_seconds
  FROM `ppltx-ba-course.final_project.fact`
  GROUP BY uid, activity_date, session_number
),
whole_sessions AS (
  SELECT
    uid,
    session_number,
    TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), SECOND) AS session_seconds
  FROM `ppltx-ba-course.final_project.fact`
  GROUP BY uid, session_number
)
SELECT
  (SELECT ROUND(AVG(session_seconds), 2) FROM split_sessions) AS split_mean,
  (SELECT ROUND(APPROX_QUANTILES(session_seconds, 2)[OFFSET(1)], 2) FROM split_sessions) AS split_median,
  (SELECT ROUND(AVG(session_seconds), 2) FROM whole_sessions) AS whole_mean,
  (SELECT ROUND(APPROX_QUANTILES(session_seconds, 2)[OFFSET(1)], 2) FROM whole_sessions) AS whole_median;