-------------------------------------------------------------------EX1----------------------------------------------------------------------------------------------------
WITH cte
AS (
	SELECT extract(year FROM transaction_date) AS year
		,product_id
		,spend
	FROM user_transactions
	)
SELECT year
	,product_id
	,spend AS curr_year_spend
	,lag(spend) OVER (
		PARTITION BY product_id ORDER BY year
		) AS prev_year_spend
	,round(100 * (spend - lag(spend) OVER (PARTITION BY product_id)) / (lag(spend) OVER (PARTITION BY product_id)), 2) AS yoy_rate
FROM cte 
-------------------------------------------------------------------EX2----------------------------------------------------------------------------------------------------
WITH cte
AS (
	SELECT issue_month
		,card_name
		,first_value(issued_amount) OVER (
			PARTITION BY card_name ORDER BY issue_year
				,issue_month
			) AS issued_amount
	FROM monthly_cards_issued
	)
SELECT card_name
	,issued_amount
FROM cte
GROUP BY card_name
	,issued_amount
ORDER BY issued_amount DESC

	-- cách 2 
	SELECT  card_name, 
  FIRST_VALUE(issued_amount) OVER (PARTITION BY card_name ORDER BY issue_year
				,issue_month) as amount
FROM monthly_cards_issued
ORDER BY amount DESC; 
-------------------------------------------------------------------EX3----------------------------------------------------------------------------------------------------
SELECT t.user_id
	,t.spend
	,t.transaction_date
FROM (
	SELECT user_id
		,transaction_date
		,spend
		,row_number() OVER (
			PARTITION BY user_id ORDER BY transaction_date
			)
	FROM transactions
	) AS t
WHERE row_number = 3
-------------------------------------------------------------------EX4----------------------------------------------------------------------------------------------------

SELECT t.transaction_date
	,t.user_id
	,count(*)
FROM (
	SELECT user_id
		,transaction_date
		,count(*) OVER (PARTITION BY user_id) AS purchase_count
		,rank() OVER (
			PARTITION BY user_id ORDER BY transaction_date DESC
			) AS rank
	FROM user_transactions
	) AS t
WHERE t.rank = 1
GROUP BY t.transaction_date
	,t.user_id
-------------------------------------------------------------------EX5----------------------------------------------------------------------------------------------------
WITH cte1
AS (
	SELECT user_id
		,tweet_date
		,tweet_count AS cur_tweet
		,lag(tweet_count) OVER (
			PARTITION BY user_id ORDER BY tweet_date
			) AS before_date
	FROM tweets
	)
	,-- lấy ra số tweet của 3 ngày trước 
cte2
AS (
	SELECT user_id
		,tweet_date
		,COALESCE(cur_tweet, 0) + COALESCE(before_date, 0) + coalesce(lag(before_date) OVER (
				PARTITION BY user_id ORDER BY tweet_date
				), 0) AS sum
		,row_number() OVER (
			PARTITION BY user_id ORDER BY tweet_date
			) AS rank
	FROM cte1
	) -- lấy ra số tweet của 2 ngày trước sau đó cộng số tweet của 3 ngày trước + 2 ngày trước + ngày hiện tại
SELECT user_id
	,tweet_date
	,CASE 
		WHEN rank = 1
			THEN round(sum / 1, 2)
		WHEN rank = 2
			THEN round(sum / 2::DECIMAL, 2)
		ELSE round(sum / 3::DECIMAL, 2)
		END AS rolling_avg_3d
FROM cte2
-------------------------------------------------------------------EX6----------------------------------------------------------------------------------------------------
	
WITH cte
AS (
	SELECT merchant_id
		,credit_card_id
		,amount
		,transaction_timestamp
		,EXTRACT(hour FROM transaction_timestamp - lag(transaction_timestamp) OVER (
				PARTITION BY merchant_id
				,credit_card_id
				,amount
				)) * 60 + eXTRACT(minute FROM transaction_timestamp - lag(transaction_timestamp) OVER (
				PARTITION BY merchant_id
				,credit_card_id
				,amount
				)) AS TIME
	FROM transactions
	)
SELECT COUNT(*) AS payment_count
FROM cte
WHERE TIME BETWEEN 0
		AND 10
-------------------------------------------------------------------EX7----------------------------------------------------------------------------------------------------
with cte as (select category, product, sum(spend)  OVER(PARTITION BY category, product )
from product_spend 
where EXTRACT(year from transaction_date) =2022), -- lấy ra năm 2022 đã 
cte2 as (
SELECT category,product,sum as total_spend,RANK() OVER(PARTITION BY category ORDER BY sum desc) as rank from cte
group by category,product,sum) -- lấy ra tổng và xếp hạng 
select category,product, total_spend from cte2 
where rank = 1 or rank =2 -- lấy ra 2 cái cao nhất 
-------------------------------------------------------------------EX8----------------------------------------------------------------------------------------------------
with cte as(SELECT artist_name,dense_RANK() OVER(ORDER BY count(*) desc) as artist_rank FROM artists as a 
	join songs as b on a.artist_id=b.artist_id 
	join global_song_rank as c
on b.song_id = c.song_id
where rank <= 10 
group by artist_name)

select artist_name,artist_rank from cte 
where artist_rank <=5
