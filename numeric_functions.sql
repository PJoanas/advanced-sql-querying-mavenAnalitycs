-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Numeric functions
select * from orders;
select * from products;
-- Calculate the total spend for each customer
select 
	o.customer_id,
    o.order_id,
    o.product_id,
    o.units,
    p.unit_price
from orders o left join products p
on o.product_id = p.product_id;

select 	
	o.customer_id,
    sum(units * unit_price) as total_spend
from orders o left join products p
on   o.product_id = p.product_id
group by o.customer_id
order by 2 desc;

-- Put the spend into bins of $0-$10, $10-20, etc.
with spend_bin as (select o.customer_id,
				   sum(o.units * p.unit_price) as total_spend,
				   floor(sum(o.units * p.unit_price) / 10) *10 as total_spend_bin
				   from orders o left join products p
				   on o.product_id = p.product_id
				   group by o.customer_id)
                   
-- Number of customers in each spend bin
select 
	total_spend_bin,
    count(customer_id) as number_of_customers
from spend_bin
group by total_spend_bin
order by 1;



-- ASSIGNMENT 2: Datetime functions
select * from orders;
-- Extract just the orders from Q2 2024
select *
from orders 
where year(order_date) = 2024
	and month(order_date) between 4 and 6;

-- Add a column called ship_date that adds 2 days to each order date
select
	order_id,
    order_date,
    date_add(order_date, interval 2 day) as ship_date
from orders 
where year(order_date) = 2024
	and month(order_date) between 4 and 6;

-- ASSIGNMENT 3: String functions
select * from products;

-- View the current factory names and product IDs
select
	factory,
    product_id
from products;

-- Remove apostrophes and replace spaces with hyphens
select
	replace(replace(factory, "'", ""), " ", "-") as factory_cleaned,
    product_id
from products
order by 1, 2;

-- Create new ID column called factory_product_id
with cte as (select replace(replace(factory, "'", ""), " ", "-") as factory_cleaned,
			 product_id
			 from products)
             
select 
	concat(factory_cleaned," - ", product_id) as dactory_product_id
from cte;


-- ASSIGNMENT 4: Pattern matching
select * from products;
-- View the product names
select product_name
from products;

-- Only extract text after the hyphen for Wonka Bars
select 
	product_name,
    replace(product_name, "Wonka Bar - ", "") as cleaned_product_name
from products;

-- Alternative using substrings
select 	
	product_name,
    case when nstr(product_name, "-") = 0 then product_name 
		 else substr(product_name, instr(product_name, "-") + 2) 
		end as new_name
from products;

-- ASSIGNMENT 5: Null functions
select * from products;
-- View the columns of interest
select
	product_name,
    factory,
    division
from products;

-- Replace NULL values with Other
select
	product_name,
    factory,
    division,
    ifnull(division, "Other") as filled_division
from products;


-- Find the most common division for each factory
select
	factory,
    division,
    count(product_name) as number_of_products
from products
where division is not null
group by factory, division
order by factory, division;

-- Replace NULL values with top division for each factory
with cte as (select factory,division,
			 count(product_name) as number_of_products
			 from products
			 where division is not null
			 group by factory, division),
             
product_rank as (select *,
				 row_number() over (partition by factory order by number_of_products desc) as product_rank
				 from cte),
    
top_div as (select *
			from product_rank
			where product_rank = 1)

-- Replace division with Other value and top division
select
	p.product_name,
    p.factory,
    p.division,
    tp.division as top_division,
    coalesce(p.division, "Other") as filled_division,
    coalesce(p.division, tp.division) as new_divisions
from products p left join top_div tp
on p.factory = tp.factory;

