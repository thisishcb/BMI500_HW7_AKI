SELECT * FROM `physionet-data.mimiciii_clinical.d_labitems` 
    where LABEL like "%rine%" AND LABEL like "%olume%" OR 
    LABEL like "%reatinine%" AND LABEL like "%erum%" OR 
    LABEL like "%reatinine%" AND FLUID = "Blood" OR
    LABEL like "%GFR%"
    ORDER BY ROW_ID ASC;
-- ROW_ID	ITEMID	LABEL	FLUID	CATEGORY	LOINC_CODE
-- 113  50912   Creatinine  Blood   Chemistry   2160-0
-- 121	50920	Estimated GFR (MDRD equation)	Blood	Chemistry	33914-3
-- 281	51081	Creatinine, Serum	Urine	Chemistry	
-- 308	51108	Urine Volume	Urine	Chemistry	28009-9
-- 309	51109	Urine Volume, Total	Urine	Chemistry	28009-9
