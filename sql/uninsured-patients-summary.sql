SELECT
    COUNT(DISTINCT e.patient) AS uninsured_patients,
    SUM(e.total_claim_cost) AS total_uninsured_cost,
    AVG(e.base_encounter_cost) AS avg_uninsured_encounter_cost
FROM encounters e
JOIN payers py ON e.payer = py.id
WHERE py.name = 'NO_INSURANCE';