select * from customers;#customer_id, name, age, gender, region, signup_date
select * from order_details;#order_detail_id, order_id, product_id, quantity, line_total
select * from orders order by customer_id;#order_id, customer_id, order_date, total_amount, status
select * from products;#product_id, product_name, category, price, cost_price
select * from payments;#payment_id, order_id, payment_date, payment_method, amount
select * from returns;#return_id, order_id, product_id, return_date,reason
alter table products add column product_no int after product_name;
alter table products modify column product_no  varchar(200);
update products set product_no=substring_index(product_name," ",1);
alter table products drop column product_no;
 use retailsalesdb;
-- 1.retrive the customers those who not order anything
select c.customer_id from customers c left join orders o on c.customer_id=o.customer_id where c.customer_id not in(select customer_id from orders);

-- 2.top 10 most selling products
select od.product_id,product_name,count(od.product_id) from products p inner join order_details od on p.product_id=od.product_id join orders o on o.order_id=od.order_id group by od.product_id order by count(od.product_id) desc limit 10;

-- 3.calculate sales by region
select region,sum(o.total_amount) as sales_by_region from customers c inner join orders o on c.customer_id=o.customer_id group by o.customer_id;
 
 -- 4.Who are the top 5 customers by total spending?
 use retailsalesdb;
select * from customers;#customer_id, name, age, gender, region, signup_date
select * from orders order by customer_id;#order_id, customer_id, order_date, total_amount, status
select c.customer_id,c.name,sum(o.total_amount) as total_spending from customers c join orders o on c.customer_id=o.customer_id group by o.customer_id order by total_spending desc limit 5 ;

-- 5.What is the monthly revenue per product category?
select p.category,monthname(o.order_date) as order_month,sum(o.total_amount) from products p join order_details od on p.product_id=od.product_id join orders o on o.order_id=od.order_id GROUP BY p.category, MONTHNAME(o.order_date)
ORDER BY order_month;

-- 6.Which category shows the fastest month-on-month growth?
select p.category,monthname(o.order_date) as order_month,sum(o.total_amount) as revenue from products p join order_details od on p.product_id=od.product_id join orders o on o.order_id=od.order_id GROUP BY p.category, MONTHNAME(o.order_date) order by revenue ;
WITH monthly_sales AS (
    SELECT 
        p.category,
        DATE_FORMAT(o.order_date, '%Y-%m') AS yearmonth,
        SUM(o.total_amount) AS revenue
    FROM products p
    JOIN order_details od ON p.product_id = od.product_id
    JOIN orders o ON o.order_id = od.order_id
    GROUP BY p.category, DATE_FORMAT(o.order_date, '%Y-%m')
),
growth AS (
    SELECT 
        category,
        yearmonth,
        revenue,
        LAG(revenue) OVER (PARTITION BY category ORDER BY yearmonth) AS prev_revenue
    FROM monthly_sales
)
SELECT 
    category,
    yearmonth,
    revenue,
    prev_revenue,
    ROUND(((revenue - prev_revenue) / prev_revenue) * 100, 2) AS growth_percent
FROM growth
WHERE prev_revenue IS NOT NULL
ORDER BY growth_percent DESC
LIMIT 1;

-- How many customers are one-time buyers vs. repeat buyers?
select * from orders;
WITH repeat_cust_count AS
(select customer_id,count(customer_id) as repeat_customers from orders group by customer_id having repeat_customers>1 order by repeat_customers) 
 select count(customer_id) from repeat_cust_count;
 select * from orders;
WITH onetime_cust_count AS
(select customer_id,count(customer_id) as onetime_customers from orders group by customer_id having onetime_customers=1 order by onetime_customers) 
 select count(customer_id) from onetime_cust_count;
 SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS order_count
    FROM orders o
    GROUP BY o.customer_id
) AS customer_orders
GROUP BY customer_type;
-- Segment customers into loyalty tiers (e.g., Silver = 2–5 orders, Gold = 6–10, Platinum = 10+).
select * from orders;
select
case
    when total_orders=1 then "onetime"
    when total_orders between 2 and 5 then "silver"
    when total_orders between 6 and 10 then "gold"
else "platinum"
end as "loyalty_tier",
count(*) as customer_count
from    
    (select customer_id,count(order_id) as total_orders from orders group by customer_id)
    AS customer_orders
