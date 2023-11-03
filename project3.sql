-----------------------1) Doanh thu theo từng ProductLine, Year  và DealSize?----------------------------------------------------------------------
select productline,YEAR_ID, DEALSIZE, sum(sales) as REVENUE from public.sales_dataset_rfm_prj
group by productline,YEAR_ID, DEALSIZE

-----------------------2) Đâu là tháng có bán tốt nhất mỗi năm?----------------------------------------------------------------------
select year_id,month_ID,ORDER_NUMBER from
(select year_id,
 	month_ID, 
 	sum(sales) as REVENUE,count(ordernumber) as ORDER_NUMBER, 
 	rank() over(partition by year_id order by sum(sales),count(ordernumber))
 from public.sales_dataset_rfm_prj
group by year_id,month_ID) as t
where rank =1
  
-----------------------3) Product line nào được bán nhiều ở tháng 11?----------------------------------------------------------------------
select productline,month_ID, DEALSIZE, sum(sales) as REVENUE,count(ordernumber) as ORDER_NUMBER from public.sales_dataset_rfm_prj
where month_ID =11
group by productline,month_ID, DEALSIZE
order by sum(sales) desc , count(ordernumber) desc limit 1
-- =>>>>> Classic Cars
-----------------------4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? ----------------------------------------------------------------------
select * from 
(select YEAR_ID, PRODUCTLINE,sum(sales) as REVENUE, RANK() over(partition by YEAR_ID order by sum(sales ) desc) from public.sales_dataset_rfm_prj
where country ='UK'
group by YEAR_ID, PRODUCTLINE) as t
where rank = 1
-----------------------5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM  ----------------------------------------------------------------------
--rút R - F - M 
with cte as 
(select 
contactfullname,postalcode,
current_date - max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M 
from public.sales_dataset_rfm_prj
group by contactfullname,postalcode),
-- phân loại RFM
cte1 as 
(select contactfullname,postalcode,
ntile(5) over(order by R desc) as
R_score,
ntile(5) over(order by F ) as F_score,
ntile(5) over(order by M ) as M_score
from cte),
cte2 as 
(select contactfullname,postalcode,
 cast(R_score as varchar)|| cast(R_score as varchar)||cast(R_score as varchar)
 as rfm_score from cte1)
 select contactfullname,postalcode, rfm_score from cte2 as a join public.segment_score as b 
 on a.rfm_score = b.scores
 where segment = 'Champions'

