-- creating the database
CREATE DATABASE superstore;
USE superstore;

-- creating the staging table,,,the first table that the whole dataset is loaded into
CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(20),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(20),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(10),
    region VARCHAR(20),
    product_id VARCHAR(20),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(200),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2)
);

-- creating the normalized tables
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(20),
    country VARCHAR(50),
    region VARCHAR(20),
    state VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(20),
    customer_id VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE sales (
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- inserting data into the normalized tables from the staging table
INSERT IGNORE INTO customers
SELECT
    customer_id,
    customer_name,
    segment,
    country,
    region,
    state,
    city
FROM superstore_raw;

INSERT IGNORE INTO products
SELECT
    product_id,
    product_name,
    category,
    sub_category
FROM superstore_raw;

INSERT IGNORE INTO orders
SELECT
    order_id,
    STR_TO_DATE(order_date, '%m-%d-%y'),
    STR_TO_DATE(ship_date, '%m-%d-%y'),
    ship_mode,
    customer_id
FROM superstore_raw;


INSERT INTO sales
SELECT
    order_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
FROM superstore_raw;


