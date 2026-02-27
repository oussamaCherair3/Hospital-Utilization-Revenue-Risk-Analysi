SELECT
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN deathdate IS NULL THEN 1 END) AS living_patients,
    COUNT(CASE WHEN deathdate IS NOT NULL THEN 1 END) AS deceased_patients
FROM patients;