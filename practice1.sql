-- ex 1
  SELECT NAME FROM CITY 
WHERE POPULATION >120000 AND COUNTRYCODE ='USA'
--EX2 
SELECT * FROM CITY 
WHERE COUNTRYCODE ='JPN'
--EX3 
SELECT CITY,STATE FROM STATION 
--EX4
SELECT DISTINCT CITY FROM STATION 
WHERE CITY LIKE 'a%' or CITY LIKE 'e%' or CITY LIKE 'i%' or CITY LIKE 'o%' or CITY LIKE 'u%';
--EX5
SELECT distinct CITY FROM STATION 
WHERE CITY LIKE '%a' or CITY LIKE '%e' or CITY LIKE '%o' or CITY LIKE '%i' or CITY LIKE '%u' ;
--EX6
select DISTINCT CITY FROM STATION 
WHERE CITY NOT LIKE 'a%' and CITY NOT LIKE 'e%' and CITY NOT LIKE 'i%' and CITY NOT LIKE 'o%' and CITY NOT LIKE 'u%';
--EX7
SELECT name from Employee
order by name
--EX8
select name from Employee 
where salary > 2000 and months < 10 
-- EX9 
select product_id from Products 
where low_fats ='Y' and recyclable = 'Y';
--EX10
select name from Customer 
where referee_id <> 2 or referee_id is null ;
--EX 11
select name,population,area from World
where area >= 3000000 or population >= 25000000;
--EX12 
select distinct author_id as id from Views 
where author_id = viewer_id
order by id
--EX13
select part, assembly_step from parts_assembly
where finish_date is NULL;
--EX14
SELECT * FROM lyft_drivers 
where yearly_salary < 30000 or yearly_salary >= 70000
--EX15
select *from uber_advertising
where money_spent > 100000
