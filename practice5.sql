---ex1
select a.CONTINENT, FLOOR (avg(b.POPULATION)) from COUNTRY as a INNER join CITY as b 
on a.CODE =b.COUNTRYCODE
GROUP BY a.CONTINENT
--ex2
SELECT ROUND(sum(CASE 
				WHEN b.signup_action = 'Confirmed'
					THEN 1
				ELSE 0
				END)::DECIMAL / count(*), 2)
FROM emails AS a
INNER JOIN texts AS b ON a.email_id = b.email_id
--ex3 
SELECT age_bucket,
	ROUND(100*sum(CASE 
			WHEN ac.activity_type = 'send'
				THEN ac.time_spent
			END) :: DECIMAL /sum(CASE 
			WHEN ac.activity_type in ('open','send')
				THEN ac.time_spent
			END),2) as send_perc
	, ROUND(100* sum(CASE 
			WHEN ac.activity_type = 'open'
				THEN ac.time_spent
			END) :: DECIMAL /sum(CASE 
			WHEN ac.activity_type in ('open','send')
				THEN ac.time_spent
			END),2) as open_perc
FROM activities AS ac
JOIN age_breakdown AS ab ON ac.user_id = ab.user_id
GROUP BY ab.age_bucket
--ex4
SELECT customer_id FROM customer_contracts as a 
inner join 
products as b on a.product_id = b.product_id
GROUP BY customer_id
having count(distinct b.product_category) = 3
	
--EX5
SELECT a.employee_id
	,a.name
	,count(b.reports_to) AS reports_count
	,round(avg(b.age)) AS average_age
FROM Employees AS a
INNER JOIN Employees AS b ON a.employee_id = b.reports_to
GROUP BY a.employee_id
	,a.name
ORDER BY a.employee_id
--ex6 
select a. product_name,sum(b.unit) as unit from  Products as a inner join Orders as b 
on a.product_id = b.product_id 
where b.order_date between '2020-02-01' and '2020-02-29'
 group by a.product_name
 having sum(b.unit)>=100
 order by sum(b.unit) desc
--ex7 
SELECT p.page_id FROM pages as p LEFT JOIN page_likes as pl 
on p.page_id = pl.page_id
where pl.user_id is null
order by p.page_id
