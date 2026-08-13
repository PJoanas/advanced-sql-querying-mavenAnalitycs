-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 2: Self Joins
-- Which products are within 25 cents of each other in terms of unit price?

-- View the products table
select * from products;

-- Join the products table with itself so each candy is paired with a different candy
select 
	* 
from products p1 inner join products p2
on 	 p1.product_id <> p2.product_id;

        
-- Calculate the price difference, do a self join, and then return only price differences under 25 cents
select 
	*, 
	.unit_price - p2.unit_price as price_diff
from products p1 inner join products p2
on 	 p1.product_id <> p2.product_id
where ABS(p1.unit_price - p2.unit_price) < 0.25;
