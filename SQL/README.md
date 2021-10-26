# SQL scripts

All scripts are run on Google Big Query
## Useful external links
Official Github Repository:
[https://github.com/MIT-LCP/mimic-code](https://github.com/MIT-LCP/mimic-code)

## `GET_CREATININE`
- try to match each lab item is related to a admission(`HADM_ID`)/subject(`SUBJECT_ID`) rather than ICU stays. 
- each lab exam group by subjects, find minimum in past 48h / 7days as base line 

## `URINE_OUTPUT`
- since there are too many unexpected labitems about urine output, we adopt the official file directly.
- add `SUBJECT_ID` and `HADM_ID` to table
- - [https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/fluid_balance/urine_output.sql](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/fluid_balance/urine_output.sql)

## `GET_URINE`
- [https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/organfailure/kdigo_uo.sql](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/organfailure/kdigo_uo.sql)
- try to match each lab item is related to a admission(`HADM_ID`)/subject(`SUBJECT_ID`) rather than ICU stays. 
- each urine output group by subjects, find the output in last 6,12,24 hours as would be used as indicator for AKI later.
- table `weight_durations` would be used to calculate urine in unit `ml/kg/h`.
  - `weight_durations` is recorded in table `chartevents` which is ICU stay specific.
  - ignore all data without `icustay_id` in `URINE_OUTPUT ` (cannot get weight)
- some fields
  - `starttime_6hr/12hr/24hr` -> start time of the urine output within 6/12/24h  
  - `uo_tm_6hr/12hr/24hr` -> time span of the urine output within 6/12/24h  
  -  `uo_tm_6hr/12hr/24hr` -> urine output level within 6/12/24h in `ml/kg/h`  

## `eGFR`
```
SELECT * FROM `physionet-data.mimiciii_clinical.labevents` 
WHERE ITEMID = 50920
```
all values are `see comments` which is not accessable.

## `RRT` (abandoned)
- not directly accessable as a simple therapy
- adopted the `RRT` table from `mimiciii_derived`
- https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/rrt.sql
- add time of rrt (min charttime)
- takes too muhc time to run, and the time information is lost in the existing derived table.

## `PATIENTS_STAGE_TIME`
- for each patient find the highest AKI stage and the time identified.
find all AKI patients with :
```
SELECT * FROM `mimiciii-328704.mimicself.patients_stage` 
WHERE AKI_STAGE != 0
ORDER BY AKI_STAGE,SUBJECT_ID
```

## `GET_DATA_BEFORE_AKI`
- simply filter out all data 6-12 hours before the patient is identified as AKI
  - except urine and serum creatine

## `GET_POPULAR`
- Try to get popular indicators/tests available in patients.

## `GET_DATA_24` 
- With former SQL for 6-12 hours
  - Among 25941 AKI patients, only ITEM 51221 reach 10000 subjects which is less than 50% of all subjects.
- Extend the time to 6-24h before AKI, six indicator reach 21000
- Which are `51221`, `50912`, `51006`, `51265`, `50902`, `50882`

| ROW_ID | ITEMID | LABEL          | FLUID | CATEGORY   | LOINC_CODE |
| ------ | ------ | -------------- | ----- | ---------- | ---------- |
| 83     | 50882  | Bicarbonate    | Blood | Chemistry  | 1963-8     |
| 103    | 50902  | Chloride       | Blood | Chemistry  | 2075-0     |
| 206    | 51006  | Urea Nitrogen  | Blood | Chemistry  | 3094-0     |
| 421    | 51221  | Hematocrit     | Blood | Hematology | 4544-3     |
| 465    | 51265  | Platelet Count | Blood | Hematology | 777-3      |


## `AGGREAGATE_DATA`
- aggregate data for training
- `subject_ID`, `51221`, `50912`(Creatinine), `51006`, `51265`, `50902`, `50882`; `URINE`
- `URINE` data are 
- The data limited in past 6-24h are hard to find the difference of change, most data has only one record for each patient in 6-24h, so we would use absolute value and average if there are multiple
