-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Duplicate values

-- View the students data
select * from students;

-- Create a column that counts the number of times a student appears in the table
select
	student_name,
    count(*)
from students
group by student_name;

-- Return student ids, names and emails, excluding duplicates students
with ct as (select *,
			row_number() over (partition by student_name order by id desc) as student_rank
			from students)
    
select 
	id, 
    student_name, 
    email 
from ct
where student_rank = 1;
		


-- ASSIGNMENT 2: Min / max value filtering

-- View the students and student grades tables
select * from students;
select * from student_grades;

-- For each student, return the classes they took and their final grades

with ranking as (select s.id, s.student_name, sg.semester_id, sg.class_name, sg.final_grade,
				 dense_rank() over (partition by student_name order by final_grade desc) as grade_rank
				 from students s inner join student_grades sg
				 on s.id = sg.student_id)
        
-- Return each student's top grade and corresponding class
select * from ranking
where grade_rank = 1;
                    
-- ASSIGNMENT 3: Pivoting

-- Combine the students and student grades tables
select * from students;
select * from student_grades;

select * 
from students s left join student_grades sg 
on s.id = sg.student_id;
        
-- View only the columns of interest
select 
	s.id,
    s.student_name,
    s.grade_level,
    sg.department,
    sg.final_grade
from students s left join student_grades sg 
on s.id = sg.student_id;
        
-- Pivot the grade_level column
select 
	s.grade_level,
	sg.department,
	sg.final_grade,
	case when grade_level = 9 	then 1 else 0 end as 'freshman',
	case when grade_level = 10 	then 1 else 0 end as 'sophomore',
	case when grade_level = 11 	then 1 else 0 end as 'junior',
	case when grade_level = 12 	then 1 else 0 end as 'senior'
from students s left join student_grades sg 
on   s.id = sg.student_id;

        
-- Update the values to be final grades
select 
	s.grade_level,
	sg.department,
	sg.final_grade,
	case when grade_level = 9 	then sg.final_grade else 0 end as 'freshman',
	case when grade_level = 10 	then sg.final_grade else 0 end as 'sophomore',
	case when grade_level = 11 	then sg.final_grade else 0 end as 'junior',
	case when grade_level = 12 	then sg.final_grade else 0 end as 'senior'
from students s left join student_grades sg 
on s.id = sg.student_id;

-- Create the final summary table
select 
	sg.department,	
	s.grade_level,
	sg.final_grade,
	round(avg(case when s.grade_level = 9 	then sg.final_grade end)) as 'freshman',
	round(avg(case when s.grade_level = 10 	then sg.final_grade end)) as 'sophomore',
	round(avg(case when s.grade_level = 11 	then sg.final_grade end)) as 'junior',
	round(avg(case when s.grade_level = 12 	then sg.final_grade end)) as 'senior'
from students s left join student_grades sg 
on s.id = sg.student_id
where sg.department is not null
group by sg.department
order by sg.department;

-- ASSIGNMENT 4: Rolling calculations
select * from orders;
select * from products;

select *
from orders o left join products p
on o.product_id = p.product_id;

select *
from orders o left join products p
on o.product_id = p.product_id;

select 
	o.order_date,
    o.units,
    p.unit_price
from orders o left join products p
on o.product_id = p.product_id;

-- Calculate the total sales each month
with cte as (select o.order_date,
			 year(o.order_date) as 'year_order',
			 month(o.order_date) as 'month_order',
			 o.units * p.unit_price as total_price
			 from orders o left join products p
			 on o.product_id = p.product_id
			 order by 2, 3)

select 
	year_order, 
    month_order,
    sum(total_price) as price
from cte
group by year_order, month_order
order by year_order, month_order;
    
    
-- Add on the cumulative sum and 6 month moving average
with cte as (select o.order_date,
			 year(o.order_date) as 'year_order',
			 month(o.order_date) as 'month_order',
			 o.units * p.unit_price as total_price
			 from orders o left join products p
			 on o.product_id = p.product_id
			 order by 2, 3),
             
total_price as (select year_order, month_order,
			    sum(total_price) as price
				from cte
				group by year_order, month_order)

select 
	year_order,
    month_order,
    price,
    sum(price) over (partition by year_order order by month_order) as culm_sum,
    round(avg(price) over (partition by year_order order by month_order
						   rows between 5 preceding and current row),3) as avg_sum
from total_price;
