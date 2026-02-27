SELECT p.id, p.first || ' ' || p.last AS   full_name,
ROUND(AVG(e.base_encounter_cost),2) AS Average_Cost,
SUM(total_claim_cost) AS Total_Cost,SUM(e.payer_coverage) AS INSURANCE_Covrage
FROM patients p
JOIN encounters e ON p.id = e.patient
GROUP BY p.id, full_name
ORDER BY Average_Cost DESC,Total_Cost DESC,INSURANCE_Covrage