-- public.soh_update_pwb_3q_2025 source

CREATE OR REPLACE VIEW public.soh_update_pwb_3q_2025
AS WITH master AS (
         SELECT DISTINCT dm.date,
            su.code
           FROM date_master dm
             CROSS JOIN ( SELECT DISTINCT concat(p.bu, p.stcode) AS code
                   FROM plan2025 p) su
          WHERE dm.date >= '2025-01-01'::date AND dm.date <= '2025-12-31'::date AND su.code ~~ 'PWB%'::text
        ), master_with_week AS (
         SELECT m.code,
            m.date,
            date_part('week'::text, m.date) AS week_number
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
             LEFT JOIN soh_update_pwb_3q su2 ON m.code = su2.code AND m.date = to_date(su2."DATE", 'YYYYMMDD'::text)
        ), deduplicated_data AS (
         SELECT ranked_data.code,
            ranked_data.week_number,
            ranked_data.food_credit,
            ranked_data.nonfood_consign,
            ranked_data.perishable_nonmer,
            ranked_data.totalsoh,
            ranked_data.rank,
            row_number() OVER (PARTITION BY ranked_data.code, ranked_data.week_number ORDER BY ranked_data.rank, ranked_data.date) AS row_num
           FROM ranked_data
          WHERE ranked_data.totalsoh IS NOT NULL AND ranked_data.week_number <= date_part('week'::text, CURRENT_DATE) OR ranked_data.week_number >= date_part('week'::text, CURRENT_DATE)
        )
 SELECT code,
    week_number,
    food_credit,
    nonfood_consign,
    perishable_nonmer,
    totalsoh
   FROM deduplicated_data
  WHERE row_num = 1
  ORDER BY code, week_number;
