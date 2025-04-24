-- Top 10 Subcategories by revenue
WITH category_revenue AS (
    SELECT 
        p.category,
        SUM(s.sales_amount) AS total_category_revenue
    FROM 
        gold.fact_sales s
    JOIN 
        gold.dim_products p ON s.product_key = p.product_key
    GROUP BY 
        p.category
)
SELECT
    p.subcategory,
    p.category,
    SUM(s.sales_amount)::money AS subcategory_revenue,
    cr.total_category_revenue::money AS category_revenue,
    ROUND((SUM(s.sales_amount) * 100.0 / cr.total_category_revenue), 2) || '%' AS "% of category"
FROM 
    gold.fact_sales s
JOIN 
    gold.dim_products p ON s.product_key = p.product_key
JOIN 
    category_revenue cr ON p.category = cr.category
GROUP BY 
    p.category, p.subcategory, cr.total_category_revenue
ORDER BY 
    subcategory_revenue DESC
LIMIT 10;

/* Result:
============================================================================================
| subcategory       | category    | subcategory_revenue | category_revenue | % of category |
| ----------------- | ----------- | ------------------- | ---------------- | ------------- |
| Road Bikes        | Bikes       | $14,519,438.00      | $28,316,272.00   | 51.28%        |
| Mountain Bikes    | Bikes       | $9,952,254.00       | $28,316,272.00   | 35.15%        |
| Touring Bikes     | Bikes       | $3,844,580.00       | $28,316,272.00   | 13.58%        |
| Tires and Tubes   | Accessories | $244,634.00         | $700,262.00      | 34.93%        |
| Helmets           | Accessories | $225,435.00         | $700,262.00      | 32.19%        |
| Jerseys           | Clothing    | $173,084.00         | $339,716.00      | 50.95%        |
| Shorts            | Clothing    | $71,330.00          | $339,716.00      | 21.00%        |
| Bottles and Cages | Accessories | $56,993.00          | $700,262.00      | 8.14%         |
| Fenders           | Accessories | $46,662.00          | $700,262.00      | 6.66%         |
| Hydration Packs   | Accessories | $40,315.00          | $700,262.00      | 5.76%         |
*/

-- Top 10 Subcategories by average sale [With difference from category avg]
WITH category_avg_sale AS (
    SELECT 
        p.category,
        AVG(s.sales_amount) AS category_avg_sale
    FROM 
        gold.fact_sales s
    JOIN 
        gold.dim_products p ON s.product_key = p.product_key
    GROUP BY 
        p.category
)
SELECT
    p.subcategory,
    p.category,
    ROUND(AVG(s.sales_amount), 2)::money AS subcategory_avg_sale,
    ROUND(cas.category_avg_sale, 2)::money AS category_avg_sale,
    ROUND((AVG(s.sales_amount) * 100.0 / cas.category_avg_sale - 100), 2) || '%' AS "% diff from category avg"
FROM 
    gold.fact_sales s
JOIN 
    gold.dim_products p ON s.product_key = p.product_key
JOIN 
    category_avg_sale cas ON p.category = cas.category
GROUP BY 
    p.category, p.subcategory, cas.category_avg_sale
ORDER BY 
    subcategory_avg_sale DESC
LIMIT 10;

/* Result:
=======================================================================================================
| subcategory     | category    | subcategory_avg_sale | category_avg_sale | % diff from category avg |
| --------------- | ----------- | -------------------- | ----------------- | ------------------------ |
| Mountain Bikes  | Bikes       | $2,002.47            | $1,862.30         | 7.53%                    |
| Road Bikes      | Bikes       | $1,799.63            | $1,862.30         | -3.37%                   |
| Touring Bikes   | Bikes       | $1,774.15            | $1,862.30         | -4.73%                   |
| Bike Stands     | Accessories | $159.00              | $19.40            | 719.50%                  |
| Bike Racks      | Accessories | $120.00              | $19.40            | 518.49%                  |
| Shorts          | Clothing    | $70.00               | $37.33            | 87.53%                   |
| Vests           | Clothing    | $64.34               | $37.33            | 72.37%                   |
| Hydration Packs | Accessories | $55.00               | $19.40            | 183.47%                  |
| Jerseys         | Clothing    | $51.95               | $37.33            | 39.16%                   |
| Helmets         | Accessories | $35.01               | $19.40            | 80.42%                   |
*/