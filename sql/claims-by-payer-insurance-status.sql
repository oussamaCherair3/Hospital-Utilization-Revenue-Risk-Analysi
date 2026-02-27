SELECT
    PAY.name AS payer_name,
    SUM(EN.total_claim_cost) AS total_claim_cost,
    CASE
        WHEN PAY.name = 'NO_INSURANCE' THEN 'SELF_PAID'
        ELSE 'INSURANCE'
    END AS insurance_state
FROM patients AS P
INNER JOIN encounters AS EN ON P.id = EN.patient
INNER JOIN payers AS PAY ON EN.payer = PAY.id
GROUP BY PAY.id, PAY.name
ORDER BY total_claim_cost DESC;


/**/
SELECT
    CASE
        WHEN PAY.name = 'NO_INSURANCE' THEN 'SELF_PAID'
        ELSE 'INSURANCE'
    END AS insurance_state,
    COUNT(DISTINCT EN.id) AS total_encounters,
    COUNT(DISTINCT P.id) AS total_patients,
    SUM(EN.total_claim_cost) AS total_claim_cost
FROM patients AS P
INNER JOIN encounters AS EN ON P.id = EN.patient
INNER JOIN payers AS PAY ON EN.payer = PAY.id
GROUP BY insurance_state
ORDER BY total_claim_cost DESC;