GROUP BY loyalty_tier
ORDER BY FIELD(loyalty_tier, 'New/One-time', 'Silver', 'Gold', 'Platinum');

-- Which regions contribute the most monthly revenue?
select * from customers;
select c.region,sum(total_amount) as total_monthly_revenue, DATE_FORMAT(o.order_date, '%Y-%m') as month_name from customers c join orders o on c.customer_id=o.customer_id group by c.region,month_name order by total_monthly_revenue desc ;

-- What is the average order value per category each month?
select * from orders;
select * from products;
select * from order_details;
SELECT 
    p.category,
    DATE_FORMAT(o.order_date, '%Y-%m') AS year_month1,
    ROUND(SUM(od.line_total) / COUNT(DISTINCT o.order_id),2) AS avg_order_value
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY p.category, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY year_month1, p.category;

-- How many new customers signed up per month?
select * from customers;#customer_id, name, age, gender, region, signup_date
SELECT
COUNT(customer_id) AS new_customers_signed_up_per_month,date_format(signup_date,"%y-%m") AS YEAR_MONTH1
FROM customers
group by YEAR_MONTH1
order by YEAR_MONTH1 ;

-- What is the average age of customers in each region? is in question duplicates not present then use avg if present then formula
select
avg(age) as average_age_of_customers,region
from customers
group by region
order by average_age_of_customers,region;

-- Which region has the most customers?
select * from orders;
select * from customers;
select 
count(customer_id),region from customers
group by region
order by count(customer_id) desc;

-- 🛒 Order & Sales Analysis

-- What are the monthly sales trends (total sales amount per month)?
select
sum(total_amount) as monthly_sales,date_format(order_date,"%y-%m")as year_month1
from orders
group by year_month1
order by year_month1 desc;

-- Which order status (completed, pending, cancelled) is most common?
select
status,count(*) as order_count,round((count(*)*100/(select count(*) from orders)),2) as percentage_of_total
from orders
group by status;

-- What is the average order value per customer?
select * from customers;#customer_id, name, age, gender, region, signup_date
select * from order_details;#order_detail_id, order_id, product_id, quantity, line_total
select * from orders order by customer_id;#order_id, customer_id, order_date, total_amount, status
select
round(sum(total_amount)/count(distinct(order_id)),2) as average_order_value_per_customer,customer_id from orders group by customer_id;

-- Which customers placed the highest number of orders?
select 
c.name,c.customer_id,count(o.order_id) as order_count
from orders o join customers c on c.customer_id=o.customer_id
group by customer_id
order by order_count desc;

-- What percentage of orders were returned?**
select * from returns;
SELECT 
    ROUND(
        (COUNT(distinct r.order_id) * 100.0 / COUNT(distinct o.order_id)), 
        2
    ) AS return_percentage
FROM orders o
LEFT JOIN returns r ON o.order_id = r.order_id;

-- Which are the top 10 best-selling products (by quantity)?
select * from order_details;#order_detail_id, order_id, product_id, quantity, line_total
select * from products;
select od.product_id,p.product_name,sum(od.quantity) from products p join order_details od on p.product_id=od.product_id  group by od.product_id,p.product_name order by sum(od.quantity) desc limit 10;

-- Which products generate the highest revenue?
select * from orders;
select p.product_id, p.product_name,sum(od.quantity*od.total_price) as total_revenue from products p join order_items od on p.product_id=od.product_id group by p.product_id order by total_revenue desc;

-- Which product category is most popular?
select p.category,count(order_id) from products p join order_details od on p.product_id=od.product_id group by p.category;

-- What is the profit margin (price – cost_price) for each product?
SELECT 
    product_id,
    product_name,
    category,
    price,
    cost_price,
    (price - cost_price) AS profit_margin
FROM products;

#profit percentage
SELECT 
    product_id,
    product_name,
    category,
    price,
    cost_price,
    (price - cost_price) AS profit_margin,
    ROUND(((price - cost_price) / cost_price) * 100, 2) AS profit_margin_percentage
FROM products;

-- Which products have the highest return rate?
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(r.return_id) AS total_returns,
    COUNT(od.order_detail_id) AS total_sold,
    ROUND((COUNT(r.return_id) * 100.0 / COUNT(od.order_detail_id)), 2) AS return_rate_percentage
