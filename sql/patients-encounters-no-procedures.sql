SELECT p.id,first,last
FROM patients p
LEFT JOIN procedures pr
  ON pr.patient = p.id
WHERE pr.patient IS NULL;

/***/
SELECT first,
last FROM patients
WHERE patients.id NOT IN (SELECT DISTINCT patient  FROM procedures)