-- TUTORIAL
-- ========
-- KPI 5: Post-Tutorial Engagement Rate, plus the two figures that support the
-- recommendation attached to it.
-- Grain: one row, rates across the whole install cohort.

-- engagement_rate_d7 is KPI 5 itself: the share of installed users who spin and
-- level up within 7 days. spin_rate_d7 and levelled_share_of_spinners are reported
-- alongside it to locate where the shortfall sits, spinning or building.

-- The Play event is this dataset's equivalent of a spin. There is no build event,
-- so a rise in Level is used as the proxy for a build.

-- All three figures share one definition and one 7 day window, so the ratio between
-- them is valid.

WITH install AS (
  SELECT
    uid,
    MIN(event_time) AS install_ts,
    MIN(Level) AS start_level
  FROM `ppltx-ba-course.final_project.fact`
  GROUP BY uid
),
flags AS (
  SELECT
    i.uid,
    MAX(CASE
          WHEN f.event = 'Play'
           AND TIMESTAMP_DIFF(f.event_time, i.install_ts, HOUR) <= 168
          THEN 1 ELSE 0 END) AS spun,
    MAX(CASE
          WHEN f.event = 'Play'
           AND f.Level > i.start_level
           AND TIMESTAMP_DIFF(f.event_time, i.install_ts, HOUR) <= 168
          THEN 1 ELSE 0 END) AS spun_and_levelled
  FROM `ppltx-ba-course.final_project.fact` f
  JOIN install i USING (uid)
  GROUP BY i.uid
)
SELECT
  COUNT(*) AS installed_users,
  SUM(spun) AS spun_users,
  ROUND(SUM(spun) / COUNT(*) * 100, 2) AS spin_rate_d7,
  SUM(spun_and_levelled) AS engaged_users,
  ROUND(SUM(spun_and_levelled) / COUNT(*) * 100, 2) AS engagement_rate_d7,
  ROUND(SUM(spun_and_levelled) / SUM(spun) * 100, 2) AS levelled_share_of_spinners
FROM flags;