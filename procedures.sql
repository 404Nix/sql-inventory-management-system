-- Procedure to generate sales report
CREATE OR REPLACE PROCEDURE generate_sales_report(
    start_date DATE,
    end_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp_sales_report;
    
    CREATE TEMPORARY TABLE temp_sales_report AS
    SELECT 
        p.category,
        p.product_name,
        SUM(s.quantity) as total_quantity,
        SUM(s.quantity * s.sale_price) as total_revenue,
        COUNT(DISTINCT s.transaction_id) as transaction_count,
        l.location_name
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    JOIN Locations l ON s.location_id = l.location_id
    WHERE s.sale_date BETWEEN start_date AND end_date
    GROUP BY p.category, p.product_name, l.location_name
    ORDER BY total_revenue DESC;
END;
$$;

-- Procedure to transfer inventory between locations
CREATE OR REPLACE PROCEDURE transfer_inventory(
    product_id_param INTEGER,
    source_location_id INTEGER,
    destination_location_id INTEGER,
    transfer_quantity INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    available_quantity INTEGER;
BEGIN
    -- Check available quantity at source
    SELECT quantity_on_hand INTO available_quantity
    FROM Inventory
    WHERE product_id = product_id_param AND location_id = source_location_id;
    
    IF available_quantity IS NULL OR available_quantity < transfer_quantity THEN
        RAISE EXCEPTION 'Insufficient inventory at source location';
    END IF;
    
    -- Begin transaction
    BEGIN
        -- Reduce inventory at source
        UPDATE Inventory
        SET quantity_on_hand = quantity_on_hand - transfer_quantity
        WHERE product_id = product_id_param AND location_id = source_location_id;
        
        -- Increase inventory at destination
        UPDATE Inventory
        SET quantity_on_hand = quantity_on_hand + transfer_quantity
        WHERE product_id = product_id_param AND location_id = destination_location_id;
        
        -- If destination doesn't have this product yet, create new inventory record
        IF NOT FOUND THEN
            INSERT INTO Inventory (product_id, location_id, quantity_on_hand)
            VALUES (product_id_param, destination_location_id, transfer_quantity);
        END IF;
        
        -- Insert transfer record (assuming a Transfers table exists)
        -- INSERT INTO Transfers (product_id, source_location_id, destination_location_id, quantity, transfer_date)
        -- VALUES (product_id_param, source_location_id, destination_location_id, transfer_quantity, CURRENT_DATE);
    END;
END;
$$;

-- Procedure to process end-of-day activities
CREATE OR REPLACE PROCEDURE process_end_of_day()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Refresh materialized views
    PERFORM refresh_materialized_views();
    
    -- Archive completed purchase orders
    -- INSERT INTO Purchase_Orders_Archive
    -- SELECT * FROM Purchase_Orders
    -- WHERE status = 'received' AND received_date < CURRENT_DATE - INTERVAL '30 days';
    
    -- DELETE FROM Purchase_Orders
    -- WHERE status = 'received' AND received_date < CURRENT_DATE - INTERVAL '30 days';
    
    -- Other end-of-day processing
END;
$$;