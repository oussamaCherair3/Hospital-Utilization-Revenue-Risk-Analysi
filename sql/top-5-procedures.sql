SELECT  COUNT(p.description) AS procedure_count,p.description
FROM patients AS Pat < br > INNER
JOIN encounters AS EN
ON Pat.id = EN.patient < br > INNER
JOIN procedures AS P
ON EN.id = p.encounter < br > GROUP BY p.description
ORDER BY COUNT(p.description) DESC
LIMIT 5;