--------------------------------------------------------------------------------EX1 --------------------------------------------------------------------------------
-- Trước tiên xếp hạng số thứ tự đơn hàng để biết được đơn hàng nào được đặt đầu tiên 
WITH cte
AS (
	SELECT customer_id
		,order_date
		,customer_pref_delivery_date
		,row_number() OVER (
			PARTITION BY customer_id ORDER BY order_date
			)
	FROM Delivery
	)
	,
	--đếm số lượng scheduled và immediate
cte1
AS (
	SELECT CASE 
			WHEN order_date = customer_pref_delivery_date
				THEN 'immediate'
			ELSE 'scheduled'
			END AS type
		,count(*)
	FROM cte
	WHERE row_number = 1
	GROUP BY type
	ORDER BY type
	)
-- tính tỉ lệ 
SELECT CASE 
		WHEN round(100 * count / (lead(count) OVER () + count)::DECIMAL, 2) IS NULL
			THEN 100
		ELSE round(100 * count / (lead(count) OVER () + count)::DECIMAL, 2)
		END AS immediate_percentage
FROM cte1 limit 1
--------------------------------------------------------------------------------EX2 --------------------------------------------------------------------------------
-------------  tìm chênh lệch ngày các player đăng nhập 
WITH cte
AS (
	SELECT player_id
		,device_id
		,event_date
		,row_number() OVER (PARTITION BY player_id) AS rank
		,(
			lead(event_date) OVER (
				PARTITION BY player_id ORDER BY event_date
				) - event_date
			) AS diff
	FROM activity
	)
	,
-------------  tình tổng số player
cte1
AS (
	SELECT count(*)
	FROM Activity
	GROUP BY player_id
	)
	,
	------------- lọc ra player đăng nhập lại trong 2 ngày sau ngày đầu 
cte2
AS (
	SELECT *
	FROM cte
	WHERE rank = 1
		AND diff <= 2
	)
SELECT round(count(*) / (
			SELECT count
			FROM cte1
			)::DECIMAL, 2)
FROM cte2

--------------------------------------------------------------------------------EX3 --------------------------------------------------------------------------------
-- lấy ra id của người cuối để nếu số lượng là lẻ thì sẽ giữ nguyên người đó
WITH cte
AS (
	SELECT student AS last
	FROM Seat
	ORDER BY id DESC limit 1
	)
  -- đổi chỗ 2 người liên tiếp -> dùng lead và lag 
	,cte1
AS (
	SELECT id
		,CASE 
			WHEN id % 2 = 0
				THEN lag(student) OVER ()
			ELSE lead(student) OVER ()
			END AS student
	FROM Seat
	)
  
SELECT id
	,CASE 
		WHEN student IS NULL -- nếu nó null tức là đó là người cuối cùng của số lẻ 
			THEN (
					SELECT last
					FROM cte
					)
		ELSE student
		END
FROM cte1
-------------------------------------------------------------------------------- EX4 --------------------------------------------------------------------------------
-- lấy ra tổng số tiền tính đến ngày hiện tại

select customer_id,name,visited_on, sum(amount) over(order by visited_on ) from Customer
-- lấy ra các ngày từ ngày đầu tiên trở đi 