WITH patients AS
(
    SELECT * FROM `mimiciii-328704.mimicself.patients_stage` 
    WHERE AKI_STAGE != 0
    ORDER BY AKI_STAGE,SUBJECT_ID
)
SELECT 
    ITEMID
    , COUNT(DISTINCT SUBJECT_ID) AS SUBJECT_COUNT
FROM 
(
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
    and le.charttime <= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '6' HOUR))
    and le.charttime >= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '24' HOUR))
    and le.VALUENUM is not null
)
GROUP BY ITEMID
ORDER BY SUBJECT_COUNT DESC