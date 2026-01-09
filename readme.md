## 📚 Data Source

This hospital database is sourced from **Maven Analytics**.

- Dataset: Hospital Patient Records  
- Provider: [Maven Analytics](https://mavenanalytics.io/data-playground/hospital-patient-records)
- Tool: ![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue).

Project Overview: "This repo analyzes a synthetic hospital dataset from Maven Analytics to uncover insights on patient demographics, encounters, and procedures. Skills demonstrated: SQL querying, data cleaning, exploratory analysis."
Setup Instructions: How to replicate (e.g., "Load data into PostgreSQL via pgAdmin: CREATE DATABASE hospital; then import CSVs from Maven.")
Data Limitations: Note synthetic nature, date range (2021-2022), and any assumptions (e.g., ages calculated as of 2023-01-01).

### DATASET
- Total Patients (974)
```sql
SELECT COUNT(*) FROM patients;
```
- Total Encounters:27891
```sql
SELECT COUNT(*) FROM encounters;
```
- Data Range: 2021-2022

## :card_file_box: Database Tables
- patients
- encounters
- procedures
- oganizations
- payers


### Basic Table Inspection Queries
```sql
SELECT * FROM patients;
SELECT * FROM encounters;
SELECT * FROM procedures;
SELECT * FROM organizations;
SELECT * FROM payers;
```

### Table Structure Example 
```sql
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position
```
## :broom: Data Cleaning & Standardization

During data inspection, the following patterns were identified and handled appropriately:

- Optional demographic fields (`suffix`, `maiden`, `zip`) contain `NULL` values, which were treated as valid and left unchanged.
- Categorical fields use abbreviated codes:
  - `marital`: `S` (Single), `M` (Married)
  - `gender`: `M` (Male), `F` (Female)
- These fields were standardized or interpreted consistently during analysis.
- Patient name fields contained non-alphabetic characters, indicating synthetic or unvalidated entries.



## :bar_chart: Example Analytical Insights

Number of living vs deceased patients based on `deathdate` values.
- The Total Number Of Alive Patients: 820
- The Total Number Of Deceased patients: 154
```sql
SELECT 
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN deathdate IS NULL THEN 1 END) AS living_patients,
    COUNT(CASE WHEN deathdate IS NOT NULL THEN 1 END) AS deceased_patients
FROM patients;
```

- Checking for Invalid dates
```sql
SELECT id, birthdate, deathdate
FROM patients
WHERE birthdate > deathdate;
```
- Most patients are in the 18-64 group, suggesting focus on adult care
```sql
SELECT 
	CASE
		WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) < 18 THEN 'Under 18'
		WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) BETWEEN 18 AND 25 THEN '18-25'
		WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) BETWEEN 25 AND 45 THEN '25-45'
		WHEN EXTRACT(YEAR FROM AGE('2023-01-01'::DATE,birthdate)) BETWEEN 45 AND 65 THEN '45-65'
		ELSE '65+'
	END AS age_group,
	COUNT(*) AS COUNT
FROM patients WHERE deathdate IS  NULL
GROUP BY age_group
ORDER BY age_group;
```
- The Top 5 most common procedure descriptions performed in the hospital.
```sql
SELECT COUNT(p.description) AS procedure_count,p.description FROM patients AS Pat
INNER JOIN encounters AS EN ON Pat.id = EN.patient
INNER JOIN procedures AS P ON EN.id=p.encounter group by p.description ORDER BY COUNT(p.description);
```
- Average cost per patient (joining Patients and Encounters).
```sql 
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS full_name,
AVG(e.base_encounter_cost) AS avg_cost
FROM patients p
JOIN encounters e ON p.patient_id = e.patient_id
GROUP BY p.patient_id, full_name
ORDER BY avg_cost DESC
```
- Most common procedures by gender.

```sql
SELECT pre.description,gender,count(*) AS COUNT FROM procedures AS pre
INNER JOIN patients AS p ON pre.patient = p.id
INNER JOIN encounters AS en ON pre.encounter=en.id
 GROUP BY pre.description,p.gender ORDER BY COUNT DESC;
```
- Total Claim Costs by Payer with Insurance Status

```sql
SELECT 
    PAY.name AS payer_name,
    SUM(EN.total_claim_cost) AS total_claim_cost,
    CASE 
        WHEN PAY.name = 'NO_INSURANCE' THEN 'SELF_PAID'
        ELSE 'INSURANCE'
    END AS insurance_state
FROM patients AS P
INNER JOIN encounters AS EN ON P.patient_id = EN.patient_id
INNER JOIN payers AS PAY ON EN.payer_id = PAY.payer_id
GROUP BY PAY.payer_id, PAY.name
ORDER BY total_claim_cost DESC;
```
- Total claim cost with encouters number;
```sql
SELECT 
    CASE 
        WHEN PAY.name = 'NO_INSURANCE' THEN 'SELF_PAID'
        ELSE 'INSURANCE'
    END AS insurance_state,
    COUNT(DISTINCT EN.encounter_id) AS total_encounters,
    COUNT(DISTINCT P.patient_id) AS total_patients,
    SUM(EN.total_claim_cost) AS total_claim_cost
FROM patients AS P
INNER JOIN encounters AS EN ON P.patient_id = EN.patient_id
INNER JOIN payers AS PAY ON EN.payer_id = PAY.payer_id
GROUP BY insurance_state
ORDER BY total_claim_cost DESC;
```
- Insurers cover 80% of costs, but self-paid amounts are significant, suggesting opportunities for better coverage outreach.

```sql
SELECT 
    COUNT(DISTINCT e.id) AS uninsured_patients,
    SUM(e.total_claim_cost) AS total_uninsured_cost,
    AVG(e.base_encounter_cost) AS avg_uninsured_encounter_cost
FROM encounters e
JOIN payers py ON e.payer = py.id
WHERE py.name = 'NO_INSURANCE'; 
```