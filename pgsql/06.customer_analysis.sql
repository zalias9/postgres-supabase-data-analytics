-- Top 5 ranking customers by order count [With tied ranks, so there will be more than 5 rows]
WITH customer_rank AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS order_count,
        SUM(sales_amount)::money AS total_amount,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT order_number) DESC) AS rank
    FROM gold.fact_sales
    GROUP BY customer_key
)
SELECT *
FROM customer_rank AS cr
JOIN gold.dim_customers AS gdc ON cr.customer_key = gdc.customer_key
WHERE rank <= 5
ORDER BY rank ASC;

/* Result:
============================================================================================================================================================================
| customer_key | order_count | total_amount | rank | customer_id | customer_number | first_name | last_name | country | marital_status | gender | birthdate  | create_date |
| ------------ | ----------- | ------------ | ---- | ----------- | --------------- | ---------- | --------- | ------- | -------------- | ------ | ---------- | ----------- |
| 92           | 28          | $1,186.00    | 1    | 11091       | AW00011091      | Dalton     | Perez     | Canada  | Married        | Male   | 1962-10-02 | 2025-10-07  |
| 177          | 28          | $1,317.00    | 1    | 11176       | AW00011176      | Mason      | Roberts   | Canada  | Married        | Male   | 1979-01-21 | 2025-10-07  |
| 278          | 27          | $1,434.00    | 3    | 11277       | AW00011277      | Charles    | Jackson   | Canada  | Married        | Male   | 1968-12-07 | 2025-10-08  |
| 263          | 27          | $1,124.00    | 3    | 11262       | AW00011262      | Jennifer   | Simmons   | Canada  | Married        | Female | 1975-05-01 | 2025-10-08  |
| 331          | 27          | $1,134.00    | 3    | 11330       | AW00011330      | Ryan       | Thompson  | Canada  | Married        | Male   | 1945-11-10 | 2025-10-08  |
| 186          | 27          | $1,616.00    | 3    | 11185       | AW00011185      | Ashley     | Henderson | Canada  | Single         | Female | 1950-04-07 | 2025-10-07  |
| 288          | 27          | $1,165.00    | 3    | 11287       | AW00011287      | Henry      | Garcia    | Canada  | Married        | Male   | 1966-07-16 | 2025-10-08  |
| 277          | 27          | $987.00      | 3    | 11276       | AW00011276      | Nancy      | Chapman   | Canada  | Married        | Female | 1974-09-15 | 2025-10-08  |
| 224          | 27          | $1,293.00    | 3    | 11223       | AW00011223      | Hailey     | Patterson | Canada  | Single         | Female | 1957-03-15 | 2025-10-08  |
| 201          | 27          | $1,461.00    | 3    | 11200       | AW00011200      | Jason      | Griffin   | Canada  | Married        | Male   | 1953-05-21 | 2025-10-08  |
| 712          | 27          | $1,104.00    | 3    | 11711       | AW00011711      | Daniel     | Davis     | Canada  | Single         | Male   | 1973-12-04 | 2025-10-08  |
| 301          | 27          | $1,499.00    | 3    | 11300       | AW00011300      | Fernando   | Barnes    | Canada  | Married        | Male   | 1965-08-31 | 2025-10-08  |
| 332          | 27          | $1,327.00    | 3    | 11331       | AW00011331      | Samantha   | Jenkins   | Canada  | Married        | Female | 1974-01-03 | 2025-10-08  |/
*/

-- Top 5 ranking customers by total amount [With tied ranks, so there will be more than 5 rows]
WITH customer_rank AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS order_count,
        SUM(sales_amount)::money AS total_amount,
        RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS rank
    FROM gold.fact_sales
    GROUP BY customer_key
)
SELECT *
FROM customer_rank AS cr
JOIN gold.dim_customers AS gdc ON cr.customer_key = gdc.customer_key
WHERE rank <= 5
ORDER BY rank ASC;

/* Result:
============================================================================================================================================================================
| customer_key | order_count | total_amount | rank | customer_id | customer_number | first_name | last_name | country | marital_status | gender | birthdate  | create_date |
| ------------ | ----------- | ------------ | ---- | ----------- | --------------- | ---------- | --------- | ------- | -------------- | ------ | ---------- | ----------- |
| 1133         | 5           | $13,294.00   | 1    | 12132       | AW00012132      | Kaitlyn    | Henderson | France  | Married        | Female | 1961-05-18 | 2025-10-08  |
| 1302         | 5           | $13,294.00   | 1    | 12301       | AW00012301      | Nichole    | Nara      | France  | Single         | Female | 1952-06-03 | 2025-10-08  |
| 1309         | 5           | $13,268.00   | 3    | 12308       | AW00012308      | Margaret   | He        | France  | Married        | Female | 1970-10-19 | 2025-10-08  |
| 1132         | 5           | $13,265.00   | 4    | 12131       | AW00012131      | Randall    | Dominguez | France  | Married        | Male   | 1961-04-15 | 2025-10-08  |
| 1301         | 5           | $13,242.00   | 5    | 12300       | AW00012300      | Adriana    | Gonzalez  | France  | Single         | Female | 1952-01-15 | 2025-10-08  |
*/

-- Top 10 customers by average order amount, with more than 3 orders [With difference from category avg]
WITH category_avg AS (
    SELECT AVG(order_total) AS overall_avg_amount
    FROM (
        SELECT order_number, SUM(sales_amount) AS order_total
        FROM gold.fact_sales
        GROUP BY order_number
    ) order_totals
)
SELECT
    customer_key,
    COUNT(DISTINCT order_number) AS order_count,
    SUM(sales_amount)::money AS total_amount,
    AVG(sales_amount)::money AS avg_amount,
    ((AVG(sales_amount) * 100.0 / (SELECT overall_avg_amount FROM category_avg)) - 100)::numeric(5,2) AS "% diff from overall avg"
FROM gold.fact_sales
GROUP BY customer_key
HAVING COUNT(DISTINCT order_number) > 3
ORDER BY avg_amount DESC
LIMIT 10;

/* Result:
============================================================================================================================================================================
| customer_key | order_count | total_amount | avg_amount | % diff from overall avg |
| ------------ | ----------- | ------------ | ---------- | ----------------------- |
| 422          | 4           | $9,780.00    | $2,445.00  | 130.36                  |
| 1633         | 4           | $10,793.00   | $1,798.83  | 69.48                   |
| 238          | 4           | $10,566.00   | $1,761.00  | 65.92                   |
| 247          | 4           | $10,575.00   | $1,510.71  | 42.34                   |
| 2593         | 4           | $9,695.00    | $1,385.00  | 30.49                   |
| 2606         | 4           | $9,614.00    | $1,373.43  | 29.40                   |
| 1301         | 5           | $13,242.00   | $1,324.20  | 24.76                   |
| 1132         | 5           | $13,265.00   | $1,205.91  | 13.62                   |
| 1651         | 4           | $10,813.00   | $1,201.44  | 13.20                   |
| 2262         | 4           | $7,200.00    | $1,200.00  | 13.06                   |
*/