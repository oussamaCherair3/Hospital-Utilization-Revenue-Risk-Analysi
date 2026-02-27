SELECT
    id,
    birthdate,
    deathdate
FROM patients
WHERE birthdate >= deathdate;