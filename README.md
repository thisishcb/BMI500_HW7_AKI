- [BMI500_HW7_MIMIC_III](#bmi500_hw7_mimic_iii)
  - [Identify AKI patients from MIMIC III database](#identify-aki-patients-from-mimic-iii-database)
    - [MIMIC III](#mimic-iii)
    - [KDIGO def of AKI](#kdigo-def-of-aki)
- [Additional Notes](#additional-notes)
  - [tables of MIMIC III](#tables-of-mimic-iii)
  - [IDs for tests and criterions](#ids-for-tests-and-criterions)
      - [AKF/ARF is included in the table `d_icd_diagnoses`, but according to the definition from KDIGO](#akfarf-is-included-in-the-table-d_icd_diagnoses-but-according-to-the-definition-from-kdigo)

# BMI500_HW7_MIMIC_III
identify AKI patients with KDIGO defnition,
cluster AKI patients with unsepervised model,
extract freatures
train supervised predictive models 
 
## Identify AKI patients from MIMIC III database

### MIMIC III
[MIMIC III clinical](https://physionet.org/content/mimiciii/1.4/) 6.2 GB  
[MIMIC III WAVEFORM](https://physionet.org/content/mimic3wdb/1.0/) 6.7 TB  
[MIMIC Doc](https://mimic.mit.edu/docs/)  
SQL Query using BigQuery by Google.

### KDIGO def of AKI
satisfy any:  
| AKI Stage | Serum Creatinine (SCr) | Urine Output |
| :-------: | :--------------- | :----------- |
| 1 | 1.5-1.9 times baseline$^1$ or<br>  SCr $\ge 0.3mg/dL$ in crease | $< 0.5ml/kg/h$ for 6-12 hours |
| 2 | 2.0-2.9 times baseline | $< 0.5ml/kg/h$ for $\ge$ 12 hours |
| 3 | 3 times baseline$$ or<br> SCr $\ge 4.0mg/dL$ in crease or<br> initiation of RRT$^2$ or<br> decrease in eGFR to $<35ml/min/1.73m^2$ in patients < 18 years old | $< 0.3ml/kg/h$ for $\ge$ 24 hours or<br> Anuria for $\ge$ 12 hours|  

$^1$: What is baselime?
> baseline, which is known or presumed to have occurred within the prior 7 days;  

$^2$: RRT is a derived table, no inition information is found in MIMIC III. (?)




<!-- ============================================= -->
<!-- ====           Additional Notes          ==== -->
<!-- ============================================= -->

# Additional Notes

## tables of MIMIC III
[MIMIC III tables](https://mimic.mit.edu/docs/iii/tables/) Used tables:
| Table | Category | Fields | Description |
| - | - | - | - |
| - | - | - | - |
| - | - | - | - |

## IDs for tests and criterions
```{sql}
SELECT * FROM `physionet-data.mimiciii_clinical.d_labitems` 
    where LABEL like "%rine%" AND LABEL like "%olume%" OR 
    LABEL like "%reatinine%" AND LABEL like "%erum%" OR 
    Label like "%GFR%"
    ORDER BY ROW_ID ASC;
```
| ROW_ID | ITEMID | LABEL                         | FLUID | CATEGORY  | LOINC_CODE |
| ------ | ------ | ----------------------------- | ----- | --------- | ---------- |
| 121    | 50920  | Estimated GFR (MDRD equation) | Blood | Chemistry | 33914-3    |
| 281    | 51081  | Creatinine, Serum             | Urine | Chemistry |            |
| 308    | 51108  | Urine Volume                  | Urine | Chemistry | 28009-9    |
| 309    | 51109  | Urine Volume, Total           | Urine | Chemistry | 28009-9    |

#### AKF/ARF is included in the table `d_icd_diagnoses`, but according to the definition from [KDIGO](https://kdigo.org/wp-content/uploads/2016/10/KDIGO-2012-AKI-Guideline-English.pdf)
> AKI is defined by an abrupt decrease in kidney function that includes, but is not limited to, ARF.

```{sql}
SELECT * FROM `physionet-data.mimiciii_clinical.d_icd_diagnoses` 
    where SHORT_TITLE like "%cute%" AND SHORT_TITLE like "%kidney%"
    ORDER BY ROW_ID ASC;
```
| ROW_ID | ICD9_CODE | SHORT_TITLE              | LONG_TITLE                                                              |
| ------ | --------- | ------------------------ | ----------------------------------------------------------------------- |
| 5907   | 5848      | Acute kidney failure NEC | Acute kidney failure with other specified pathological lesion in kidney |
| 5908   | 5849      | Acute kidney failure NOS | Acute kidney failure, unspecified                                       |