-- Analysis of the yearly performance of products by comparing their average sales and the previous year's sales */
WITH yearly_product_sales AS (
    SELECT
        EXTRACT(YEAR FROM f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        EXTRACT(YEAR FROM f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales::money,
    AVG(current_sales) OVER (PARTITION BY product_name)::money AS avg_sales,
    ROUND(current_sales - AVG(current_sales) OVER (PARTITION BY product_name),2)::money AS diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)::money AS prev_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year,
    CASE
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Previous Data'
    END AS prev_year_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

/* Result: [Limited to 10 rows, actual query shows all rows]
================================================================================
| order_year | product_name           | current_sales | avg_sales  | diff_avg    | avg_change | prev_year_sales | diff_prev_year | prev_year_change |
| ---------- | ---------------------- | ------------- | ---------- | ----------- | ---------- | --------------- | -------------- | ---------------- |
| 2022       | All-Purpose Bike Stand | $159.00       | $13,197.00 | -$13,038.00 | Below Avg  | null            | null           | No Previous Data |
| 2023       | All-Purpose Bike Stand | $37,683.00    | $13,197.00 | $24,486.00  | Above Avg  | $159.00         | 37524          | Increase         |
| 2024       | All-Purpose Bike Stand | $1,749.00     | $13,197.00 | -$11,448.00 | Below Avg  | $37,683.00      | -35934         | Decrease         |
| 2022       | AWC Logo Cap           | $72.00        | $6,570.00  | -$6,498.00  | Below Avg  | null            | null           | No Previous Data |
| 2023       | AWC Logo Cap           | $18,891.00    | $6,570.00  | $12,321.00  | Above Avg  | $72.00          | 18819          | Increase         |
| 2024       | AWC Logo Cap           | $747.00       | $6,570.00  | -$5,823.00  | Below Avg  | $18,891.00      | -18144         | Decrease         |
| 2023       | Bike Wash - Dissolver  | $6,960.00     | $3,636.00  | $3,324.00   | Above Avg  | null            | null           | No Previous Data |
| 2024       | Bike Wash - Dissolver  | $312.00       | $3,636.00  | -$3,324.00  | Below Avg  | $6,960.00       | -6648          | Decrease         |
| 2023       | Classic Vest- L        | $11,968.00    | $6,240.00  | $5,728.00   | Above Avg  | null            | null           | No Previous Data |
| 2024       | Classic Vest- L        | $512.00       | $6,240.00  | -$5,728.00  | Below Avg  | $11,968.00      | -11456         | Decrease         |
*/

-- Top 10 Products by revenue
WITH
  ranked_products AS (
    SELECT
      RANK() OVER (
        ORDER BY
          SUM(f.sales_amount) DESC
      ) AS "rank",
      p.product_name,
      p.category,
      p.subcategory,
      SUM(f.sales_amount)::money AS total_revenue
    FROM
      gold.fact_sales f
      LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY
      p.product_name,
      p.category,
      p.subcategory
  )
SELECT
  *
FROM
  ranked_products
WHERE
  "rank" <= 10;

/* Results:
==============================================================================
| rank | product_name            | category | subcategory    | total_revenue |
| ---- | ----------------------- | -------- | -------------- | ------------- |
| 1    | Mountain-200 Black- 46  | Bikes    | Mountain Bikes | $1,373,454.00 |
| 2    | Mountain-200 Black- 42  | Bikes    | Mountain Bikes | $1,363,128.00 |
| 3    | Mountain-200 Silver- 38 | Bikes    | Mountain Bikes | $1,339,394.00 |
| 4    | Mountain-200 Silver- 46 | Bikes    | Mountain Bikes | $1,301,029.00 |
| 5    | Mountain-200 Black- 38  | Bikes    | Mountain Bikes | $1,294,854.00 |
| 6    | Mountain-200 Silver- 42 | Bikes    | Mountain Bikes | $1,257,368.00 |
| 7    | Road-150 Red- 48        | Bikes    | Road Bikes     | $1,205,786.00 |
| 8    | Road-150 Red- 62        | Bikes    | Road Bikes     | $1,202,208.00 |
| 9    | Road-150 Red- 52        | Bikes    | Road Bikes     | $1,080,556.00 |
| 10   | Road-150 Red- 56        | Bikes    | Road Bikes     | $1,055,510.00 |
*/

-- Bottom 10 worst performing products
WITH
  ranked_products AS (
    SELECT
      RANK() OVER (
        ORDER BY
          SUM(f.sales_amount)
      ) as "rank",
      p.product_name,
      p.category,
      p.subcategory,
      SUM(f.sales_amount)::money AS total_revenue
    FROM
      gold.fact_sales f
      LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY
      p.product_name,
      p.category,
      p.subcategory
    ORDER BY
      total_revenue
  )
SELECT
  *
FROM
  ranked_products
WHERE
  "rank" <= 10

/* Results:
================================================================================
| rank | product_name          | category    | subcategory     | total_revenue |
| ---- | --------------------- | ----------- | --------------- | ------------- |
| 1    | Racing Socks- L       | Clothing    | Socks           | $2,430.00     |
| 2    | Racing Socks- M       | Clothing    | Socks           | $2,682.00     |
| 3    | Patch Kit/8 Patches   | Accessories | Tires and Tubes | $6,382.00     |
| 4    | Bike Wash - Dissolver | Accessories | Cleaners        | $7,272.00     |
| 5    | Touring Tire Tube     | Accessories | Tires and Tubes | $7,440.00     |
| 6    | Road Tire Tube        | Accessories | Tires and Tubes | $9,504.00     |
| 7    | Half-Finger Gloves- L | Clothing    | Gloves          | $10,632.00    |
| 8    | Classic Vest- S       | Clothing    | Vests           | $10,944.00    |
| 9    | Half-Finger Gloves- S | Clothing    | Gloves          | $11,712.00    |
| 10   | Half-Finger Gloves- M | Clothing    | Gloves          | $11,976.00    |
*/