## Table of Contents

- Data Source
- Dataset
- Database Tables
- Data Cleaning & Standardization
- Analytical Insights
- Key Insights
- Recommendations

## Data Source
This hospital database is sourced from Maven Analytics.

- Dataset: Hospital Patient Records  
- Provider: [Maven Analytics](https://mavenanalytics.io/data-playground/hospital-patient-records)
Tool: PostgreSQL.
Project Overview: "This repo analyzes a synthetic hospital dataset from Maven Analytics to uncover insights on patient demographics, encounters, and procedures. Skills demonstrated: SQL querying, data cleaning, exploratory analysis."
Setup Instructions: How to replicate (e.g., "Load data into PostgreSQL via pgAdmin: CREATE DATABASE hospital; then import CSVs from Maven.")
Data Limitations: Note synthetic nature, date range (2021-2022), and any assumptions (e.g., ages calculated as of 2023-01-01).

Dataset

- Total Patients (974)

```SQL 
SELECT COUNT(*) FROM patients;
```

- Total Encounters:27891

```SQL
SELECT COUNT(*) FROM encounters;
```

Data Range: 2011-2022

## Database Tables

- patients
- encounters
- procedures
- organizations
- payers

- Basic Table Inspection Queries
```SQL
SELECT * FROM patients;
SELECT * FROM encounters;
SELECT * FROM procedures;
SELECT * FROM organizations;
SELECT * FROM payers;
``` 
## Table Structure Example
```SQL
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position
```
## Data Cleaning & Standardization
- During data inspection, the following patterns were identified and handled appropriately:

- Optional demographic fields (suffix, maiden, zip) contain NULL values, which were treated as valid and left unchanged.
Categorical fields use abbreviated codes:
  - marital: S (Single), M (Married)
  - gender: M (Male), F (Female)
These fields were standardized or interpreted consistently during analysis.
Patient name fields contained non-alphabetic characters, indicating synthetic or unvalidated entries.

## Analytical Insights
- Number of living vs deceased patients based on deathdate values.
```SQL
SELECT
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN deathdate IS NULL THEN 1 END) AS living_patients,
    COUNT(CASE WHEN deathdate IS NOT NULL THEN 1 END) AS deceased_patients
FROM patients;
```
Checking for Invalid dates

```SQL
SELECT id, birthdate, deathdate
FROM patients
WHERE birthdate >= deathdate;
```
- No Invalid dates found here. valid data

```SQL
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) BETWEEN 18 AND 25 THEN '18-25'
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) BETWEEN 25 AND 45 THEN '25-45'
        WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) BETWEEN 45 AND 65 THEN '45-65'
        ELSE '65+'
    END AS age_group,
    COUNT(DISTINCT patients.id) AS patient_count,
    COUNT(encounters.id) AS total_encounters,
    ROUND(COUNT(encounters.id)::NUMERIC / COUNT(DISTINCT patients.id), 1) AS encounters_per_patient
FROM patients
INNER JOIN encounters ON patients.id = encounters.patient
WHERE deathdate IS NULL
GROUP BY age_group
ORDER BY age_group;
```
- Top 5 most common procedures by description.
```SQL
SELECT COUNT(p.description) AS procedure_count,p.description FROM patients AS Pat
INNER JOIN encounters AS EN ON Pat.id = EN.patient
INNER JOIN procedures AS P ON EN.id=p.encounter group by p.description ORDER BY COUNT(p.description) DESC LIMIT 5;
```
- Average cost per patient, Total cost per patient, and Insurance Coverage per patient.

```SQL
SELECT p.id, p.first || ' ' || p.last AS   full_name,
ROUND(AVG(e.base_encounter_cost),2) AS Average_Cost,
SUM(total_claim_cost) AS Total_Cost,SUM(e.payer_coverage) AS INSURANCE_Covrage
FROM patients p
JOIN encounters e ON p.id = e.patient
GROUP BY p.id, full_name
ORDER BY Average_Cost DESC,Total_Cost DESC,INSURANCE_Covrage
```
Most common procedures by gender.

```SQL
SELECT pre.description,p.gender,count(*) AS COUNT FROM procedures AS pre
INNER JOIN patients AS p ON pre.patient = p.id
INNER JOIN encounters AS en ON pre.encounter=en.id
GROUP BY pre.description,p.gender ORDER BY COUNT DESC LIMIT 5;
```
- Total Claim Costs by Payer with Insurance Status, finding 10 insurance providers.
some patients have multiple payers, which means they have multiple insurance providers.
```SQL
SELECT
    PAY.name AS payer_name,
    SUM(EN.total_claim_cost) AS total_claim_cost,
    CASE
        WHEN PAY.name = 'NO_INSURANCE' THEN 'SELF_PAID'
        ELSE 'INSURANCE'
    END AS insurance_state
FROM patients AS P
INNER JOIN encounters AS EN ON P.id = EN.patient
INNER JOIN payers AS PAY ON EN.payer = PAY.id
GROUP BY PAY.id, PAY.name
ORDER BY total_claim_cost DESC; ```

```SQL
SELECT
    CASE
        WHEN PAY.name = 'NO_INSURANCE' THEN 'SELF_PAID'
        ELSE 'INSURANCE'
    END AS insurance_state,
    COUNT(DISTINCT EN.id) AS total_encounters,
    COUNT(DISTINCT P.id) AS total_patients,
    SUM(EN.total_claim_cost) AS total_claim_cost
FROM patients AS P
INNER JOIN encounters AS EN ON P.id = EN.patient
INNER JOIN payers AS PAY ON EN.payer = PAY.id
GROUP BY insurance_state
ORDER BY total_claim_cost DESC; ```
```SQL
SELECT
    COUNT(DISTINCT e.patient) AS uninsured_patients,
    SUM(e.total_claim_cost) AS total_uninsured_cost,
    AVG(e.base_encounter_cost) AS avg_uninsured_encounter_cost
FROM encounters e
JOIN payers py ON e.payer = py.id
WHERE py.name = 'NO_INSURANCE';
```
Noticed that some patient don't have any procedures, we need to check if they have any encounters.
```SQL
SELECT p.id,first,last
FROM patients p
LEFT JOIN procedures pr
  ON pr.patient = p.id
WHERE pr.patient IS NULL;
```

```SQL
SELECT first,
last FROM patients
WHERE patients.id NOT IN (SELECT DISTINCT patient  FROM procedures)
 ```
- Checking for encounters: All of the patient that don't have any procedures, have encounter range between 1 to 217.
```sql
SELECT DISTINCT p.id, p.first, p.last,
COUNT(en.id) AS Encounter_count
FROM patients p  
LEFT JOIN procedures pr ON pr.patient = p.id  
LEFT JOIN encounters en ON en.patient = p.id
WHERE pr.patient IS NULL
GROUP BY p.id, p.first, p.last
ORDER BY Encounter_count DESC;
```
## Key Insights

- The Total Number Of Alive Patients: 820
- The Total Number Of Deceased patients: 154
- High survival rate—focus on preventive care.
- Patients 65+ average 6.3 encounters per patient, 2.3x higher than the 25-45 group (2.7 encounters).
This means older patients consume significantly more healthcare resources.
The top 5 procedures are preventive screenings (medication reconciliation, depression screening, substance use assessment), and patients 65+ have 2.3x more encounters than younger groups. This suggests the hospital focuses on chronic disease management for an aging population.
27% of patients (262 out of 974) are uninsured, which means the hospital may not get paid for their care. This creates financial risk and potential bad debt.
- 181 patients (18.6%) have encounters but no recorded procedures, suggesting possible billing gaps or documentation issues.

## Recommendations
- Analyze staffing levels to ensure geriatric care capacity matches our patient mix.
- Expand preventive care programs and ensure adequate geriatric specialist staffing
- Connect uninsured patients with social workers to explore insurance enrollment or financial assistance programs.
- Review patients with encounters but no procedures to identify potential billing or documentation gaps.