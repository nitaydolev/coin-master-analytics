-- DASHBOARD
-- =========
-- Table name: daily_dashboard
-- Serving table for the daily dashboard.
-- Grain: one row per user per active day.

-- daily_panel is already at user-day grain but carries no install date, so
-- user_panel is joined to bring it in.

CREATE OR REPLACE TABLE `my-project-nitay.playpltx.daily_dashboard` AS
SELECT
  d.dt,
  d.userId,
  d.platform,
  d.countryCode,
  c.country_name AS country,
  d.condition,
  d.currentVillage,
  u.firstSeenDate AS install_date,
  d.sessionCount,
  d.t_sessionTimeSec,
  d.t_events,
  d.spinCount,
  d.buildingUpgradeCount,
  d.raidStartCount,
  d.attackStartCount,
  d.adWatchCount,
  d.iapPurchaseCount,
  d.iapRevenueUsd,
  d.isPayerDay
FROM `ppltx-ba-course.PlayPltx.daily_panel` d
LEFT JOIN `ppltx-ba-course.PlayPltx.user_panel` u USING (userId)
LEFT JOIN `my-project-nitay.playpltx.countries` c ON d.countryCode = c.country_code

