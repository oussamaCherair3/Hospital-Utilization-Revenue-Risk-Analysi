SELECT
    COUNT(*) AS No_Payer_Coverage,
    (COUNT(*) * 100) / (SELECT COUNT(*) FROM encounters) AS coverage_percent
FROM encounters
WHERE payer_coverage = 0;


-- uninsured total cost 
SELECT
    SUM(CASE WHEN payer_coverage = 0 THEN total_claim_cost END) AS unpaid_cost,
    ROUND(
        SUM(CASE WHEN payer_coverage = 0 THEN total_claim_cost END) * 100.0
        / SUM(total_claim_cost),
        2
    ) AS unpaid_percentage
FROM encounters;