CREATE DATABASE PIZZA;
USE PIZZA;

select * from pizzas;
select * from pizza_types;

#for big data we need to create table
CREATE TABLE orders(
order_id int primary key,
order_date date not null,
order_time time not null
);

CREATE TABLE  order_details(
order_details_id int,
order_id int,
pizza_id varchar(50),
quantity int,
primary key(order_details_id)
);

SHOW TABLES;
SHOW COLUMNS FROM ORDERS;
SHOW COLUMNS FROM ORDER_DETAILS;
SHOW COLUMNS FROM PIZZAS;
SHOW COLUMNS FROM PIZZA_TYPES;

-- CHECK NULL VALUES FROM EACH TABLE
#1. ORDER TABLE
SELECT COUNT(*) AS NULL_COUNT FROM ORDERS
WHERE ORDER_ID IS NULL OR ORDER_DATE IS NULL OR ORDER_TIME IS NULL;

#2. PIZZA TABLE
SELECT COUNT(*) AS NULL_COUNT FROM PIZZAS
WHERE PIZZA_ID IS NULL OR PIZZA_TYPE_ID IS NULL OR SIZE IS NULL OR PRICE IS NULL;

#3. PIZZA_TYPES
SELECT COUNT(*) AS NULL_COUNT FROM PIZZA_TYPES
WHERE NAME IS NULL OR PIZZA_TYPE_ID IS NULL OR CATEGORY IS NULL OR INGREDIENTS IS NULL;

#4. ORDER_DETAILS
SELECT COUNT(*) AS NULL_COUNT FROM ORDER_DETAILS
WHERE ORDER_ID IS NULL OR ORDER_DETAILS_ID IS NULL OR PIZZA_ID IS NULL OR QUANTITY IS NULL;

--    QUESTIONS

#1. Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;


#2. Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_revenue from order_details 
join pizzas
on order_details.pizza_id=pizzas.pizza_id;

#3. Identify the highest-priced pizza.
select pizzas.price as highest_price,pizza_types.name from pizzas
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by highest_price desc
limit 1;


# 4. Identify the most common pizza size ordered.
select  pizzas.size,count(order_details.order_id * order_details.quantity) as total_order from pizzas
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by size
order by total_order desc;


#5. List the top 5 most ordered pizza types along with their quantities.
select name,sum(order_details.quantity) as total_quantity from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by name
order by total_quantity desc
limit 5;


-- 		INTERMEDIATE LEVEL QUESTIONS
#1.Join the necessary tables to find the total quantity of each pizza category ordered.
select category,sum(order_details.quantity) as total_quantity  from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by category
order by total_quantity desc;

#2.Determine the distribution of orders by hour of the day.
select hour(order_time) as hour,count(order_id) from orders
group by hour 
order by count(order_id) desc;

# 3.Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) category_wise_distribution from  pizza_types
group by category;

#4.Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(order_by_day) from (select order_date,sum(quantity) as order_by_day from orders
join order_details
on orders.order_id=order_details.order_id
group by order_date) as data;

#5.Determine the top 3 most ordered pizza types based on revenue.
select name,round(sum(pizzas.price * order_details.quantity),0) as total_revenue from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by name 
order by total_revenue desc
limit 3;


--  ADVANCE QUERIES
#1.Calculate the percentage contribution of each pizza type to total revenue.
SELECT category,concat(round(sum((order_details.quantity * pizzas.price)/(select sum(order_details.quantity * pizzas.price) from pizzas
															join  order_details
                                                            on pizzas.pizza_id=order_details.pizza_id)*100),2),"%") as percent_contribution
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by category;

#2.Analyze the cumulative revenue generated over time.
                                                            
select order_date,sum(revenue) over(order by order_date) from (select  order_date,round(sum(quantity * price),2) as revenue from orders
join order_details
on orders.order_id=order_details.order_id
join pizzas
on order_details.pizza_id=pizzas.pizza_id
group by order_date) as sales;

# 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select category, name, revenue from (select category,name, revenue, 
 row_number() over (partition by category order by revenue desc) as rn from (select category,name,sum(pizzas.price*order_details.quantity) as revenue from pizza_types
 join pizzas
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
 join order_details
	on pizzas.pizza_id=order_details.pizza_id
 group by category,name) as cat_revenue) as full_revenue
 where rn<=3;
 





