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
--EX4

