-- Query 1: churn and retention by contract type
-- The CTE computes the per-contract numbers first; the final SELECT adds retention.
WITH contract_stats AS (
    SELECT
        Contract,
        COUNT(*)                           AS customers,
        SUM(churn_flag)                    AS churned,      -- churn_flag is 0/1, so SUM = number of churners
        ROUND(100.0 * AVG(churn_flag), 2)  AS churn_pct     -- AVG of 0/1 = churn rate
    FROM customers
    GROUP BY Contract
)
SELECT
    Contract,
    customers,
    churned,
    churn_pct,
    ROUND(100.0 - churn_pct, 2) AS retention_pct
FROM contract_stats
ORDER BY churn_pct DESC;
