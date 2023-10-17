/*--------------------------------------------------------EX1 --------------------------------------------------------------------------*/
SELECT count(a.company_id) AS duplicate_companies -- đếm số job trùng  
FROM (
	SELECT company_id
		,title
		,description
		,count(job_id)
	FROM job_listings -- dùng subquery để lấy ra các job trùng 
	GROUP BY company_id
		,title
		,description
	HAVING count(job_id) > 1
	) AS a;



/*--------------------------------------------------------EX2 --------------------------------------------------------------------------*/
WITH total_spend1
AS (
	SELECT category
		,product
		,sum(spend) AS total_spend
	FROM product_spend
	WHERE category = 'appliance'
		AND EXTRACT(year FROM transaction_date) = '2022'
	GROUP BY product
		,category
	ORDER BY total_spend DESC limit 2
	)
	,-- lấy tổng số tiền sản phẩm từ danh mục appliance 
total_spend2
AS (
	SELECT category
		,product
		,sum(spend) AS total_spend
	FROM product_spend
	WHERE category = 'electronics'
		AND EXTRACT(year FROM transaction_date) = '2022'
	GROUP BY product
		,category
	ORDER BY total_spend DESC limit 2
	) -- lấy tổng số tiền sản phẩm từ danh mục electronics
SELECT *
FROM total_spend1
UNION ALL
SELECT *
FROM total_spend2
	--nối 2 bảng lại với nhau
/*--------------------------------------------------------EX4--------------------------------------------------------------------------*/
SELECT p.page_id
FROM pages AS p
LEFT JOIN page_likes AS pl ON p.page_id = pl.page_id
WHERE pl.user_id IS NULL
ORDER BY p.page_id
 /*--------------------------------------------------------EX5--------------------------------------------------------------------------*/ 
WITH current_month
AS (
	SELECT EXTRACT(month FROM event_date) AS curr_month
	FROM user_actions
	ORDER BY EXTRACT(month FROM event_date) DESC limit 1
	)
	,-- lấy ra tháng hiện tại 
before_month
AS (
	SELECT EXTRACT(month FROM event_date) - 1 AS bef_month
	FROM user_actions
	ORDER BY EXTRACT(month FROM event_date) DESC limit 1
	)
	,-- lấy ra tháng trước
user_active_current_month
AS (
	SELECT DISTINCT user_id
	FROM user_actions
	WHERE EXTRACT(month FROM event_date) = (
			SELECT curr_month
			FROM current_month
			)
	)
	,-- lấy ra user hoạt động tháng này
user_active_before_month
AS (
	SELECT DISTINCT user_id
	FROM user_actions
	WHERE EXTRACT(month FROM event_date) = (
			SELECT bef_month
			FROM before_month
			)
	) -- lấy ra user hoạt động tháng trước 
SELECT (
		SELECT curr_month
		FROM current_month
		) AS month
	,count(*) AS monthly_active_users
FROM user_active_current_month AS a
JOIN user_active_before_month AS b ON a.user_id = b.user_id
	
 /*--------------------------------------------------------EX7--------------------------------------------------------------------------*/ 

WITH min_year
AS (
	SELECT product_id
		,min(year) AS minyear
	FROM Sales
	GROUP BY product_id
	)
SELECT a.product_id
	,a.year AS first_year
	,a.quantity
	,a.price
FROM Sales AS a
JOIN min_year AS b ON a.product_id = b.product_id
WHERE b.minyear = a.year

/*--------------------------------------------------------EX8--------------------------------------------------------------------------*/ 
WITH cte
AS (
	SELECT customer_id
		,product_key
	FROM Customer
	GROUP BY customer_id
		,product_key
	)
SELECT customer_id
FROM cte
GROUP BY customer_id
HAVING count(*) = (
		SELECT count(DISTINCT product_key)
		FROM Product
		)
ORDER BY customer_id
/*--------------------------------------------------------EX9--------------------------------------------------------------------------*/ 
SELECT employee_id
FROM Employees
WHERE salary < 30000
	AND manager_id NOT IN (
		SELECT employee_id
		FROM Employees
		)
ORDER BY employee_id
/*--------------------------------------------------------EX10 trùng EX 1--------------------------------------------------------------------------*/ 
/*--------------------------------------------------------EX11 --------------------------------------------------------------------------*/
-- Write your PostgreSQL query statement below
WITH cte
AS (
	SELECT a.name AS results
	FROM Users AS a
	JOIN MovieRating AS b ON a.user_id = b.user_id
	GROUP BY a.name
	ORDER BY count(*) DESC
		,a.name limit 1
	)
	,cte2
AS (
	SELECT c.title AS results
	FROM Movies AS c
	JOIN MovieRating AS d ON c.movie_id = d.movie_id
	WHERE extract(month FROM d.created_at) = 2
		AND extract(year FROM d.created_at) = 2020
	GROUP BY c.title
	ORDER BY avg(rating) DESC
		,c.title limit 1
	)
SELECT *
FROM cte

UNION ALL

SELECT *
FROM cte2
/*--------------------------------------------------------EX12 --------------------------------------------------------------------------*/
WITH cte
AS (
	SELECT requester_id AS id
		,count(*) AS count
	FROM RequestAccepted
	GROUP BY requester_id
	)
	,cte1
AS (
	SELECT accepter_id AS id
		,count(*) AS count
	FROM RequestAccepted
	GROUP BY accepter_id
	)
SELECT id
	,sum(count) AS num
FROM (
	SELECT *
	FROM cte
	
	UNION ALL
	
	SELECT *
	FROM cte1
	)
GROUP BY id
ORDER BY num DESC limit 1














