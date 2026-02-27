SELECT
    COUNT(p.description) AS procedure_count,
    p.description,
    MAX(p.base_cost) AS base_cost
FROM patients AS Pat
INNER JOIN encounters AS EN
    ON Pat.id = EN.patient
INNER JOIN procedures AS P
    ON EN.id = P.encounter
GROUP BY
    p.description
ORDER BY
    COUNT(p.description) DESC
LIMIT 10;