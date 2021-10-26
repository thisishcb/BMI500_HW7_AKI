WITH patients AS
(
    SELECT * FROM `mimiciii-328704.mimicself.patients_stage` 
    WHERE AKI_STAGE != 0
    ORDER BY AKI_STAGE,SUBJECT_ID
)
SELECT 
    *
FROM 
(
    SELECT
        le.SUBJECT_ID
        , le.ITEMID
        , le.charttime
        , pt.AKI_STAGE
        , pt.STAGE_TIME
        , le.VALUENUM
    FROM `physionet-data.mimiciii_clinical.labevents` le
    INNER JOIN patients pt
    on le.SUBJECT_ID = pt.SUBJECT_ID
    WHERE
    le.charttime < pt.STAGE_TIME
    and le.charttime <= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '6' HOUR))
    and le.charttime >= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '24' HOUR))
    and le.VALUENUM is not null
)
WHERE
    ITEMID = 51221
    or ITEMID = 50912
    or ITEMID = 51006
    or ITEMID = 51265
    or ITEMID = 50902
    or ITEMID = 50882
