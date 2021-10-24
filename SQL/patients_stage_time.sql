WITH aki AS
(
    SELECT
        ic.SUBJECT_ID
        , ks.icustay_id
        , ks.aki_stage
        , ks.charttime
    from `physionet-data.mimiciii_derived.kdigo_stages` ks
    INNER JOIN `physionet-data.mimiciii_clinical.icustays` ic
    ON ic.icustay_id = ks.icustay_id
    WHERE ks.charttime is not null
    GROUP BY icustay_id, SUBJECT_ID
)
, main AS
(
    SELECT
        subj.SUBJECT_ID
        , subj.GENDER
        , MAX(aki.aki_stage) AS aki_stage
    from `physionet-data.mimiciii_clinical.patients` subj
    INNER JOIN `physionet-data.mimiciii_derived.kdigo_stages` aki
    ON subj.SUBJECT_ID = aki.SUBJECT_ID
    GROUP BY SUBJECT_ID
)
SELECT
    main.SUBJECT_ID
    , main.GENDER
    , main.AKI_STAGE
    , MIN(aki.charttime) AS STAGE_TIME
FROM main
INNER JOIN `physionet-data.mimiciii_derived.kdigo_stages` aki
ON main.SUBJECT_ID = aki.SUBJECT_ID
AND subj.aki_stage = aki.aki_stage
GROUP BY SUBJECT_ID, aki_stage