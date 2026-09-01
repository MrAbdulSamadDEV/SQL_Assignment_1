SELECT product_name, list_price
FROM production.products
WHERE list_price > (
    SELECT AVG(list_price)
    FROM production.products
);

SELECT first_name, last_name
FROM sales.customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM sales.orders
);

SELECT p.product_name, p.list_price, p.category_id
FROM production.products p
WHERE p.list_price = (
    SELECT MAX(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = p.category_id
);

SELECT s.first_name, s.last_name, s.store_id
FROM sales.staffs s
WHERE s.store_id = (
    SELECT TOP 1 o.store_id
    FROM sales.orders o
    JOIN sales.order_items oi
    ON o.order_id = oi.order_id
    GROUP BY o.store_id
    ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
);

SELECT order_id, total_value
FROM (
    SELECT order_id, SUM(quantity * list_price * (1 - discount)) AS total_value
    FROM sales.order_items
    GROUP BY order_id
) AS orders
WHERE total_value > 5000;

SELECT product_name
FROM production.products
WHERE product_id NOT IN (
    SELECT product_id
    FROM sales.order_items
);

SELECT TOP 1 c.first_name, c.last_name, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o
ON c.customer_id = o.customer_id
JOIN sales.order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
