-- temporary tables and churn rate calculation
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month,
CASE
  WHEN (segment = 87)
 AND
 (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
      ELSE 0
      END as is_active_87,
CASE
 WHEN (segment = 30)
 AND
 (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
      ELSE 0
      END as is_active_30,
CASE
WHEN (segment = 87)
  AND (subscription_end BETWEEN first_day AND last_day)
    THEN 1
    ELSE 0
    END as is_canceled_87,
CASE
	WHEN (segment = 30)
 		AND (subscription_end BETWEEN first_day AND last_day)
 	    THEN 1
      ELSE 0
      END as is_canceled_30
FROM cross_join),
status_aggregate AS
(SELECT month,
 SUM(is_active_30) AS active_30,
 SUM(is_canceled_30) AS canceled_30,
 SUM(is_active_87) AS active_87,
 SUM(is_canceled_87) AS canceled_87
FROM status
GROUP BY month)

SELECT month,
  ROUND(1.0 * canceled_87/active_87, 2) AS churn_rate_87,
  ROUND(1.0 * canceled_30/active_30, 2) AS churn_rate_30
FROM status_aggregate;

-- temporary tables and active user count
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, first_day as month,
CASE
  WHEN (segment = 87)
  AND
 (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
      ELSE 0
      END as is_active_87,
CASE
 WHEN (segment = 30)
 AND
 (subscription_start < first_day)
    AND (
      subscription_end > first_day
      OR subscription_end IS NULL
    ) THEN 1
      ELSE 0
      END as is_active_30,
CASE
WHEN (segment = 87)
  AND (subscription_end BETWEEN first_day AND last_day)
    THEN 1
    ELSE 0
    END as is_canceled_87,
CASE
	WHEN (segment = 30)
 		AND (subscription_end BETWEEN first_day AND last_day)
 	    THEN 1
      ELSE 0
      END as is_canceled_30
FROM cross_join),
status_aggregate AS
(SELECT month,
 SUM(is_active_30) AS active_30,
 SUM(is_canceled_30) AS canceled_30,
 SUM(is_active_87) AS active_87,
 SUM(is_canceled_87) AS canceled_87
FROM status
GROUP BY month)

SELECT month, active_30, active_87
FROM status_aggregate
GROUP BY month;
