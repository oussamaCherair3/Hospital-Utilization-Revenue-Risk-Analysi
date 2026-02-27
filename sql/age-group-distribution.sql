SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE, birthdate)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE, birthdate)) BETWEEN 18 AND 25 THEN '18-25'
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE, birthdate)) BETWEEN 25 AND 45 THEN '25-45'
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE, birthdate)) BETWEEN 45 AND 65 THEN '45-65'
        ELSE '65+'
    END AS age_group,
    COUNT(DISTINCT patients.id) AS patient_count,
    COUNT(encounters.id) AS total_encounters,
    ROUND(
        COUNT(encounters.id)::NUMERIC / COUNT(DISTINCT patients.id),
        1
    ) AS encounters_per_patient
FROM patients
INNER JOIN encounters
    ON patients.id = encounters.patient
WHERE deathdate IS NULL
GROUP BY
    age_group
ORDER BY
    age_group;