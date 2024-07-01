---ex1
SELECT sum(case when device_type = 'laptop' then 1
 else 0 end) as laptop_views 
,sum(case when device_type = 'tablet' or device_type ='phone' then 1
 else 0 end) as mobile_views from viewership
--ex2
select x,y,z, case when x+y>z and x+z>y and y+z>x then 'Yes'
else 'No' end as triangle
from Triangle
--ex3 
select round(100.0* sum(CASE
when call_category is null or call_category ='n/a' then 1
else 0 end) /count(case_id),1) as   uncategorised_call_pct

from callers
--ex4 
select name from Customer 
where referee_id != 2 or referee_id is null

 -- Cách 2 
 select
    name
from
    Customer
where
    referee_id IS DISTINCT FROM 2;
--ex5
select survived, sum(case when pclass =1 then 1 else 0 end ) as first_class,
sum(case when pclass =2 then 1 else 0 end ) as second_class,
sum(case when pclass =3 then 1 else 0 end ) as third_class
from titanic
group by survived
