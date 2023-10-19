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
