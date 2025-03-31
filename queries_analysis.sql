-- Northwind PostgreSQL Challenge Queries
-- 1. Top 5 customers by lifetime order value
SELECT 
    c.customer_id,
    c.company_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY total_spent DESC
LIMIT 5;

-- 2. Monthly sales trend using window function
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS monthly_sales,
    ROUND(SUM(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC) OVER (ORDER BY DATE_TRUNC('month', o.order_date)), 2) AS running_total
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY month
ORDER BY month;

-- 3. Top selling products by quantity
SELECT 
    p.product_name,
    SUM(od.quantity) AS total_units_sold
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 5;

-- 4. Customer order frequency (orders per customer)
SELECT 
    c.customer_id,
    c.company_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name
ORDER BY total_orders DESC;

-- 5. Average order value per country
SELECT 
    c.country,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.country
ORDER BY avg_order_value DESC;


-- 6. RANK top products per category
SELECT 
    p.product_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(od.unit_price * od.quantity * (1 - od.discount)) DESC) AS revenue_rank
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue_rank;

-- 7. Customer reorder rate (repeat buyers)
SELECT
    c.customer_id,
    c.company_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- 8. Use CTE to calculate monthly growth rate
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY month
),
growth_calc AS (
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM monthly_sales
)
SELECT
    month,
    total_sales,
    prev_month_sales,
    ROUND(
        CASE 
            WHEN prev_month_sales = 0 OR prev_month_sales IS NULL THEN NULL
            ELSE ((total_sales - prev_month_sales) / prev_month_sales) * 100
        END, 2
    ) AS growth_rate_percent
FROM growth_calc
ORDER BY month;

