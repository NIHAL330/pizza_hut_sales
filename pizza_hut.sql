create database pizza_hut;
use pizza_hut;

create table orders (order_id int primary key not null, order_date date not null, order_time time not null);
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;


-- 1.Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;
    

-- 2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id;
    
    
-- 3.Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4.Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.quantity) AS most_ordered_size
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY most_ordered_size DESC;

-- 5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;


-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_details.quantity) AS Quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;


-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);


-- 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) as avg_quantity_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS pizza_quantity;
    
    
-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS Revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;


-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    round(SUM(pizzas.price * order_details.quantity) / (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id)*100, 2) As Revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;


-- 12. Analyze the cumulative revenue generated over time.
select order_date, sum(Revenue) over(order by order_date) as Cum_Revenue from
(SELECT 
    orders.order_date,
    SUM(pizzas.price * order_details.quantity) AS Revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as sales;


-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name, revenue, 
rank() over(partition by category order by revenue desc) as rnk 
from
(select pizza_types.category, pizza_types.name, 
sum(pizzas.price * order_details.quantity) AS Revenue
FROM
    pizzas
        JOIN
        pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
    group by  pizza_types.category, pizza_types.name) as a;