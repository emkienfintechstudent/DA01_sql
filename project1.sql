-------------------------------1----------------------------------------------------------------
alter table public.sales_dataset_rfm_prj
alter column ordernumber type int USING (trim(ordernumber)::integer),
alter column quantityordered type int USING (trim(ordernumber)::integer),
alter column priceeach type float USING (trim(ordernumber)::integer),
alter column orderlinenumber type int USING (trim(ordernumber)::integer),
alter column sales type float USING (trim(ordernumber)::integer),
alter column orderdate type TIMESTAMP USING orderdate::TIMESTAMP,
alter column msrp type int USING (trim(msrp)::integer)
-------------------------------2----------------------------------------------------------------
select ORDERNUMBER from public.sales_dataset_rfm_prj
where ORDERNUMBER is null or QUANTITYORDERED is null 
or PRICEEACH is null or ORDERLINENUMBER is null 
or SALES is null or ORDERDATE is null 
-------------------------------3----------------------------------------------------------------  
update public.sales_dataset_rfm_prj
set contactlastname = left(contactfullname,position('-'in contactfullname)-1),
set contactfirstname = right(contactfullname,length (contactfullname)- position('-'in contactfullname))
-------------------------------4----------------------------------------------------------------  
update public.sales_dataset_rfm_prj 
set contactfirstname = INITCAP(contactfirstname);
update public.sales_dataset_rfm_prj 
set contactfirstname = INITCAP(contactfirstname)
-------------------------------5----------------------------------------------------------------  
update sales_dataset_rfm_prj
set QTR_ID  = EXTRACT(QUARTER FROM  orderdate);
update sales_dataset_rfm_prj
set MONTH_ID =  EXTRACT(month FROM  orderdate);
update sales_dataset_rfm_prj
set YEAR_ID = EXTRACT(year FROM  orderdate)
-------------------------------6----------------------------------------------------------------
-------Cách 1--------
WITH CTE as (select Q1 - 1.5*IQR as min, Q3 + 1.5*IQR as max from  (
select percentile_cont(0.25) within group (order by QUANTITYORDERED) as Q1,
percentile_cont(0.75) within group (order by QUANTITYORDERED) as Q3,
percentile_cont(0.75) within group (order by QUANTITYORDERED) - percentile_cont(0.25) within group (order by QUANTITYORDERED) as IQR  
from sales_dataset_rfm_prj 
) as t)

select QUANTITYORDERED from sales_dataset_rfm_prj 
where  QUANTITYORDERED > (select max from CTE)  or QUANTITYORDERED <(select min from CTE)
-------Cách 2--------
with cte as (
select quantityordered, (select  avg(quantityordered) from sales_dataset_rfm_prj)  as avg,
 (select stddev(quantityordered) from sales_dataset_rfm_prj)  as std 
	from public.sales_dataset_rfm_prj)
select ((quantityordered -avg) / std) as z_score from  cte
where ((quantityordered -avg) / std)  >2








