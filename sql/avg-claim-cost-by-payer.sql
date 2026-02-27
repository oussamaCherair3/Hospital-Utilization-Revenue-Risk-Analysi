SELECT
    pa.name,
    ROUND(AVG(en.total_claim_cost), 2) AS avg_claim_cost
FROM encounters en
INNER JOIN payers pa
    ON en.payer = pa.id
GROUP BY
    pa.name
ORDER BY
    avg_claim_cost DESC;