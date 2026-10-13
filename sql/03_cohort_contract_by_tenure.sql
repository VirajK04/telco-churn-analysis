-- Query 3: churn for every contract x tenure-bucket cohort, plus window functions.
-- CTE 1 labels each customer with a bucket; CTE 2 aggregates per cohort;
-- the final SELECT adds three window-function columns.
WITH bucketed AS (
    SELECT
        Contract,
        tenure,
        churn_flag,
        CASE
            WHEN tenure <= 12 THEN '0-12'
            WHEN tenure <= 24 THEN '13-24'
            WHEN tenure <= 48 THEN '25-48'
            ELSE '49+'
        END AS tenure_bucket
    FROM customers
),
cohort_stats AS (
    SELECT
        Contract,
        tenure_bucket,
        MIN(tenure)                        AS bucket_start,   -- used only for sorting
        COUNT(*)                           AS customers,
        SUM(churn_flag)                    AS churned,
        ROUND(100.0 * AVG(churn_flag), 2)  AS churn_pct
    FROM bucketed
    GROUP BY Contract, tenure_bucket
)
SELECT
    Contract,
    tenure_bucket,
    customers,
    churned,
    churn_pct,
    -- 1) rank all cohorts by churn rate (1 = worst)
    RANK() OVER (ORDER BY churn_pct DESC) AS risk_rank,
    -- 2) each cohort's share of ALL churners (SUM(...) OVER () = grand total on every row)
    ROUND(100.0 * churned / SUM(churned) OVER (), 2) AS pct_of_all_churners,
    -- 3) change vs the previous tenure bucket for the SAME contract
    ROUND(churn_pct - LAG(churn_pct) OVER (PARTITION BY Contract ORDER BY bucket_start), 2) AS change_vs_prev_bucket
FROM cohort_stats
ORDER BY Contract, bucket_start;
