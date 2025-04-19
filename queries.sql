-- Query 1: Sales by category for the last 30 days
SELECT 
    p.category,
    SUM(s.quantity) as total_units_sold,
    SUM(s.quantity * s.sale_price) as total_revenue,
    COUNT(DISTINCT s.transaction_id) as transaction_count
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Query 2: Top 10 bestselling products
SELECT 
    p.product_name,
    p.category,
    SUM(s.quantity) as total_units_sold,
    SUM(s.quantity * s.sale_price) as total_revenue
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_units_sold DESC
LIMIT 10;

-- Query 3: Inventory turnover rate
WITH sales_last_90_days AS (
    SELECT 
        product_id,
        SUM(quantity) as units_sold
    FROM Sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY product_id
)
SELECT 
    p.product_name,
    p.category,
    i.quantity_on_hand as current_stock,
    COALESCE(s.units_sold, 0) as units_sold_90_days,