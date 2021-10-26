WITH patients AS
(
    SELECT * FROM `mimiciii-328704.mimicself.patients_stage` 
    WHERE AKI_STAGE != 0
    ORDER BY AKI_STAGE,SUBJECT_ID
),
filtered AS 
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
),
filt_bicar AS 
(
    SELECT * FROM filtered
    WHERE ITEMID = 50882
),
filt_chlo AS 
(
    SELECT * FROM filtered
    WHERE ITEMID = 50902
),
filt_un AS 
(
    SELECT * FROM filtered
    WHERE ITEMID = 51006
),
filt_hem AS 
(
    SELECT * FROM filtered
    WHERE ITEMID = 51221
),
filt_pc AS 
(
    SELECT * FROM filtered
    WHERE ITEMID = 51265
),
urine as 
(
    SELECT
        uo.SUBJECT_ID
        , uo.charttime
        , uo.uo_rt_6hr
        , uo.uo_rt_12hr
        , uo.uo_rt_24hr
    from `mimiciii-328704.mimicself.uo_in_unit` uo
    INNER JOIN patients pt
    ON uo.SUBJECT_ID = pt.SUBJECT_ID
    WHERE
    uo.charttime < pt.STAGE_TIME
    and uo.charttime <= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '6' HOUR))
    and uo.charttime >= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '24' HOUR))
    and uo.uo_rt_6hr is not null
    GROUP BY SUBJECT_ID, charttime, uo_rt_6hr, uo_rt_12hr, uo_rt_24hr
),
creat AS 
(
    SELECT
        cr.SUBJECT_ID
        , cr.charttime
        , cr.creat
        , cr.creat_low_past_7d
    from `mimiciii-328704.mimicself.creatinine` cr
    INNER JOIN patients pt
    ON cr.SUBJECT_ID = pt.SUBJECT_ID
    WHERE
    cr.charttime < pt.STAGE_TIME
    and cr.charttime <= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '6' HOUR))
    and cr.charttime >= (DATETIME_SUB(pt.STAGE_TIME, INTERVAL '24' HOUR))
    and cr.creat is not null
    and cr.creat_low_past_7d is not null
    GROUP BY SUBJECT_ID, charttime, creat, creat_low_past_7d
)
SELECT 
  patients.SUBJECT_ID
  , patients.GENDER
  , patients.AKI_STAGE
  , AVG(filt_bicar.VALUENUM) as BICAR_AVG
  , AVG(filt_chlo.VALUENUM) as CHLO_AVG
  , AVG(filt_un.VALUENUM) as UN_AVG
  , AVG(filt_hem.VALUENUM) as HEM_AVG
  , AVG(filt_pc.VALUENUM) as PC_AVG
  , AVG(uo.uo_rt_6hr) as uo_rt_6hr_avg
  , MAX(uo.uo_rt_6hr) as uo_rt_6hr_max
  , MIN(uo.uo_rt_6hr) as uo_rt_6hr_min
  , AVG(uo.uo_rt_12hr) as uo_rt_12hr_avg
  , MAX(uo.uo_rt_12hr) as uo_rt_12hr_max
  , MIN(uo.uo_rt_12hr) as uo_rt_12hr_min
  , AVG(uo.uo_rt_24hr) as uo_rt_24hr_avg
  , MAX(uo.uo_rt_24hr) as uo_rt_24hr_max
  , MIN(uo.uo_rt_24hr) as uo_rt_24hr_min
  , MAX(cr.creat)-MIN(cr.creat) as creat_diff
  , AVG(cr.creat) as creat_avg
  , MIN(cr.creat_low_past_7d) as creat_baseline
FROM patients
LEFT JOIN filt_bicar on filt_bicar.SUBJECT_ID = patients.SUBJECT_ID
LEFT JOIN filt_chlo on filt_chlo.SUBJECT_ID = patients.SUBJECT_ID
LEFT JOIN filt_un on filt_un.SUBJECT_ID = patients.SUBJECT_ID
LEFT JOIN filt_hem on filt_hem.SUBJECT_ID = patients.SUBJECT_ID
LEFT JOIN filt_pc on filt_pc.SUBJECT_ID = patients.SUBJECT_ID
LEFT JOIN urine uo on uo.SUBJECT_ID = patients.SUBJECT_ID
LEFT JOIN creat cr on cr.SUBJECT_ID = patients.SUBJECT_ID
group by SUBJECT_ID, GENDER, AKI_STAGE