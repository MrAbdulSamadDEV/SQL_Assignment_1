SELECT TOP 10 product_name, list_price
FROM production.products
ORDER BY list_price DESC;

SELECT first_name, last_name
FROM sales.customers
ORDER BY last_name ASC, first_name ASC;

SELECT TOP 5 product_name, model_year, list_price
FROM production.products
WHERE model_year = 2018
ORDER BY list_price ASC;
