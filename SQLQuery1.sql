--- 1. Find top 10 highest revenue generating products 


select top 10 product_id,SUM(sale_price) as sales
from Orders 
group by product_id 
order by sales desc 


--- 2. find top 5 highest selling products in each region 

with cte as(

select region,product_id,SUM(sale_price) as sales
from Orders 
group by region ,product_id )
select * from (
select *,ROW_NUMBER() over(partition by region order by sales desc) as rn from cte) A
where rn<=5


--- 3. find month over month growth comparison for 2022 & 2023 sales eg: jan 2022 vs jan 2023
with cte as (

select YEAR(order_date) as order_year ,MONTH(order_date) as order_month,
SUM(sale_price) as sales
from Orders 
group by YEAR(order_date),MONTH(order_date))


select order_month,
SUM(case when order_year = 2022 then sales else 0 end) as sales_2022,
SUM(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month


--- 4. For each category which month had highest sales

WITH cte AS (
    SELECT  
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT * 
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;



--- 5. which sub category had highest growth by profit in 2023 compare to 2022
WITH cte1 AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM Orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte1
    GROUP BY sub_category
)
SELECT TOP 1 
    *,
    (sales_2023 - sales_2022) AS sales_difference
FROM cte2
ORDER BY sales_difference DESC;


	