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
-- em gộp tổng amount của ngày bằng group by dã 
with cte as ( 
select visited_on, sum(amount) as amount from Customer
group by visited_on
order by visited_on),
-- ngồi mãi ko nghĩ ra cách nào nên em chơi kiểu công nhân ạ, là cộng luôn từ 7 ngày trước đến ngày hiện --tại
cte1 as (
(select visited_on, amount 
+ lag(amount,6) over(order by visited_on)
+lag(amount,5) over(order by visited_on) 
+lag(amount,4) over(order by visited_on) 
+lag(amount,3) over(order by visited_on)
+lag(amount,2) over(order by visited_on)
+lag(amount,1) over(order by visited_on)
as sum  from cte))

select visited_on,sum as amount, round(sum/7::decimal,2) as average_amount from cte1
where sum is not null
-------------------------------------------------------------------------------- EX5--------------------------------------------------------------------------------
-- đến tiv_2015 và lat + lon
WITH cte AS (
  SELECT tiv_2015, tiv_2016, CONCAT(lat, lon) AS location, 
  COUNT(*) OVER (PARTITION BY CONCAT(lat, lon)) AS location_count,
  count(tiv_2015) over(partition by tiv_2015) as count_tiv_2015
  FROM Insurance
)
-- lọc ra tiv_2016 dựa trên số tiv_2015 >1 và số lat + lon =1
SELECT ROUND(SUM(total)::decimal, 2) AS tiv_2016
FROM ( 
  SELECT tiv_2015, sum(tiv_2016) AS total
  FROM cte
  WHERE location_count = 1 and count_tiv_2015 >1
   group by tiv_2015
)
-------------------------------------------------------------------------------- EX6--------------------------------------------------------------------------------
with cte as (select a.id, 
a.name,
a.salary,
a.departmentId,
b.name as department,
dense_rank() over(partition by departmentId order by salary desc) as rank1 
from Employee as a  join Department as b 
on a.departmentId = b.id )

select department,name as Employee ,salary from cte 
where rank1 <=3
-------------------------------------------------------------------------------- EX7--------------------------------------------------------------------------------
-- Tính tổng trọng lượng tuần tự theo người lên xe
with cte as (select person_name,
sum (weight) over(order by turn)  
from Queue)
-- lấy tất cả các người tính để khi khối lượng còn trụ được 1 tấn, --rồi sắp xếp ngược lại sau đó lấy người đầu tiên
select person_name from cte
where sum <=1000
order by sum desc 
 limit 1
-------------------------------------------------------------------------------- EX8--------------------------------------------------------------------------------
