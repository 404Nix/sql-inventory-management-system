-- Create database (uncomment if needed)
-- CREATE DATABASE inventory_management;

-- Product information
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL,
    reorder_level INTEGER DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Store locations
CREATE TABLE Locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(30),
    zip VARCHAR(20),
    manager_id INTEGER
);

-- Supplier information
CREATE TABLE Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    payment_terms VARCHAR(50),
    active BOOLEAN DEFAULT TRUE
);

-- Inventory per location
CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES Products(product_id),
    location_id INTEGER REFERENCES Locations(location_id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    last_count_date DATE,
    UNIQUE(product_id, location_id)
);

-- Purchase orders
CREATE TABLE Purchase_Orders (
    po_id SERIAL PRIMARY KEY,
    supplier_id INTEGER REFERENCES Suppliers(supplier_id),
    product_id INTEGER REFERENCES Products(product_id),
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery DATE,
    status VARCHAR(20) DEFAULT 'pending',
    received_date DATE
);

-- Employee information
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50),
    location_id INTEGER REFERENCES Locations(location_id),
    hire_date DATE NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Sales transactions
CREATE TABLE Sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES Products(product_id),
    location_id INTEGER REFERENCES Locations(location_id),
    employee_id INTEGER REFERENCES Employees(employee_id),
    sale_date TIMESTAMP NOT NULL,
    quantity INTEGER NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    transaction_id VARCHAR(50) NOT NULL
);

-- Create partitioned sales table for historical data
CREATE TABLE Sales_Partitioned (
    sale_id SERIAL,
    product_id INTEGER REFERENCES Products(product_id),
    location_id INTEGER REFERENCES Locations(location_id),
    employee_id INTEGER REFERENCES Employees(employee_id),
    sale_date TIMESTAMP NOT NULL,
    quantity INTEGER NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    transaction_id VARCHAR(50) NOT NULL
) PARTITION BY RANGE (sale_date);

-- Create quarterly partitions
CREATE TABLE sales_q1_2024 PARTITION OF Sales_Partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
CREATE TABLE sales_q2_2024 PARTITION OF Sales_Partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');