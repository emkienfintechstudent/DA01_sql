--ex1
select distinct CITY from STATION 
WHERE ID % 2 = 0
--ex2
  SELECT COUNT(ID) - COUNT(DISTINCT CITY) FROM STATION
--ex3
  Select ceil(AVG(Salary) - avg(replace(Salary,0,''))) from EMPLOYEES
--ex4
Select ROUND(SUM(item_count::decimal * order_occurrences) /SUM(order_occurrences),1)from items_per_order;
--ex5
select candidate_id FROM candidates 
where skill in ('Python','Tableau','PostgreSQL')
group by candidate_id
having count(skill) =3
ORDER BY candidate_id
--ex6
select user_id, MAX(Date(post_date)) - min(date(post_date))AS days_between from posts 
where DATE_PART('year',post_date::date)=2021
GROUP BY user_id
having MAX(Date(post_date))- min(Date(post_date)) <>0
order by user_id
--ex7
SELECT card_name, max(issued_amount) - min(issued_amount) as diffirent from monthly_cards_issued
group by card_name 
order by max(issued_amount) - min(issued_amount) desc
--ex8
select manufacturer, count(drug) as drug_count , abs(SUM(total_sales - cogs)) as total_loss from pharmacy_sales
where total_sales - cogs <=0
group by manufacturer
ORDER BY total_loss desc
--ex9
Select * from Cinema
where description != 'boring' and id %2 !=0
order by rating desc
--ex10
select teacher_id,count(distinct subject_id) as cnt  from Teacher 
group by teacher_id
--ex11
select distinct user_id, count(follower_id) as followers_count from Followers 
group by user_id
order by user_id 
--ex12 
select class from Courses 
group by class
having count(student) >= 5
