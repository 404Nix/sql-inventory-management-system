-- Function for updating product timestamps on modification
CREATE OR REPLACE FUNCTION update_product_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_timestamp_trigger
BEFORE UPDATE ON Products
FOR EACH ROW
EXECUTE FUNCTION update_product_timestamp();

-- Function and trigger for automated purchase order creation
CREATE OR REPLACE FUNCTION auto_create_purchase_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity_on_hand < (SELECT reorder_level FROM Products WHERE product_id = NEW.product_id) THEN
        INSERT INTO Purchase_Orders (
            supplier_id,
            product_id,
            quantity,
            unit_cost,
            order_date,
            expected_delivery,
            status
        )
        SELECT 
            (SELECT supplier_id FROM Suppliers WHERE active = TRUE LIMIT 1),
            NEW.product_id,
            (SELECT reorder_level FROM Products WHERE product_id = NEW.product_id) * 2,
            (SELECT unit_price * 0.7 FROM Products WHERE product_id = NEW.product_id),
            CURRENT_DATE,
            CURRENT_DATE + INTERVAL '7 days',
            'pending';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_inventory_levels
AFTER UPDATE ON Inventory
FOR EACH ROW
EXECUTE FUNCTION auto_create_purchase_order();

-- Function to update inventory when purchase orders are received
CREATE OR REPLACE FUNCTION update_inventory_on_po_receipt()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'received' AND OLD.status != 'received' THEN
        -- Update the inventory at the default location (location_id=1)
        UPDATE Inventory
        SET quantity_on_hand = quantity_on_hand + NEW.quantity
        WHERE product_id = NEW.product_id AND location_id = 1;
        
        -- If no row was updated, insert a new inventory record
        IF NOT FOUND THEN
            INSERT INTO Inventory (product_id, location_id, quantity_on_hand)
            VALUES (NEW.product_id, 1, NEW.quantity);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_received_purchase_order
AFTER UPDATE ON Purchase_Orders
FOR EACH ROW
EXECUTE FUNCTION update_inventory_on_po_receipt();

-- Function to update inventory when sales occur
CREATE OR REPLACE FUNCTION update_inventory_on_sale()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Inventory
    SET quantity_on_hand = quantity_on_hand - NEW.quantity
    WHERE product_id = NEW.product_id AND location_id = NEW.location_id;
    
    -- Ensure inventory doesn't go negative
    IF (SELECT quantity_on_hand FROM Inventory 
        WHERE product_id = NEW.product_id AND location_id = NEW.location_id) < 0 THEN
        RAISE EXCEPTION 'Insufficient inventory for product %', NEW.product_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_sale
AFTER INSERT ON Sales
FOR EACH ROW
EXECUTE FUNCTION update_inventory_on_sale();

-- Function to refresh materialized views
CREATE OR REPLACE FUNCTION refresh_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW daily_sales_summary;
END;
$$ LANGUAGE plpgsql;