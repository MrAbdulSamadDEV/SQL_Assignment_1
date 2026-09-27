-- Task 1: Management needs a detailed sales dataset for analysis. Return one row per order item containing order_id and order_date, customer full name, store name, staff full name, product name, category name, brand name, quantity, list_price, discount, and calculated net_line_revenue. Include only completed orders (order_status = 4) and sort the result from newest order to oldest.
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    s.store_name,
    CONCAT(st.first_name, ' ', st.last_name) AS staff_full_name,
    p.product_name,
    cat.category_name,
    b.brand_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS net_line_revenue
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN sales.stores AS s
    ON o.store_id = s.store_id
INNER JOIN sales.staffs AS st
    ON o.staff_id = st.staff_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
INNER JOIN production.categories AS cat
    ON p.category_id = cat.category_id
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
WHERE o.order_status = 4
ORDER BY o.order_date DESC, o.order_id DESC;

-- Task 2: Create a store-level performance report for completed orders showing store name, number of distinct orders, total units sold, total net revenue, and average order value. Return one row per store and order the stores from highest to lowest total net revenue.
SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS distinct_order_count,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount))
        / NULLIF(COUNT(DISTINCT o.order_id), 0) AS average_order_value
FROM sales.stores AS s
LEFT JOIN sales.orders AS o
    ON s.store_id = o.store_id
    AND o.order_status = 4
LEFT JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY s.store_id, s.store_name
ORDER BY total_net_revenue DESC;

-- Task 3: Return customers whose total completed-order spending is greater than the average total spending of customers who have completed orders. Show customer_id, customer name, completed order count, and total spending. Order the result by total spending descending.
WITH CustomerSpending AS
(
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS completed_order_count,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending
    FROM sales.customers AS c
    INNER JOIN sales.orders AS o
        ON c.customer_id = o.customer_id
        AND o.order_status = 4
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    completed_order_count,
    total_spending
FROM CustomerSpending
WHERE total_spending > (SELECT AVG(total_spending) FROM CustomerSpending)
ORDER BY total_spending DESC;

-- Task 4: Return products where the stock quantity is below 5 in at least one store. Show product name, store name, current quantity, category name, and brand name. Products with zero stock should appear first, followed by the lowest remaining quantities.
SELECT
    p.product_name,
    s.store_name,
    st.quantity AS current_quantity,
    c.category_name,
    b.brand_name
FROM production.stocks AS st
INNER JOIN production.products AS p
    ON st.product_id = p.product_id
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
INNER JOIN sales.stores AS s
    ON st.store_id = s.store_id
WHERE st.quantity < 5
ORDER BY st.quantity ASC, p.product_name, s.store_name;

-- Task 5: For each product category, identify the top 3 products by total net revenue from completed orders. Return category name, product name, total units sold, total net revenue, and the product's position within its category. Tied products must receive the same position and the next position should not contain gaps.
WITH ProductRevenue AS
(
    SELECT
        c.category_id,
        c.category_name,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM production.categories AS c
    INNER JOIN production.products AS p
        ON c.category_id = p.category_id
    INNER JOIN sales.order_items AS oi
        ON p.product_id = oi.product_id
    INNER JOIN sales.orders AS o
        ON oi.order_id = o.order_id
        AND o.order_status = 4
    GROUP BY
        c.category_id,
        c.category_name,
        p.product_id,
        p.product_name
),
RankedProducts AS
(
    SELECT
        category_name,
        product_name,
        total_units_sold,
        total_net_revenue,
        DENSE_RANK() OVER
        (
            PARTITION BY category_id
            ORDER BY total_net_revenue DESC
        ) AS product_position
    FROM ProductRevenue
)
SELECT
    category_name,
    product_name,
    total_units_sold,
    total_net_revenue,
    product_position
FROM RankedProducts
WHERE product_position <= 3
ORDER BY category_name, product_position, product_name;

-- Task 6: Create a monthly sales trend for completed orders. For each calendar month return year, month, total net revenue, previous month's total net revenue, and revenue change from the previous month. The first month may have NULL for the previous-month comparison. Sort chronologically.
WITH MonthlySales AS
(
    SELECT
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    sales_year AS year,
    sales_month AS month,
    total_net_revenue,
    LAG(total_net_revenue) OVER
    (
        ORDER BY sales_year, sales_month
    ) AS previous_month_net_revenue,
    total_net_revenue
        - LAG(total_net_revenue) OVER
        (
            ORDER BY sales_year, sales_month
        ) AS revenue_change_from_previous_month
FROM MonthlySales
ORDER BY sales_year, sales_month;

-- Task 7: Create a view named sales.vw_customer_sales_summary that returns one row per customer and includes customer_id, customer full name, total number of completed orders, total units purchased, total net revenue, and most recent completed order date. Customers with no completed orders must still be represented where possible, with appropriate zero/NULL values.
CREATE OR ALTER VIEW sales.vw_customer_sales_summary
AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    COUNT(DISTINCT CASE WHEN o.order_status = 4 THEN o.order_id END) AS total_completed_orders,
    COALESCE(SUM(
        CASE
            WHEN o.order_status = 4 THEN oi.quantity
            ELSE 0
        END
    ), 0) AS total_units_purchased,
    COALESCE(SUM(
        CASE
            WHEN o.order_status = 4
            THEN oi.quantity * oi.list_price * (1 - oi.discount)
            ELSE 0
        END
    ), 0) AS total_net_revenue,
    MAX(
        CASE
            WHEN o.order_status = 4 THEN o.order_date
        END
    ) AS most_recent_completed_order_date
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;
GO

-- Task 8: A customer with customer_id = 1 has requested that their phone number be changed to '(999) 555-0101'. Write SQL that performs this update inside an explicit transaction. Include a validation query after the UPDATE and show how the change can be rolled back during testing so the assessment database is not permanently changed.
BEGIN TRANSACTION;

UPDATE sales.customers
SET phone = '(999) 555-0101'
WHERE customer_id = 1;

SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM sales.customers
WHERE customer_id = 1;

ROLLBACK TRANSACTION;
GO

-- Task 9: Create a stored procedure named sales.usp_store_sales_report with input parameters @store_id, @start_date, and @end_date. The procedure should return completed-order sales for the requested store and date range, grouped by product. Return product name, total units sold, and total net revenue, ordered by revenue descending. Add appropriate error handling for invalid date ranges where @start_date is later than @end_date.
CREATE OR ALTER PROCEDURE sales.usp_store_sales_report
    @store_id INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @start_date > @end_date
    BEGIN
        THROW 50001, 'Start date cannot be later than end date.', 1;
    END;

    SELECT
        p.product_name,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    INNER JOIN production.products AS p
        ON oi.product_id = p.product_id
    WHERE o.store_id = @store_id
      AND o.order_status = 4
      AND o.order_date >= @start_date
      AND o.order_date < DATEADD(DAY, 1, @end_date)
    GROUP BY
        p.product_id,
        p.product_name
    ORDER BY total_net_revenue DESC;
END;
GO

-- Task 10: Write one additional SQL query that provides useful insight to BikeStores management using at least three tables. Below the query, explain the business question, what the result measures, and why management should care about it.
SELECT
    s.store_name,
    b.brand_name,
    COUNT(DISTINCT o.order_id) AS completed_order_count,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
FROM sales.stores AS s
INNER JOIN sales.orders AS o
    ON s.store_id = o.store_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
WHERE o.order_status = 4
GROUP BY
    s.store_id,
    s.store_name,
    b.brand_id,
    b.brand_name
ORDER BY
    s.store_name,
    total_net_revenue DESC;
