WITH
  metrics AS (
    SELECT
      SUM(sales_amount)::money AS total_sales,
      SUM(quantity) AS total_quantity,
      ROUND(AVG(price), 2)::money AS avg_price,
      COUNT(distinct order_number) AS total_orders,
      MIN(order_date) AS first_order_date,
      MAX(order_date) AS last_order_date
    FROM
      gold.fact_sales
  ),
  product_metrics AS (
    SELECT
      COUNT(DISTINCT product_name) AS total_products
    FROM
      gold.dim_products
  ),
  customer_metrics AS (
    SELECT
      COUNT(customer_key) AS total_customers
    FROM
      gold.dim_customers
  )
SELECT
  'Total Sales' AS measure_name,
  total_sales::text AS measure_value
FROM
  metrics
UNION ALL
SELECT
  'Total Quantity',
  total_quantity::text
FROM
  metrics
UNION ALL
SELECT
  'Average Price',
  avg_price::text
FROM
  metrics
UNION ALL
SELECT
  'Total Orders',
  total_orders::text
FROM
  metrics
UNION ALL
SELECT
  'First Order Date',
  first_order_date::text
FROM
  metrics
UNION ALL
SELECT
  'Last Order Date',
  last_order_date::text
FROM
  metrics
UNION ALL
SELECT
  'Total Products',
  total_products::text
FROM
  product_metrics
UNION ALL
SELECT
  'Total Customers',
  total_customers::text
FROM
  customer_metrics;

/* Results:
====================================
| measure_name     | measure_value  |
| ---------------- | -------------- |
| Total Sales      | $29,356,250.00 |
| Total Quantity   | 60423          |
| Average Price    | $486.04        |
| Total Orders     | 27659          |
| First Order Date | 2020-12-29     |
| Last Order Date  | 2024-01-28     |
| Total Products   | 295            |
| Total Customers  | 18484          |
*/