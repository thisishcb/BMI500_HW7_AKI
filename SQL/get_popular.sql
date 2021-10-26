WITH allitms AS
(
    SELECT 
        li.ITEMID
        , li.LABEL
        , COUNT(dt.SUBJECT_ID) AS NUM_OCCUR
    FROM `physionet-data.mimiciii_clinical.d_labitems` li
    INNER JOIN `mimiciii-328704.mimicself.data_before_aki` dt
    ON li.ITEMID = dt.ITEMID
    GROUP BY ITEMID, LABEL 
)
SELECT * from allitms 
WHERE NUM_OCCUR > 10000
ORDER BY NUM_OCCUR