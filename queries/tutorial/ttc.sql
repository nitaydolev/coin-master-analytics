-- TUTORIAL
-- ========
-- KPI 4: Time to Complete (TTC) per tutorial step, per app version.
-- Grain: one row per app_version and step_index.

-- avg_time is the mean of time_spent over tutorial_step_completed events. Only completed
-- events are used, since time_spent is meaningful only for a step that was actually finished.
-- n is the number of completions behind each average, kept so a small denominator is visible.

-- step_map is a lookup built from the data: each step_index maps to exactly one step_name
-- step_name lives only on step_viewed events, hence the separate lookup
-- rather than reading it from the completed events directly.

WITH
  step_map AS (
    SELECT DISTINCT 
    step_index, 
    step_name
    FROM `ppltx-ba-course.final_project.tutorial`
    WHERE step_name IS NOT NULL
  ),
  ttc AS (
    SELECT
      app_version,
      step_index,
      ROUND(AVG(time_spent), 2) AS avg_time,
      COUNT(time_spent) AS n
    FROM `ppltx-ba-course.final_project.tutorial`
    WHERE event_type = 'tutorial_step_completed'
    GROUP BY app_version, step_index
  )
SELECT
  ttc.app_version,
  ttc.step_index,
  sm.step_name,
  ttc.avg_time,
  ttc.n
FROM ttc
LEFT JOIN step_map AS sm
  ON ttc.step_index = sm.step_index
ORDER BY ttc.app_version, ttc.step_index;
