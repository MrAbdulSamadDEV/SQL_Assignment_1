SELECT p.product_name, b.brand_name, c.category_name
FROM production.products p
JOIN production.brands b
ON p.brand_id = b.brand_id
JOIN production.categories c
ON p.category_id = c.category_id;

SELECT o.order_id, c.first_name, c.last_name, o.order_date, o.order_status
FROM sales.orders o
JOIN sales.customers c
ON o.customer_id = c.customer_id;

SELECT oi.order_id, p.product_name, oi.quantity, oi.list_price, oi.discount
FROM sales.order_items oi
JOIN production.products p
ON oi.product_id = p.product_id;

SELECT s.first_name, s.last_name, st.store_name
FROM sales.staffs s
JOIN sales.stores st
ON s.store_id = st.store_id;

SELECT s.first_name, s.last_name, m.first_name, m.last_name
FROM sales.staffs s
LEFT JOIN sales.staffs m
ON s.manager_id = m.staff_id;

SELECT st.store_name, p.product_name, s.quantity
FROM production.stocks s
JOIN sales.stores st
ON s.store_id = st.store_id
JOIN production.products p
ON s.product_id = p.product_id
WHERE s.quantity > 0;

SELECT c.first_name, c.last_name, o.order_date
FROM sales.customers c
JOIN sales.orders o
ON c.customer_id = o.customer_id;

SELECT c.first_name, c.last_name, o.order_date, o.order_id
FROM sales.customers c
LEFT JOIN sales.orders o
ON c.customer_id = o.customer_id;
