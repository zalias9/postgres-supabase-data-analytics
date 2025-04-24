-- Analyse Category sales and items sold, with percentages
WITH category_sales AS (
    SELECT
      p.category,
      SUM(s.sales_amount)::money AS total_category_revenue,
      AVG(s.sales_amount)::money AS avg_category_revenue,
      COUNT(s.product_key) AS items_sold
    FROM
      gold.fact_sales s
    JOIN gold.dim_products p ON s.product_key = p.product_key
    GROUP BY
      p.category
),
totals AS (
    SELECT 
        SUM(s.sales_amount) AS grand_total_revenue,
        COUNT(s.product_key) AS grand_total_items
    FROM gold.fact_sales s
)
SELECT
    c.category,
    c.total_category_revenue,
    ROUND((c.total_category_revenue::numeric / t.grand_total_revenue) * 100, 2) || '%' AS pct_of_total_revenue,
    c.avg_category_revenue,
    c.items_sold,
    ROUND((c.items_sold::numeric / t.grand_total_items) * 100, 2) || '%' AS pct_of_items_sold
FROM
    category_sales c
CROSS JOIN totals t
ORDER BY
    c.total_category_revenue DESC;

/* Result:
================================
| category    | total_category_revenue | pct_of_total_revenue | avg_category_revenue | items_sold | pct_of_items_sold |
| ----------- | ---------------------- | -------------------- | -------------------- | ---------- | ----------------- |
| Bikes       | $28,316,272.00         | 96.46%               | $1,862.30            | 15205      | 25.17%            |
| Accessories | $700,262.00            | 2.39%                | $19.40               | 36092      | 59.76%            |
| Clothing    | $339,716.00            | 1.16%                | $37.33               | 9101       | 15.07%            |
*/