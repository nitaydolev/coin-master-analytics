-- ENGAGEMENT
-- ==========
-- KPI: Average Session Length
-- Definition: average time a user spends in the app per session.
-- Result: 275.45 seconds, or 4.59 minutes, across 255,196 sessions.

-- Computed as SUM(total_session_seconds) / SUM(sessions).
-- Both columns are additive, so summing them and dividing once is correct across any slice.

-- Session length has no dedicated timer in the source data. It is the span from the first to the
-- last event within a session, computed in build/user_day_summary.sql.

-- Sessions are counted at the (uid, day, session_number) grain, so a session crossing midnight
-- contributes one piece per day. This is why the count here (255,196) is slightly higher than the
-- 254,790 whole sessions in validation/session_midnight_split.sql, which measures them unsplit.

SELECT
  SUM(sessions) AS total_sessions,
  SUM(total_session_seconds) AS total_seconds,
  ROUND(SUM(total_session_seconds) / SUM(sessions), 2) AS avg_session_seconds,
  ROUND(SUM(total_session_seconds) / SUM(sessions) / 60, 2) AS avg_session_minutes
FROM `my-project-nitay.coin_master_project.user_day_summary`;