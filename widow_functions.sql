-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Window function basics

-- View the orders table
select * from orders;

-- View the columns of interest
select 
	customer_id,
    order_id,
    order_date,
    transaction_id
from orders;

-- For each customer, add a column for transaction number
select 
	customer_id,
    order_id,
    order_date,
    transaction_id,
    row_number() over(partition by customer_id order by transaction_id asc) as transaction_count
from orders
order by customer_id, transaction_id;

-- ASSIGNMENT 2: Row Number vs Rank vs Dense Rank

-- View the columns of interest
select * from orders;
select order_id, product_id, units from orders;

-- Try ROW_NUMBER to rank the units
select 
	order_id, 
	product_id, 
	units,
	row_number() over() as row_numb
from orders
order by units desc;

-- For each order, rank the products from most units to fewest units
-- If there's a tie, keep the tie and don't skip to the next number after
select 
	order_id, 
	product_id, 
	units,
	dense_rank() over (partition by order_id order by units desc) as d_rank
from orders
order by order_id;

-- Check the order id that ends with 44262 from the results preview
select 
	order_id, 
	product_id, 
	units,
	dense_rank() over (partition by order_id order by units desc) as d_rank
from orders
where order_id like '%44262'
order by order_id, d_rank;

-- ASSIGNMENT 3: First Value vs Last Value vs Nth Value

-- View the rankings from the last assignment
select 
	order_id, 
    product_id, 
    units,
	dense_rank() over (partition by order_id order by units desc) as d_rank
from orders
order by order_id, d_rank;

-- Add a column that contains the 2nd most popular product
select 
	order_id, 
    product_id, 
    units,
	dense_rank() over (partition by order_id order by units desc) 			  as d_rank,
    nth_value(product_id, 2) over (partition by order_id order by units desc) as 2nd_prod
from orders
order by order_id, d_rank;

-- Return the 2nd most popular product for each order
with 2nd_rank as (select order_id, product_id, units,
			  dense_rank() over (partition by order_id order by units desc)             as d_rank,
			  nth_value(product_id, 2) over (partition by order_id order by units desc) as 2nd_prod
			  from orders
			  order by order_id, d_rank)
              
select 
	order_id, 
    product_id 
from 2nd_rank 
where product_id = 2nd_prod;

-- Alternative using DENSE RANK
-- Add a column that contains the rankings
select 
	order_id, 
    product_id, 
    units,
	dense_rank() over (partition by order_id order by units desc) as d_rank
from orders
order by order_id, d_rank;

-- Return the 2nd most popular product for each order
with ranking as (select order_id, product_id, units,
				 dense_rank() over (partition by order_id order by units desc) as d_rank
				 from orders
				 order by order_id, d_rank)
                 
select order_id, product_id, units from ranking 
where d_rank = 2;


-- ASSIGNMENT 4: Lead & Lag
select * from orders;
-- View the columns of interest
select
	customer_id,
	order_id,
    order_date,
    product_id,
    units
from orders
order by customer_id, order_id;

-- For each customer, return the total units within each order
select 
	customer_id,
    order_id,
    sum(units) as total_units
from orders
group by customer_id, order_id
order by customer_id, tran_id;

-- Add on the transaction id to keep track of the order of the orders
select 
	customer_id,
    order_id,
    min(transaction_id) as tran_id,
    sum(units) as total_units
from orders
group by customer_id, order_id
order by customer_id, tran_id;

-- Turn the query into a CTE and view the columns of interest
with total_orders as (select customer_id, order_id,
					  min(transaction_id) as tran_id,
					  sum(units) 		  as total_units
					  from orders
					  group by customer_id, order_id
					  order by customer_id, tran_id),

-- Create a prior units column
	my_cte 		  as (select customer_id, order_id, total_units,
				  lag(total_units) over (partition by customer_id order by tran_id) as prior_units
		          from total_orders)

-- For each customer, find the change in units per order over time
select 
	customer_id,
    order_id,
    total_units,
    prior_units,
    total_units - prior_units as units_diff
from my_cte;

-- ASSIGNMENT 5: NTILE
-- Calculate the total amount spent by each customer

-- View the data needed from the orders table
select * from orders;

-- View the data needed from the products table
select * from products;

-- Combine the two tables and view the columns of interest
select 
	o.customer_id,
    o.order_id,
    o.product_id,
    o.units,
    p.unit_price
from orders o left join products p
on   o.product_id = p.product_id;
        
-- Calculate the total spending by each customer and sort the results from highest to lowest
select 
	o.customer_id,
    sum(units * unit_price) as total_price
from orders o left join products p
on   o.product_id = p.product_id
group by o.customer_id
order by total_price desc;

-- Turn the query into a CTE and apply the percentile calculation
with new_cte as (select o.customer_id as customer_id,
				 sum(units * unit_price) as total_price
				 from orders o left join products p
				 on o.product_id = p.product_id
				 group by o.customer_id),
                 
	 tiled 	 as (select customer_id, total_price,
				 ntile(100) over(order by total_price desc) as tiled
			     from new_cte)

-- Return the top 1% of customers in terms of spending
select customer_id, total_price
from tiled
where tiled = 1;

