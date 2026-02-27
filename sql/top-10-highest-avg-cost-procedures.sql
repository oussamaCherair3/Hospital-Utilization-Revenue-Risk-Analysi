SELECT
    description,
    ROUND(AVG(base_cost), 2) AS avg_base_cost,
    COUNT(*) AS times_performed
FROM procedures
GROUP BY description
ORDER BY avg_base_cost DESC
LIMIT 10;