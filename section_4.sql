SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM production.categories c
JOIN production.products p
ON c.category_id = p.category_id
GROUP BY c.category_name;

SELECT b.brand_name, AVG(p.list_price) AS average_price
FROM production.brands b
JOIN production.products p
ON b.brand_id = p.brand_id
GROUP BY b.brand_name;

SELECT st.store_name, COUNT(o.order_id) AS order_count
FROM sales.stores st
LEFT JOIN sales.orders o
ON st.store_id = o.store_id
GROUP BY st.store_name;

SELECT order_id, SUM(quantity * list_price * (1 - discount)) AS total_revenue
FROM sales.order_items
GROUP BY order_id;

SELECT c.first_name, c.last_name, COUNT(o.order_id) AS order_count
FROM sales.customers c
LEFT JOIN sales.orders o
ON c.customer_id = o.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY order_count DESC;

SELECT TOP 1 b.brand_name, AVG(p.list_price) AS average_price
FROM production.brands b
JOIN production.products p
ON b.brand_id = p.brand_id
GROUP BY b.brand_name
ORDER BY average_price DESC;

SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM production.categories c
JOIN production.products p
ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING COUNT(p.product_id) > 50;

SELECT st.store_name, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.stores st
JOIN sales.orders o
ON st.store_id = o.store_id
JOIN sales.order_items oi
ON o.order_id = oi.order_id
GROUP BY st.store_name;

SELECT s.first_name, s.last_name, COUNT(o.order_id) AS order_count
FROM sales.staffs s
JOIN sales.orders o
ON s.staff_id = o.staff_id
GROUP BY s.first_name, s.last_name
HAVING COUNT(o.order_id) > 50;
