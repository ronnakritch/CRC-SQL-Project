create view soh_update_pwb_3q
as select 
concat('PWB',lpad(pwb_soh.msstor, 5, '0'::text)) as code,
'PWB' as bu,
lpad(pwb_soh.msstor, 5, '0'::text) AS store_code,
pwb_soh.msasdt AS data_date,
"left"(pwb_soh.msasdt, 4) AS year,
'3Q'::text AS atype,
sum(
        CASE
            WHEN mstype = '1'::text THEN msstoh::numeric
            ELSE 0::numeric
        END) AS food_credit,
    sum(
        CASE
            WHEN mstype = '2'::text THEN msstoh::numeric
            ELSE 0::numeric
        END) AS nonfood_consign,
    sum(
        CASE
            WHEN mstype = '3'::text THEN msstoh::numeric
            ELSE 0::numeric
        END) AS perishable_nonmer,
    sum(msstoh::numeric) AS totalsoh
from pwb_soh 
where (msdept = '01' and mssdpt in ('02','03','04'))
or (msdept = '02')
or (msdept = '09' and mssdpt in ('06','08','09'))
or (msdept = '10' and mssdpt in ('01','02','03'))
or (msdept = '11' and mssdpt in ('01','02','03','05'))
or (msdept = '12' and mssdpt in ('01','06','07'))
or (msdept = '15' and mssdpt in ('01','06','09','10'))
group by 
msstor,
msasdt
union all
select 
concat('PWB',lpad(pwb_uss_soh.stmerch, 5, '0'::text)) as code,
'PWB' as bu,
lpad(pwb_uss_soh.stmerch, 5, '0'::text) AS stcode,
pwb_uss_soh.asdate AS data_date,
"left"(pwb_uss_soh.asdate, 4) AS year,
'3Q'::text AS atype,
sum(
        CASE
            WHEN skutype = '1'::text THEN quant::numeric
            ELSE 0::numeric
        END) AS food_credit,
    sum(
        CASE
            WHEN skutype = '2'::text THEN quant::numeric
            ELSE 0::numeric
        END) AS nonfood_consign,
    sum(
        CASE
            WHEN skutype = '3'::text THEN quant::numeric
            ELSE 0::numeric
        END) AS perishable_nonmer,
    sum(quant::numeric) AS totalsoh
from pwb_uss_soh 
where (LPAD(deptcode,2,'0') = '01' and LPAD(subdeptcode,4,'0') in ('0102','0103','0104'))
or (LPAD(deptcode,2,'0') = '02')
or (LPAD(deptcode,2,'0') = '09' and LPAD(subdeptcode,4,'0') in ('0906','0908','0909'))
or (LPAD(deptcode,2,'0') = '10' and LPAD(subdeptcode,4,'0') in ('1001','1002','1003'))
or (LPAD(deptcode,2,'0') = '11' and LPAD(subdeptcode,4,'0') in ('1101','1102','1103','1105'))
or (LPAD(deptcode,2,'0') = '12' and LPAD(subdeptcode,4,'0') in ('1201','1206','1207'))
or (LPAD(deptcode,2,'0') = '15' and LPAD(subdeptcode,4,'0') in ('1501','1506','1509','1510'))
group by 
stmerch,
asdate
