-- adopted from https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/organfailure/kdigo_stages.sql

-- This query checks if the patient had AKI according to KDIGO.
-- AKI is calculated every time a creatinine or urine output measurement occurs.
-- Baseline creatinine is defined as the lowest creatinine in the past 7 days.

-- get creatinine stages
with cr_stg AS
(
  SELECT
    cr.SUBJECT_ID
    , cr.HADM_ID
    , cr.charttime
    , cr.creat
    , case
        -- 3x baseline
        when cr.creat >= (cr.creat_low_past_7d*3.0) then 3
        -- *OR* cr >= 4.0 with associated increase
        when cr.creat >= 4
        -- For patients reaching Stage 3 by SCr >4.0 mg/dl
        -- require that the patient first achieve ... acute increase >= 0.3 within 48 hr
        -- *or* an increase of >= 1.5 times baseline
        and (cr.creat_low_past_48hr <= 3.7 OR cr.creat >= (1.5*cr.creat_low_past_7d))
            then 3 
        -- TODO: initiation of RRT
        when cr.creat >= (cr.creat_low_past_7d*2.0) then 2
        when cr.creat >= (cr.creat_low_past_48hr+0.3) then 1
        when cr.creat >= (cr.creat_low_past_7d*1.5) then 1
    else 0 end as aki_stage_creat
  FROM `mimiciii-328704.mimicself.creatinine` cr
)
-- stages for UO / creat
, uo_stg as
(
  select
      uo.SUBJECT_ID
    , uo.HADM_ID
    , uo.icustay_id
    , uo.charttime
    , uo.weight
    , uo.uo_rt_6hr
    , uo.uo_rt_12hr
    , uo.uo_rt_24hr
    -- AKI stages according to urine output
    , CASE
        WHEN uo.uo_rt_6hr IS NULL THEN NULL
        -- require patient to be in ICU for at least 6 hours to stage UO
        WHEN uo.charttime <= DATETIME_ADD(ie.intime, INTERVAL '6' HOUR) THEN 0
        -- require the UO rate to be calculated over half the period
        -- i.e. for uo rate over 24 hours, require documentation at least 12 hr apart
        WHEN uo.uo_tm_24hr >= 11 AND uo.uo_rt_24hr < 0.3 THEN 3
        WHEN uo.uo_tm_12hr >= 5 AND uo.uo_rt_12hr = 0 THEN 3
        WHEN uo.uo_tm_12hr >= 5 AND uo.uo_rt_12hr < 0.5 THEN 2
        WHEN uo.uo_tm_6hr >= 2 AND uo.uo_rt_6hr  < 0.5 THEN 1
    ELSE 0 END AS aki_stage_uo
  from `mimiciii-328704.mimicself.uo_in_unit` uo
  INNER JOIN `physionet-data.mimiciii_clinical.icustays` ie
    ON uo.icustay_id = ie.icustay_id
)
-- get all charttimes documented
, tm_stg AS
(
    SELECT tb.SUBJECT_ID, tb.HADM_ID, tb.charttime, uo_stg.icustay_id FROM
    (
        SELECT
        SUBJECT_ID, HADM_ID, charttime
        FROM cr_stg
        UNION DISTINCT
        SELECT
        SUBJECT_ID, HADM_ID, charttime
        FROM uo_stg
    ) tb
    INNER JOIN uo_stg
    ON uo_stg.SUBJECT_ID = tb.SUBJECT_ID
)
select
  ie.icustay_id
  , tm.charttime
  , cr.creat
  , cr.aki_stage_creat
  , uo.uo_rt_6hr
  , uo.uo_rt_12hr
  , uo.uo_rt_24hr
  , uo.aki_stage_uo
  -- Classify AKI using both creatinine/urine output criteria
  , GREATEST(
      COALESCE(cr.aki_stage_creat, 0),
      COALESCE(uo.aki_stage_uo, 0)
    ) AS aki_stage
FROM `physionet-data.mimiciii_clinical.icustays` ie
-- get all possible charttimes as listed in tm_stg
LEFT JOIN tm_stg tm
  ON ie.icustay_id = tm.icustay_id
LEFT JOIN cr_stg cr
  ON ie.SUBJECT_ID = cr.SUBJECT_ID
  AND tm.charttime = cr.charttime
LEFT JOIN uo_stg uo
  ON ie.icustay_id = uo.icustay_id
  AND tm.charttime = uo.charttime
WHERE
  cr.creat is not null OR uo.aki_stage_uo is not null
order by ie.icustay_id, tm.charttime;