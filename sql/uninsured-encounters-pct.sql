SELECT
    COUNT(*) AS No_Payer_Coverage,
    (COUNT(*) * 100) / (SELECT COUNT(*) FROM encounters) AS coverage_percent
FROM encounters
WHERE payer_coverage = 0;