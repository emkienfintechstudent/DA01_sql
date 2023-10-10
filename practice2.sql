--ex1
select distinct CITY from STATION 
WHERE ID % 2 = 0
--ex2
  SELECT COUNT(ID) - COUNT(DISTINCT CITY) FROM STATION
--ex3
  Select ceil(AVG(Salary) - avg(replace(Salary,0,''))) from EMPLOYEES
--ex5
SELECT ROUND(SUM(item_count::DECIMAL*order_occurrences)/SUM(order_occurrences),1) AS mean
FROM items_per_order;
