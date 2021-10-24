-- Modified from https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/organfailure/kdigo_creatinine.sql


WITH scr AS (
    -- table of all labevents with 
    -- use 50912 rather than 51081
    SELECT
        le.ROW_ID
        , le.SUBJECT_ID
        , le.HADM_ID
        , le.valuenum as creat
        , le.charttime
    FROM 
    `physionet-data.mimiciii_clinical.labevents` le
    where
        le.ITEMID = 50912
        and le.VALUENUM is not null
)
-- CREATE TABLE scr_stage
SELECT
  scr.SUBJECT_ID
  , scr.HADM_ID
  , scr.creat
  , scr.charttime
  , MIN(cr48.creat) AS creat_low_past_48hr
  , MIN(cr7.creat) AS creat_low_past_7d
  
FROM scr
-- add in all creatinine values in the last 48 hours
LEFT JOIN scr cr48
  ON scr.SUBJECT_ID = cr48.SUBJECT_ID
  AND cr48.charttime <  scr.charttime
  AND DATETIME_DIFF(scr.charttime, cr48.charttime, HOUR) <= 48
-- add in all creatinine values in the last 7 days
LEFT JOIN scr cr7
  ON scr.SUBJECT_ID = cr7.SUBJECT_ID
  AND cr7.charttime <  scr.charttime
  AND DATETIME_DIFF(scr.charttime, cr7.charttime, DAY) <= 7
GROUP BY scr.SUBJECT_ID, scr.HADM_ID, scr.charttime, scr.creat
ORDER BY scr.HADM_ID, scr.charttime, scr.creat;