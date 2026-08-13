-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Subqueries in the SELECT clause

-- View the products table
select * from products;

-- View the average unit price
select avg(unit_price) from products;

-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price
select 
	product_id,
    product_name,
    unit_price,
    (select avg(unit_price) from products) 				  as avg_unit_price,
    (unit_price - (select avg(unit_price) from products)) as diff_avg_price
from products;

-- Order the results from most to least expensive
select 
	product_id,
    product_name,
    unit_price,
    (select avg(unit_price) from products) 		  	  	  as avg_unit_price,
    (unit_price - (select avg(unit_price) from products)) as diff_avg_price
    from products
    order by 5 desc;

-- ASSIGNMENT 2: Subqueries in the FROM clause
select * from products;

-- Return the factories, product names from the factory
-- and number of products produced by each factory
select 
	pr.factory, 
    pr.product_name,
    npr.number_of_products
from products pr left join 
	(select factory,
		count(product_name) as number_of_products
	from products
	group by factory) npr
on pr.factory = npr.factory
order by 3 desc;


-- All factories and products
select factory, product_name from products;


-- All factories and their total number of products

select 
	factory,
	count(product_name) as number_of_products
from products
group by factory;

-- Final query with subqueries

select 
	pr.factory, 
    pr.product_name,
    npr.number_of_products
from products pr left join 
	(select factory,
	 count(product_id) as number_of_products
	from products
	group by factory) npr
on pr.factory = npr.factory
order by 1,2;

-- ASSIGNMENT 3: Subqueries in the WHERE clause

-- View all products from Wicked Choccy's
select * from products
where factory = 'Wicked Choccy''s';

-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's
select * from products
where unit_price < ALL(select unit_price from products where factory = 'Wicked Choccy''s');


-- ASSIGNMENT 4: CTEs

-- View the orders and products tables
select * from orders;
select * from products;



with prices as (select o.order_id, o.product_id,o.units, p.unit_price
				from orders o inner join products p
				on o.product_id = p.product_id),
                
-- Calculate the amount spent on each product, within each order
total_prices as (select order_id, product_id, 
				sum(units * unit_price) as total_price
				from prices 
				group by order_id, product_id),

-- Return all orders over $200
order_prices as (select order_id, sum(total_price) as order_price
				 from total_prices
				 group by order_id
				 having order_price > 200)

-- Return the number of orders over $200
select count(*) as count_orders
from order_prices;


-- ASSIGNMENT 5: Multiple CTEs

-- Copy over Assignment 2 (Subqueries in the FROM clause) solution
select 
	pr.factory, 
    pr.product_name,
    npr.number_of_products
from products pr left join 
	(select factory,
		count(product_name) as number_of_products
	from products
	group by factory) npr
on pr.factory = npr.factory
order by 3 desc;

-- Rewrite the Assignment 2 subquery solution using CTEs instead
with count_products as (select factory,
						count(product_id) as number_of_products
						from products
						group by factory)
select 
	pr.factory,
    pr.product_name,
    cp.number_of_products
from products pr left join count_products cp 
on 	 pr.factory = cp.factory 
order by 3 desc


