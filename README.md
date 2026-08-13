# Advanced SQL Querying by Maven Analytics

## Purpose of the project
The purpose of this project was to get familiar with advanced SQL techniques and use them to solve real-life business problems. 
The repository includes assignments and data analysis solutions completed during the course (analyzing an e-commerce database). 

## SQL techniques used
* **Multi-table analysis**
  (Basic JOINs, joining on multiple columns, joining multiple tables, SELF JOIN, CROSS JOIN, UNION, UNION ALL)
* **Subqueries**
  (Subqueries in the SELECT, FROM, WHERE, and HAVING clauses, ANY, ALL, EXISTS, and correlated subqueries)
* **Common Table Expressions (CTEs)**
  (Multiple CTEs, recursive CTEs, comparing CTEs vs Temp Tables vs Subqueries)
* **Window Functions**
  (ROW_NUMBER(), RANK(), DENSE_RANK(), FIRST_VALUE(), LAST_VALUE(), NTH_VALUE(), LEAD(), LAG(), NTILE(), cumulative sum, moving average)
* **Functions by Data Type**
  (CAST, CONVERT, string functions, pattern matching, NULL functions)
* **Data Analysis Application**
  (Identifying duplicate values, min/max value filtering, pivoting, rolling calculations, imputing null values)

## Code Example

Below is an example of calculating rolling business metrics (cumulative sum and a 6-month moving average) to analyze revenue trends over time.

```sql
-- Calculate the total sales each month
WITH monthly_sales AS (
    SELECT 
        YEAR(o.order_date) AS year_order,
        MONTH(o.order_date) AS month_order,
        SUM(o.units * p.unit_price) AS total_price
    FROM orders o 
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY 
        YEAR(o.order_date), 
        MONTH(o.order_date)
)
SELECT 
    year_order, 
    month_order,
    total_price
FROM monthly_sales
ORDER BY 
    year_order, 
    month_order;
    
    
-- Add on the cumulative sum and 6-month moving average
WITH monthly_sales AS (
    SELECT 
        YEAR(o.order_date) AS year_order,
        MONTH(o.order_date) AS month_order,
        SUM(o.units * p.unit_price) AS total_price
    FROM orders o 
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY 
        YEAR(o.order_date), 
        MONTH(o.order_date)
)
SELECT 
    year_order,
    month_order,
    total_price,
    SUM(total_price) OVER (PARTITION BY year_order ORDER BY month_order) AS cumulative_sum,
    ROUND(AVG(total_price) OVER (PARTITION BY year_order ORDER BY month_order
                                 ROWS BETWEEN 5 PRECEDING AND CURRENT ROW), 3) AS moving_avg_6m
FROM monthly_sales
ORDER BY 
    year_order, 
    month_order;
```
