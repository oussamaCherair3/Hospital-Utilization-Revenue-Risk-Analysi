SELECT pre.description,p.gender,count(*) AS COUNT FROM procedures AS pre
INNER JOIN patients AS p ON pre.patient = p.id
INNER JOIN encounters AS en ON pre.encounter=en.id
GROUP BY pre.description,p.gender ORDER BY COUNT DESC LIMIT 5;