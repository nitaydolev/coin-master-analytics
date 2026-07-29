-- TUTORIAL
-- ========
-- Tutorial funnel: unique users per step, per app version.
-- This is the shared base for three KPIs, all derived from these counts:
--   KPI 1: Funnel Completion Rate   final step users / first step users
--   KPI 2: Step-by-Step Conversion  each step's users / first step users
--   KPI 3: Step-by-Step Drop-off    each step's users / previous step's users

-- Grain: one row per app_version and step_name.
-- COUNT(DISTINCT user_id) counts users, not events, so a user who viewed a step
-- more than once is still counted once.

-- step_name is populated only on tutorial_step_viewed events; all other event types
-- carry NULL. Filtering IS NOT NULL therefore restricts the funnel to step views,
-- so num_users counts users who reached (viewed) each step.

-- The three KPIs are computed in Google Sheets rather than here, so the funnel
-- is laid out for clear visualization.

SELECT
  app_version,
  step_name,
  COUNT(DISTINCT user_id) AS num_users
FROM `ppltx-ba-course.final_project.tutorial`
WHERE step_name IS NOT NULL
GROUP BY app_version, step_name
ORDER BY app_version, step_name;