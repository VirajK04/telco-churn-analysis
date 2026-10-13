-- Query 2: churn by tenure bucket
-- Step 1 (CTE): label every customer with a tenure bucket using CASE.
-- Step 2: aggregate by that label.
WITH bucketed AS (
    SELECT
        customerID,
        tenure,
        churn_flag,
        CASE
            WHEN tenure <= 12 THEN '0-12'
            WHEN tenure <= 24 THEN '13-24'
            WHEN tenure <= 48 THEN '25-48'
            ELSE '49+'
        END AS tenure_bucket
    FROM customers
)
SELECT
    tenure_bucket,
    COUNT(*)                           AS customers,
    SUM(churn_flag)                    AS churned,
    ROUND(100.0 * AVG(churn_flag), 2)  AS churn_pct,
    ROUND(100.0 - 100.0 * AVG(churn_flag), 2) AS retention_pct
FROM bucketed
GROUP BY tenure_bucket
ORDER BY MIN(tenure);   -- sort by time order, not alphabetically
