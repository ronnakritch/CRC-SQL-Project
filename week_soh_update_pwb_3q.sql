WITH master AS (
    SELECT DISTINCT dm.date,
           su.code
      FROM date_master dm
           CROSS JOIN (SELECT DISTINCT concat(p.bu, p.stcode) AS code
                       FROM plan2025 p) su
     WHERE dm.date BETWEEN '2025-01-01'::date AND '2025-12-31'::date
), master_with_week AS (
    SELECT m.code,
           m.date,
           date_part('week', m.date) AS week_number
      FROM master m
), ranked_data AS (
    SELECT m.code,
           m.date,
           m.week_number,
           su2.food_credit,
           su2.nonfood_consign,
           su2.perishable_nonmer,
           su2.totalsoh,
           row_number() OVER (PARTITION BY m.code, m.week_number ORDER BY m.date) AS rank
      FROM master_with_week m
           LEFT JOIN soh_update_pwb_3q su2
           ON m.code = su2.code::text AND m.date = to_date(su2."DATE"::text, 'YYYYMMDD')
), deduplicated_data AS (
    SELECT code,
           week_number,
           food_credit,
           nonfood_consign,
           perishable_nonmer,
           totalsoh,
           rank,
           row_number() OVER (PARTITION BY code, week_number ORDER BY rank, date) AS row_num
      FROM ranked_data
     WHERE totalsoh IS NOT NULL
)
SELECT code,
       week_number,
       food_credit,
       nonfood_consign,
       perishable_nonmer,
       totalsoh
  FROM deduplicated_data
 WHERE row_num = 1 -- Keep only the first row per combination of code and week_number
 ORDER BY code, week_number;
