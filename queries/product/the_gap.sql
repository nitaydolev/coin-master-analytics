-- PRODUCT
-- =======
-- Two queries, one per question, both feeding the same paragraph.

-- 1) How many players are at each stage of the store funnel:
-- opened the store, left at checkout, completed a purchase.

-- Counts people, not events: a player who cancelled forty times counts once.
-- Result: 26,576 users, 26,230 opened the store, 22,382 cancelled, 446 completed.
-- The 3,402 unaccounted for opened the store and never started a purchase.

SELECT
  COUNT(DISTINCT uid) AS total_users,
  COUNT(DISTINCT IF(event = 'Store_Open', uid, NULL)) AS opened_store,
  COUNT(DISTINCT IF(event = 'InApp_Purchase_Canceled', uid, NULL))
    AS cancelled_a_purchase,
  COUNT(DISTINCT IF(event = 'InApp_Purchase', uid, NULL))
    AS completed_a_purchase
FROM `ppltx-ba-course.final_project.fact`;


-- 2) What is the conversion to payer at D30 and over the full lifetime?

-- D30 is the standard horizon. The lifetime figure is reliable here only because
-- the cohort is closed and every user had far more than 365 days of observation.
-- Result: 1.11% by D30, 1.68% across the full window.

WITH
  first_purchase AS (
    SELECT
      uid,
      install_date,
      MIN(IF(revenue > 0, activity_date, NULL)) AS first_purchase_day
    FROM `my-project-nitay.coin_master_project.user_day_summary`
    GROUP BY uid, install_date
  )
SELECT
  ROUND(
    COUNTIF(DATE_DIFF(first_purchase_day, install_date, DAY) <= 30)
      / COUNT(*)
      * 100,
    2) AS conv_d30_pct,
  ROUND(COUNTIF(first_purchase_day IS NOT NULL) / COUNT(*) * 100, 2)
    AS conv_lifetime_pct
FROM first_purchase;
