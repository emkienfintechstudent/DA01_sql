--ex1
select Name from STUDENTS 
WHERE Marks > 75 
order by right(Name,3),ID
--ex2 
select user_id,concat(upper(left(name,1)), lower(right(name,length(name)-1)) ) as name from Users 
order by user_id
--ex3 
select manufacturer, '$'|| ROUND(sum(total_sales)/1000000) || ' million'
from pharmacy_sales
group by manufacturer
order by sum(total_sales) desc
--ex4
select EXTRACT(month from submit_date) as mth, product_id,ROUND(AVG(stars),2)  from reviews
group by product_id, EXTRACT(month from submit_date)
ORDER BY mth,product_id
--ex5
SELECT sender_id,count(*) as "message_count" from messages 
where EXTRACT(month from sent_date) =8 and EXTRACT(year from sent_date) = 2022
GROUP BY sender_id
ORDER BY count(*) DESC
LIMIT 2
--ex6
select tweet_id from Tweets
where length(content) >15
--ex7 
select activity_date as day, count(distinct user_id) as active_users from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by activity_date 
--ex8
select count(joining_date) from employees
where extract(month from joining_date) between 1 and 7
--ex9
select position('a' in first_name) from worker
where first_name = 'Amitah'
--ex10
select id,substring(title,length(winery)+2,4) from winemag_p2
where country ='Macedonia'