FROM products p
JOIN order_details od 
    ON p.product_id = od.product_id
LEFT JOIN returns r 
    ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY return_rate_percentage DESC;


--  Payment Analysis
select * from customers;#customer_id, name, age, gender, region, signup_date
select * from order_details;#order_detail_id, order_id, product_id, quantity, line_total
select * from orders order by customer_id;#order_id, customer_id, order_date, total_amount, status
select * from products;#product_id, product_name, category, price, cost_price
select * from payments;#payment_id, order_id, payment_date, payment_method, amount
select * from returns;#return_id, order_id, product_id, return_date,reason

-- Which payment method (Cash, Card, UPI, etc.) is used most often?
SELECT 
      payment_method,
      COUNT(order_id)
FROM payments
GROUP BY payment_method
ORDER BY COUNT(order_id) DESC;

-- What is the average payment amount across customers?
SELECT
      AVG(amount)
FROM payments;

-- Which customers made the highest total payments?
SELECT
	 c.customer_id, 
	 c.name,
	 SUM(amount) AS TOTAL_PAYMENTS
FROM payments p
JOIN orders o
     ON p.order_id=o.order_id
JOIN customers c
     ON c.customer_id=o.customer_id
GROUP BY c.customer_id
ORDER BY TOTAL_PAYMENTS DESC;
       
-- How many payments are done per month
SELECT
     YEAR(payment_date),
	 MONTH(payment_date),
     COUNT(payment_id)
FROM payments
GROUP BY YEAR(payment_date),MONTH(payment_date)
ORDER BY  YEAR(payment_date),MONTH(payment_date);

-- Which products are most frequently returned and why?
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(r.return_id) AS total_returns
FROM returns r
JOIN products p 
    ON r.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_returns DESC
LIMIT 5;

select * from customers;#customer_id, name, age, gender, region, signup_date
select * from order_details;#order_detail_id, order_id, product_id, quantity, line_total
select * from orders order by customer_id;#order_id, customer_id, order_date, total_amount, status
select * from products;#product_id, product_name, category, price, cost_price
select * from payments;#payment_id, order_id, payment_date, payment_method, amount
select * from returns;#return_id, order_id, product_id, return_date,reason

-- What is the return rate by region?
SELECT 
    c.region,
    COUNT(DISTINCT r.return_id) AS total_returns,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND((COUNT(DISTINCT r.return_id) * 100.0 / COUNT(DISTINCT o.order_id)), 2) AS return_rate_percentage
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
LEFT JOIN returns r 
    ON o.order_id = r.order_id
GROUP BY c.region
ORDER BY return_rate_percentage DESC;

-- What is the total loss due to returns (sum of returned product prices)?
SELECT 
    SUM(p.price) AS total_loss_due_to_returns
FROM returns r
JOIN products p 
    ON r.product_id = p.product_id;

-- What is the lifetime value (LTV) of each customer (total spend – total returns)?
SELECT #COALESCE → ensures customers with no returns are still included (return value = 0).
    c.customer_id,
    c.name,
    c.region,
    SUM(o.total_amount) AS total_spent,
    COALESCE(SUM(p.price), 0) AS total_return_value,
    (SUM(o.total_amount) - COALESCE(SUM(p.price), 0)) AS lifetime_value
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
LEFT JOIN returns r 
    ON o.order_id = r.order_id
LEFT JOIN products p 
    ON r.product_id = p.product_id
GROUP BY c.customer_id, c.name, c.region
ORDER BY lifetime_value DESC;

-- Which region gives the highest revenue vs. highest returns?
SELECT 
    c.region,
    SUM(o.total_amount) AS total_revenue,
    COALESCE(SUM(p.price), 0) AS total_return_value,
    (SUM(o.total_amount) - COALESCE(SUM(p.price), 0)) AS net_revenue
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
LEFT JOIN returns r 
    ON o.order_id = r.order_id
LEFT JOIN products p 
    ON r.product_id = p.product_id
GROUP BY c.region
ORDER BY total_revenue DESC;

-- What is the profit per product category (total sales – total cost)?
SELECT 
    p.category,
    SUM((p.price - p.cost_price) * od.quantity) AS total_profit
FROM order_details od
JOIN products p 
    ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- Can you find seasonal trends in sales (peak months of ordering)?
SELECT 
    MONTHNAME(order_date) AS month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);

