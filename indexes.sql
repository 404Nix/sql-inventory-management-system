-- Optimize inventory lookups
CREATE INDEX idx_inventory_product ON Inventory(product_id);
CREATE INDEX idx_inventory_location ON Inventory(location_id);

-- Optimize sales reporting
CREATE INDEX idx_sales_date ON Sales(sale_date);
CREATE INDEX idx_sales_product ON Sales(product_id);
CREATE INDEX idx_sales_location ON Sales(location_id);
CREATE INDEX idx_sales_transaction ON Sales(transaction_id);

-- Optimize purchase order lookups
CREATE INDEX idx_po_supplier ON Purchase_Orders(supplier_id);
CREATE INDEX idx_po_product ON Purchase_Orders(product_id);
CREATE INDEX idx_po_status ON Purchase_Orders(status);
CREATE INDEX idx_po_dates ON Purchase_Orders(order_date, expected_delivery);

-- Optimize product lookups
CREATE INDEX idx_product_category ON Products(category);
CREATE INDEX idx_product_name ON Products(product_name);
CREATE INDEX idx_product_sku ON Products(sku);

-- Optimize employee lookups
CREATE INDEX idx_employee_location ON Employees(location_id);
CREATE INDEX idx_employee_name ON Employees(last_name, first_name);

-- Optimize location lookups
CREATE INDEX idx_location_city_state ON Locations(city, state);