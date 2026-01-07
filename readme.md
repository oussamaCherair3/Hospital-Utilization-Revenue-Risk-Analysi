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
- The Top 5 most common procedure descriptions performed in the hospital.
```sql
SELECT COUNT(p.description) AS procedure_count,p.description FROM patients AS Pat
INNER JOIN encounters AS EN ON Pat.id = EN.patient
INNER JOIN procedures AS P ON EN.id=p.encounter group by p.description ORDER BY COUNT(p.description);
```
