-- View for identifying low stock items that need reordering
CREATE VIEW Low_Stock_Items AS
SELECT p.product_name, l.location_name, i.quantity_on_hand, p.reorder_level
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Locations l ON i.location_id = l.location_id
WHERE i.quantity_on_hand < p.reorder_level;

-- View for inventory valuation
CREATE VIEW Inventory_Valuation AS
SELECT 
    l.location_name,
    p.category,
    SUM(i.quantity_on_hand) AS total_units,
    SUM(i.quantity_on_hand * p.unit_price) AS total_value
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Locations l ON i.location_id = l.location_id
GROUP BY l.location_name, p.category;

-- View for product performance
CREATE VIEW Product_Performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(s.quantity) AS units_sold,
    SUM(s.quantity * s.sale_price) AS total_revenue,
    AVG(s.sale_price) AS average_sale_price,
    p.unit_price AS list_price
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY p.product_id, p.product_name, p.category, p.unit_price;

-- Materialized view for daily sales summary
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE(sale_date) as sale_day,
    l.location_name,
    p.category,
    SUM(s.quantity * s.sale_price) as daily_revenue,
    COUNT(DISTINCT s.transaction_id) as transaction_count
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
JOIN Locations l ON s.location_id = l.location_id
GROUP BY DATE(sale_date), l.location_name, p.category;