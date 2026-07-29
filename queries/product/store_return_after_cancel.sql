-- PRODUCT
-- =======
-- Question: after a player cancels a purchase, how long until they open the store again?
-- Purpose: sets the length of the timer on the Cart feature.

-- The window looks forward only. ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING
-- restricts it to events after the cancellation, so a store visit that happened
-- earlier is never counted.

-- Store_Open has to stay in the WHERE of the CTE. It is never selected in the outer
-- query, but the window needs those rows to have something to find.

-- Result: 122,280 cancellations. Three out of four are followed by the player
-- reopening the store within fifteen minutes. Widening the window to one hour adds
-- nothing, and widening it to a full day adds half a percentage point.
-- One hour is generous. A day would be noise.

WITH stream AS (
  SELECT
    uid,
    event,
    event_time,
    MIN(IF(event = 'Store_Open', event_time, NULL)) OVER (
      PARTITION BY uid ORDER BY event_time
      ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING
    ) AS next_store_open
  FROM `ppltx-ba-course.final_project.fact`
  WHERE event IN ('Store_Open', 'InApp_Purchase_Canceled')
)
SELECT
  COUNT(*) AS cancellations,
  ROUND(COUNTIF(TIMESTAMP_DIFF(next_store_open, event_time, MINUTE) <= 15) / COUNT(*) * 100, 3) AS pct_within_15_min,
  ROUND(COUNTIF(TIMESTAMP_DIFF(next_store_open, event_time, MINUTE) <= 60) / COUNT(*) * 100, 3) AS pct_within_1_hour,
  ROUND(COUNTIF(TIMESTAMP_DIFF(next_store_open, event_time, HOUR)   <= 24) / COUNT(*) * 100, 3) AS pct_within_24_hours
FROM stream
WHERE event = 'InApp_Purchase_Canceled';