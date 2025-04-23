CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_customers (
  customer_key int PRIMARY KEY,
  customer_id int NOT NULL,
  customer_number varchar(50),
  first_name varchar(50),
  last_name varchar(50),
  country varchar(50),
  marital_status varchar(50),
  gender varchar(50),
  birthdate date,
  create_date date
);

CREATE TABLE IF NOT EXISTS gold.dim_products (
  product_key int PRIMARY KEY,
  product_id int NOT NULL,
  product_number varchar(50),
  product_name varchar(50),
  category_id varchar(50),
  category varchar(50),
  subcategory varchar(50),
  maintenance varchar(50),
  cost int,
  product_line varchar(50),
  start_date date
);

CREATE TABLE IF NOT EXISTS gold.fact_sales (
  order_number varchar(50) NOT NULL,
  product_key int NOT NULL,
  customer_key int NOT NULL,
  order_date date,
  shipping_date date,
  due_date date,
  sales_amount int,
  quantity smallint,
  price int,
  PRIMARY KEY (order_number, product_key, customer_key),
  FOREIGN KEY (product_key) REFERENCES gold.dim_products (product_key),
  FOREIGN KEY (customer_key) REFERENCES gold.dim_customers (customer_key)
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_product_key on gold.fact_sales (product_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_key on gold.fact_sales (customer_key);

-- Uncomment the code below if loading data from local storage.
-- WARNING: TRUNCATE WILL DELETE ALL ROWS OF THE TABLE BEFORE LOADING DATA.

-- TRUNCATE table gold.dim_customers CASCADE;
-- COPY gold.dim_customers
-- FROM
--   '/path/to/gold.dim_customers.csv'
-- WITH
--   (FORMAT CSV, HEADER, DELIMITER ',');

-- TRUNCATE table gold.dim_products CASCADE;
-- COPY gold.dim_products
-- FROM
--   '/path/to/gold.dim_products.csv'
-- WITH
--   (FORMAT CSV, HEADER, DELIMITER ',');

-- TRUNCATE table gold.fact_sales;
-- COPY gold.fact_sales
-- FROM
--   '/path/to/gold.fact_sales.csv'
-- WITH
--   (FORMAT CSV, HEADER, DELIMITER ',');