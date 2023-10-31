/*      Ecommerce Dataset: Exploratory Data Analysis (EDA) and Cohort Analysis in SQL
Mô tả dataset: 
1. TheLook là một trang web thương mại điện tử về quần áo. Tập dữ liệu chứa thông tin về customers, products, orders, logistics, web events , digital marketing campaigns
2. Các bảng 
+ distribution_centers -> chứa vị trí về vĩ độ và kinh độ của các thành phố ở các bang
+ event: chứa thông tin về các sự kiện diễn ra (truy cập ở nền tảng nào, truy cập qua đâu, các thông tin liên quan đến địa chỉ ip...)
+ inventory_items: các thông tin về sản phẩm trong kho 
+ orders_items: các thông tin về trạng thái đơn hàng 
+ order: chứa thông tin về đơn hàng gồm (mã khách hàng, mã đơn hàng,trạng thái, thời gian tạo)
+ products: chứa thông tin về sản phẩm 
+ users: thông tin về khách hàng 
*/

--- I. Ad-hoc tasks 
---- 1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
---- 1.1 Thống kê tổng số lượng người mua đã hoàn thành đơn hàng và số lượng đơn hàng mỗi tháng ( Từ 1/2019-4/2022)
select 
Extract(year from created_at) ||'-'|| Extract(month from created_at) as month_year,
count(order_id) as  total_order, 
count(distinct user_id) as total_user 
from bigquery-public-data.thelook_ecommerce.orders
WHERE DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
group by 1
order by 1
/*  -- Kết luận 
số lượng đơn hàng và số lượng khách hàng gia tăng qua từng tháng và từng năm nhưng gia tăng đột biến và các tháng cuối năm sau đó giảm mạnh vào đầu tháng năm sau 
=> nhu cầu mua sắm cuối năm tăng cao */

------2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
-- Lấy ra số khách hàng khác nhau mỗi tháng, số đơn hàng 
with cte as  (select 
Extract(year from created_at) ||'-'|| Extract(month from created_at) as month_year,
count(order_id) as  total_order, 
count(distinct user_id) as total_user 
from bigquery-public-data.thelook_ecommerce.orders
WHERE DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
group by 1
order by 1),
--lấy ra tổng số hóa đơn cho mỗi đơn hàng mỗi tháng 
 total_each_order as (
select Extract(year from created_at) ||'-'|| Extract(month from created_at) as month_year, 
sum(sale_price) as sum
from bigquery-public-data.thelook_ecommerce.order_items
WHERE DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
group by 1
)
select a.month_year,a.sum/b.total_order as average_order_value,b.total_user as distinct_users 
from total_each_order as a join cte as b
on a.month_year=b.month_year
order by 1

------3. Nhóm khách hàng theo độ tuổi
-- find the smallest age and largest age for each gender
with min_max_age as 
(select gender,min(age) as min_age,max(age) as max_age 
from bigquery-public-data.thelook_ecommerce.users
group by gender
),
-- male customers (youngest + oldest)
male as 
(select first_name, last_name, gender,age ,
case 
when age = (select min_age from min_max_age where gender='M') then 'youngest'
else 'oldest' end as tag 
from bigquery-public-data.thelook_ecommerce.users
where gender ='M' 
and (age = (select min_age from min_max_age where gender='M') or age = (select max_age from min_max_age where gender='M'))),
--female customers (youngest + oldest)
female as  (select first_name, last_name, gender,age ,
case 
when age = (select min_age from min_max_age where gender='F') then 'youngest'
else 'oldest' end as tag 
from bigquery-public-data.thelook_ecommerce.users
where gender ='F' 
and (age = (select min_age from min_max_age where gender='F') or age = (select max_age from min_max_age where gender='F')))
-- male + female (youngest + oldest)
-- lưu vào temp sau đó count 
SELECT * FROM male
union all 
select*from female

------4.Top 5 sản phẩm mỗi tháng.
-- lọc ra month_year ( yyyy-mm), product_id, product_name, sales, cost, profit
with cte as 
(select Extract(year from created_at) ||'-'|| Extract(month from created_at) as month_year, 
a.product_id,b.name as product_name,
sum(a.sale_price) as sales,
sum(b.cost) as cost,
sum(a.sale_price)-sum(b.cost) as profit,
from bigquery-public-data.thelook_ecommerce.order_items as a join bigquery-public-data.thelook_ecommerce.products as b
on a.product_id = b.id
where DATE(created_at) BETWEEN '2019-01-01' AND '2022-04-30'
group by 1,2,3)
-- xếp hạng 
select * from 
(select month_year, product_id, product_name, sales, cost, profit,
dense_rank() over(partition by month_year order by profit desc) as rank_per_month from cte
order by month_year
  ) as t 
  where rank_per_month <=5
------5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
-- lọc ra dates (yyyy-mm-dd), product_categories, revenue
select date(created_at), 
b.category as product_categories,
sum(a.sale_price) as revenue,
from bigquery-public-data.thelook_ecommerce.order_items as a join bigquery-public-data.thelook_ecommerce.products as b
on a.product_id = b.id
where DATE(created_at) BETWEEN '2022-02-15' AND '2022-04-15'
group by 1,2
order by 1

--------III. Tạo metric trước khi dựng dashboard
lấy ra những dữ liệu cần thiết
with cte as  (select c.user_id,b.category as product_category, date(c.created_at) as date ,a.sale_price as sale,
a.order_id,b.cost from
bigquery-public-data.thelook_ecommerce.order_items as a 
join  bigquery-public-data.thelook_ecommerce.products as b
on a.product_id = b.id 
join bigquery-public-data.thelook_ecommerce.orders as c 
on a.order_id = c.order_id),
--tìm index và ép date về 
cte1 as 
(select FORMAT_DATETIME('%Y-%m', date)||'-'||'01' AS month,extract(year from date) as year,product_category, sale,order_id,cost from cte)

select 
 Month,
 year,
product_category,
sum(sale) as TPV,
count(distinct order_id) as  TPO,

round(100*(sum(sale) - lag(SUM(sale))  over(partition by product_category order by month)/lag(SUM(sale)) over(partition by product_category order by month)),2) || '%' as Revenue_growth,
round(100*(count(order_id) - lag(count(order_id))  over(partition by product_category order by month)/lag(count(order_id)) over(partition by product_category order by  month)),2) || '%' as Order_growth,
sum(cost) as total_cost,
 sum(sale) - sum(cost) as  Total_profit,
sum(sale)/ sum(cost) as Profit_to_cost_ratio
  from cte1 
  group by month ,
year ,
product_category
order by product_category
