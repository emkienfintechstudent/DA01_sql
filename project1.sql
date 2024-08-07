--bài tập 1 
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN ordernumber TYPE numeric USING (TRIM(ordernumber):: numeric)
  
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN quantityordered TYPE numeric USING (TRIM(quantityordered):: numeric)
  
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN priceeach TYPE numeric USING (TRIM(priceeach):: numeric)
  
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN orderlinenumber TYPE numeric USING (TRIM(orderlinenumber):: numeric)

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN sales TYPE float USING (TRIM(sales):: float)

SET datestyle = 'iso,mdy';  
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN orderdate TYPE date USING (TRIM(orderdate):: date)

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN msrp TYPE numeric USING (TRIM(msrp):: numeric)

-- bài tập 2 
SELECT *
FROM sales_dataset_rfm_prj
WHERE 
    ORDERNUMBER IS NULL OR
    QUANTITYORDERED IS NULL OR
    PRICEEACH IS NULL OR
    ORDERLINENUMBER IS NULL OR
    SALES IS NULL OR
    ORDERDATE IS NULL;
-- bài tập 3 
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME VARCHAR(255),
ADD COLUMN CONTACTFIRSTNAME VARCHAR(255);

UPDATE sales_dataset_rfm_prj
SET CONTACTLASTNAME = INITCAP(SUBSTRING(CONTACTFULLNAME FROM POSITION('-' IN CONTACTFULLNAME) + 1)),
    CONTACTFIRSTNAME = INITCAP(SUBSTRING(CONTACTFULLNAME FROM 1 FOR POSITION('-' IN CONTACTFULLNAME) - 1))
WHERE CONTACTFULLNAME IS NOT NULL AND POSITION('-' IN CONTACTFULLNAME) > 0;
Hoặc 
UPDATE sales_dataset_rfm_prj
SET CONTACTLASTNAME = SPLIT_PART(CONTACTFULLNAME, ' ', 2),
    CONTACTFIRSTNAME = SPLIT_PART(CONTACTFULLNAME, ' ', 1);
-- bài tập 4 
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID INT,
ADD COLUMN MONTH_ID INT,
ADD COLUMN YEAR_ID INT;

UPDATE sales_dataset_rfm_prj
SET QTR_ID = EXTRACT(QUARTER FROM ORDERDATE),
    MONTH_ID = EXTRACT(MONTH FROM ORDERDATE),
    YEAR_ID = EXTRACT(YEAR FROM ORDERDATE);
-- bài tập 5 
SELECT * FROM  sales_dataset_rfm_prj
-- tìm outliner sử dụng IQR/boxplot
with Twt_min_max_values AS(
SELECT Q1 - 1.5*IQR AS min_value, 
Q3 + 1.5*IQR AS max_value FROM
(percentile_cont (0.25) within (ORDER by QUANTITYORDERED) AS Q1, 
percentile_cont (0.75) within (ORDER by QUANTITYORDERED) AS Q3,
percentile_cont (0.75) within (ORDER by QUANTITYORDERED)-percentile_cont (0.25) within (ORDER by QUANTITYORDERED)AS IQR
FROM  sales_dataset_rfm_prj) AS a)
--- Xác định outliner 
SELECT * FROM sales_dataset_rfm_prj
WHERE QUANTITYORDERED< (SELECT min_value FROM Twt_min_max_values )
or QUANTITYORDERED> (SELECT max_value FROM Twt_min_max_values )
--- sử dụng Z-score 
SELECT avg(QUANTITYORDERED),
stddev(QUANTITYORDERED)
FROM sales_dataset_rfm_prj

with cte as
(SELECT orderdate,QUANTITYORDERED,(avg(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS avg,
(stddev(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS stddev
FROM sales_dataset_rfm_prj)
,twt_outliner AS(
SELECT orderdate,QUANTITYORDERED,(QUANTITYORDERED-avg)/stddev AS z_score
from cte 
where ABS ((QUANTITYORDERED-avg)/stddev)>2)

UPDATE sales_dataset_rfm_prj
SET QUANTITYORDERED=(avg(QUANTITYORDERED) FROM sales_dataset_rfm_prj)
WHERE QUANTITYORDERED IN(SELECT QUANTITYORDERED FROM twt_outliner);

DELETE FROM sales_dataset_rfm_prj
WHERE QUANTITYORDERED IN(SELECT QUANTITYORDERED FROM twt_outliner);

-- bài tập 6 
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
SELECT *
FROM sales_dataset_rfm_prj
WHERE 
    ORDERNUMBER IS NOT NULL AND
    QUANTITYORDERED IS NOT NULL AND
    PRICEEACH IS NOT NULL AND
    ORDERLINENUMBER IS NOT NULL AND
    SALES IS NOT NULL AND
    ORDERDATE IS NOT NULL;

