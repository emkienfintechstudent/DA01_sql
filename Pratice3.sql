--ex1
select Name from STUDENTS 
WHERE Marks > 75 
order by right(Name,3),ID
--ex2 
select user_id,concat(upper(left(name,1)), lower(right(name,length(name)-1)) ) as name from Users 
--ex3 
