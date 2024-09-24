create database pizzahut;

create table orders (
order_id int not null primary key,
order_date date not null,
order_time time not null
);

desc order_details;
alter table order_details add primary key (order_details_id);

#Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

#Calculate the total revenue generated from pizza sales.
select round(sum(quantity*price),2) as total_sales 
from order_details od join pizzas p on p.pizza_id = od.pizza_id;

#Identify the highest-priced pizza.
select name,price from 
pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;

#Identify the most common pizza size ordered.
select sum(quantity),size from 
order_details od join pizzas p on od.pizza_id = p.pizza_id
group by size
order by 1 desc
limit 1;

#List the top 5 most ordered pizza types along with their quantities.
select name,sum(quantity)
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc
limit 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
select sum(quantity),category
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by category
order by 1;

#Determine the distribution of orders by hour of the day.
select hour(order_time) as hours , count(order_id) as order_count
from orders
group by 1;

#Join relevant tables to find the category-wise distribution of pizzas.
select count(name),category 
from pizza_types
group by category;

#Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_qty),0) as avg_qty from 
(select sum(quantity) as total_qty,order_date
from order_details od join orders o on od.order_id = o.order_id
group by 2) as a;

#Determine the top 3 most ordered pizza types based on revenue.
select name,round(sum(quantity*price),2) as revenue 
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc
limit 3;

#Calculate the percentage contribution of each pizza type to total revenue.
select category,(sum(quantity*price) / (select round(sum(quantity*price),2) as total_sales 
from order_details od join pizzas p on p.pizza_id = od.pizza_id ) )* 100 as revenue 
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc;

#Analyze the cumulative revenue generated over time.

select order_date,sum(revenue) over (order by order_date) as cum_revenue from
(select sum(quantity*price) as revenue , order_date
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join orders o on o.order_id = od.order_id
group by 2 ) as a ;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue,category from
(select name,category,revenue,
rank() over(partition by category order by revenue desc ) as rn from
(select sum(quantity*price) as revenue , category, name
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by 2,3) as a ) as b
where rn <= 3;



