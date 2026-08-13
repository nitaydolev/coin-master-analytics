-- Create a dedicated dataset for the Coin Master project.
-- IF NOT EXISTS makes the statement safe to re-run. Location US matches the source data,
-- since BigQuery cannot join tables across locations.

CREATE SCHEMA IF NOT EXISTS `my-project-nitay.coin_master_project`
OPTIONS (location = 'US');

-- Build user_day_summary: aggregates raw fact events into one row per user per active day.
-- This is the derived source of trquth for all Main KPIs (retention, LTV, ARPU, etc.).
-- CREATE OR REPLACE makes it safe to re-run; the table is fully rebuilt each time.

-- Not computable from this data (defined in the report, not calculated):
--   CPI and ROAS: require ad-spend data, which the source fact table does not contain.
CREATE OR REPLACE TABLE `my-project-nitay.coin_master_project.user_day_summary`
OPTIONS (
  description = "User-day grain: one row per user per active day. Source of truth for Main KPIs. Built from ppltx-ba-course.final_project.fact."
)
AS
WITH
  -- One row per user: the day they first appear. Anchors retention and LTV.
  user_install AS (
    SELECT
      uid,
      DATE(MIN(event_time)) AS install_date
    FROM `ppltx-ba-course.final_project.fact`
    GROUP BY uid
  ),
  -- One row per session (uid + day + session_number). Session length is the span
  -- from first to last event in the session. Day is in the grain, so a rare session
  -- crossing midnight is split into two; this touches under 0.2% of sessions.
  -- Validated in validation/session_midnight_split.sql (391 of 254,790 sessions, 0.153%).
  session_length AS (
    SELECT
      uid,
      DATE(event_time) AS activity_date,
      session_number,
      TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), SECOND) AS session_seconds
    FROM `ppltx-ba-course.final_project.fact`
    GROUP BY uid, activity_date, session_number
  ),
  -- One row per user-day: session count and total session time.
  -- Both come from the same session grain above, so Average Session Length,
  -- SUM(total_session_seconds) / SUM(sessions), stays coherent across any slice.
  daily_sessions AS (
    SELECT
      uid,
      activity_date,
      COUNT(*) AS sessions,
      SUM(session_seconds) AS total_session_seconds
    FROM session_length
    GROUP BY uid, activity_date
  ),
  -- One row per user-day: revenue and purchases.
  -- Revenue counts price only on InApp_Purchase, never on canceled or other events.
  daily_revenue AS (
    SELECT
      uid,
      DATE(event_time) AS activity_date,
      SUM(IF(event = 'InApp_Purchase', price, 0)) AS revenue,
      COUNTIF(event = 'InApp_Purchase') AS purchases
    FROM `ppltx-ba-course.final_project.fact`
    GROUP BY uid, activity_date
  )
SELECT
  s.uid,
  s.activity_date,
  i.install_date,
  s.sessions,
  r.revenue,
  r.purchases,
  s.total_session_seconds
FROM daily_sessions AS s
JOIN user_install AS i USING (uid)
JOIN daily_revenue AS r USING (uid, activity_date)
ORDER BY s.uid, s.activity_date;