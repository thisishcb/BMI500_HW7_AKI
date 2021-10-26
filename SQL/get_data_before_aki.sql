WITH patients AS
(
    SELECT * FROM `mimiciii-328704.mimicself.patients_stage` 
    WHERE AKI_STAGE != 0
    ORDER BY AKI_STAGE,SUBJECT_ID
)
SELECT
    le.SUBJECT_ID
    , le.ITEMID
    , le.charttime
    , pt.AKI_STAGE
    , pt.STAGE_TIME
FROM `physionet-data.mimiciii_clinical.labevents` le
INNER JOIN patients pt
on le.SUBJECT_ID = pt.SUBJECT_ID
WHERE
le.charttime < pt.STAGE_TIME
-- SELECT 6-12 hrs before AKI
-- same reason as in get_urine
-- each data already has one hour recorded if identified at 14:00, data should be from 2-8 which is data collected at 3-8
-- use 6-24 for training
and le.charttime <= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '6' HOUR))
and le.charttime >= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '11' HOUR))
and le.VALUENUM is not null
