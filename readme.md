## 📚 Data Source

This hospital database is sourced from **Maven Analytics**.

- Dataset: Hospital Patient Records  
- Provider: [Maven Analytics](https://mavenanalytics.io/data-playground/hospital-patient-records)
- Tool: ![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue).

The dataset is used for learning and educational purposes.

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

### Table Structure Example (patients)
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'patients';
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
```sql
SELECT COUNT(*) FROM patients WHERE deathdate IS NULL;
```
- The Total Number Of Deceased patients: 154
```sql
SELECT COUNT(*) FROM patients WHERE deathdate IS NOT NULL;
```
