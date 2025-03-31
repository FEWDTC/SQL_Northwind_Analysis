
-- Northwind PostgreSQL Compatible Schema (Minimal Example)
CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    company_name VARCHAR NOT NULL,
    contact_name VARCHAR,
    country VARCHAR
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id VARCHAR REFERENCES customers(customer_id),
    order_date DATE,
    ship_country VARCHAR
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR NOT NULL,
    unit_price NUMERIC
);

CREATE TABLE order_details (
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    unit_price NUMERIC,
    discount REAL,
    PRIMARY KEY (order_id, product_id)
);
