-- Проверка, что таблицы заполнены.
SET search_path TO shop, public;

SELECT 'categories' AS table_name, COUNT(*) AS rows_count FROM categories
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

-- Ожидаемые числа строк: categories = 6; customers = 150;
-- products = 54; orders = 720; order_items = см. результат запроса.
