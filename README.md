# Retail_Sales_Analysis_using_SQL

## ✨ Project Overview  

This project focuses on analyzing a **Retail Sales Database** using **SQL** to uncover insights on **customer spending patterns**, **product performance**, **profitability**, and **seasonal trends**.  

The goal is to simulate real-world business problems and demonstrate how **data analytics can drive decisions** in the retail industry.  

---


## 🧱 Database Schema  

 **Database Name:** `retail_sales_db`  

| Table Name | Description | Key Columns |
|-------------|-------------|-------------|
|  **customers** | Contains customer details and region information. | `customer_id`, `name`, `age`, `gender`, `region`, `signup_date` |
|  **orders** | Customer purchase records. | `order_id`, `customer_id`, `order_date`, `total_amount`, `status` |
|  **order_details** | Detailed breakdown of each product sold in an order. | `order_detail_id`, `order_id`, `product_id`, `quantity`, `line_total` |
|  **products** | Product catalog with pricing and cost information. | `product_id`, `product_name`, `category`, `price`, `cost_price` |
|  **payments** | Payment details for each order. | `payment_id`, `order_id`, `payment_date`, `payment_method`, `amount` |
|  **returns** | Information about returned products and reasons. | `return_id`, `order_id`, `product_id`, `return_date`, `reason` |


## 🎯 Key Business Questions Solved  

📊 **Sales & Profitability**  
- What is the **profit margin** for each product and category?  
- Which regions generate the **highest revenue**?  

🔁 **Returns Analysis**  
- Which products have the **highest return rate** and why?  
- What is the **total loss due to returns**?  

💰 **Customer Insights**  
- What is the **Lifetime Value (LTV)** of each customer?  
- Which customers contribute most to revenue?  

🗓️ **Trends & Seasonality**  
- What are the **peak sales months**?  
- Which region gives the highest revenue vs. highest returns?

---

## 🧠 Highlight SQL Queries  

###  Profit Margin per Product  
```sql
SELECT 
    product_name, 
    (price - cost_price) AS profit_margin
FROM products
ORDER BY profit_margin DESC;
```

### Highest Return Rate
```sql
SELECT 
    p.product_name,
    COUNT(r.return_id) AS total_returns,
    COUNT(od.order_id) AS total_orders,
    ROUND((COUNT(r.return_id) / COUNT(od.order_id)) * 100, 2) AS return_rate
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN returns r ON r.product_id = p.product_id
GROUP BY p.product_name
ORDER BY return_rate DESC;
```

### Lifetime Value (LTV) of Customers
```sql
SELECT 
    c.customer_id,
    c.name,
    SUM(o.total_amount) - COALESCE(SUM(p.price), 0) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
LEFT JOIN products p ON r.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY lifetime_value DESC;
```

### Revenue vs Returns by Region
```sql
SELECT 
    c.region,
    SUM(o.total_amount) AS total_revenue,
    SUM(p.price) AS total_returns,
    (SUM(o.total_amount) - SUM(p.price)) AS net_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
LEFT JOIN products p ON r.product_id = p.product_id
GROUP BY c.region
ORDER BY net_revenue DESC;
```

### Seasonal Sales Trends
```sql
SELECT 
    MONTHNAME(order_date) AS month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);
```

## 📈 Sample Insights
### Insight	Description
- Top Month:	December shows the highest sales — likely festive impact.
- Top Region:	North region contributes 40% of total revenue.
- LTV Trend:	Loyal customers with fewer returns generate the most profit.
- Top Category:	Electronics has the highest margins but also more returns.

## 💼 Project Highlights

- Designed a normalized retail database (6+ tables)
- Wrote 20+ advanced analytical SQL queries
- Identified trends, profit drivers, and return patterns
- Built a clean, insight-focused project ideal for a Data Analyst portfolio
