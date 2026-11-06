-- SQL E-commerce Analysis
-- Аналитические запросы для учебного проекта на PostgreSQL.
-- Данные синтетические, период: 2025 год.
-- Выполняйте запросы по отдельности, в базе ecommerce_pet.
-- Выручка = только завершённые заказы (completed).

-- 01. Распределение заказов по статусам: число и доля от всех заказов
SELECT
    o.status,
    COUNT(*) AS orders_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM shop.orders),
        2
    ) AS percentage
FROM shop.orders AS o
GROUP BY o.status
ORDER BY orders_count DESC;


-- 02. Общая выручка по завершённым заказам
SELECT
    SUM(i.quantity * i.unit_price) AS total_revenue
FROM shop.orders AS o
JOIN shop.order_items AS i
    ON o.order_id = i.order_id
WHERE o.status = 'completed';


-- 03. Ежемесячное количество завершённых заказов и выручка
-- COUNT(DISTINCT) не допускает повторного учёта заказа с несколькими позициями.
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(i.quantity * i.unit_price) AS monthly_revenue
FROM shop.orders AS o
JOIN shop.order_items AS i
    ON o.order_id = i.order_id
WHERE o.status = 'completed'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- 04. Выручка по товарным категориям за весь период
SELECT
    c.category_name,
    SUM(i.quantity * i.unit_price) AS total_revenue
FROM shop.categories AS c
JOIN shop.products AS p
    ON c.category_id = p.category_id
JOIN shop.order_items AS i
    ON p.product_id = i.product_id
JOIN shop.orders AS o
    ON i.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;


-- 05. Выручка по категориям в апреле и июне 2025 года
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    c.category_name,
    SUM(i.quantity * i.unit_price) AS category_revenue
FROM shop.categories AS c
JOIN shop.products AS p
    ON c.category_id = p.category_id
JOIN shop.order_items AS i
    ON p.product_id = i.product_id
JOIN shop.orders AS o
    ON i.order_id = o.order_id
WHERE o.status = 'completed'
  AND EXTRACT(YEAR FROM o.order_date) = 2025
  AND EXTRACT(MONTH FROM o.order_date) IN (4, 6)
GROUP BY DATE_TRUNC('month', o.order_date), c.category_id, c.category_name
ORDER BY month, category_revenue DESC;


-- 06. Количество проданных единиц по категориям (апрель и июнь)
-- SUM(quantity) считает товары, COUNT(*) считал бы строки с позициями заказов.
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    c.category_name,
    SUM(i.quantity) AS units_sold
FROM shop.categories AS c
JOIN shop.products AS p
    ON c.category_id = p.category_id
JOIN shop.order_items AS i
    ON p.product_id = i.product_id
JOIN shop.orders AS o
    ON i.order_id = o.order_id
WHERE o.status = 'completed'
  AND EXTRACT(YEAR FROM o.order_date) = 2025
  AND EXTRACT(MONTH FROM o.order_date) IN (4, 6)
GROUP BY DATE_TRUNC('month', o.order_date), c.category_id, c.category_name
ORDER BY month, units_sold DESC;


-- 07. Средневзвешенная цена проданной единицы (апрель и июнь)
-- В отличие от AVG(unit_price), учитывает количество единиц в каждой позиции.
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    ROUND(
        SUM(i.quantity * i.unit_price) / NULLIF(SUM(i.quantity), 0),
        2
    ) AS avg_unit_price
FROM shop.orders AS o
JOIN shop.order_items AS i
    ON o.order_id = i.order_id
WHERE o.status = 'completed'
  AND EXTRACT(YEAR FROM o.order_date) = 2025
  AND EXTRACT(MONTH FROM o.order_date) IN (4, 6)
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- 08. Топ-10 товаров по выручке
SELECT
    p.product_name,
    SUM(i.quantity) AS units_sold,
    SUM(i.quantity * i.unit_price) AS total_revenue
FROM shop.products AS p
JOIN shop.order_items AS i
    ON p.product_id = i.product_id
JOIN shop.orders AS o
    ON i.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC, p.product_name
LIMIT 10;


-- 09. Топ-10 товаров по числу проданных единиц
SELECT
    p.product_name,
    SUM(i.quantity) AS units_sold,
    SUM(i.quantity * i.unit_price) AS total_revenue
FROM shop.products AS p
JOIN shop.order_items AS i
    ON p.product_id = i.product_id
JOIN shop.orders AS o
    ON i.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC, p.product_name
LIMIT 10;


-- 10. Топ-10 покупателей по числу завершённых заказов
SELECT
    c.full_name,
    COUNT(o.order_id) AS orders_count
FROM shop.customers AS c
JOIN shop.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.full_name
ORDER BY orders_count DESC, c.full_name
LIMIT 10;


-- 11. Топ-10 покупателей по выручке: число заказов и средний чек
-- После JOIN с order_items нужен DISTINCT для корректного числа заказов.
SELECT
    c.full_name,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(i.quantity * i.unit_price) AS total_spent,
    ROUND(
        SUM(i.quantity * i.unit_price) / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_check
FROM shop.customers AS c
JOIN shop.orders AS o
    ON c.customer_id = o.customer_id
JOIN shop.order_items AS i
    ON o.order_id = i.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC, c.full_name
LIMIT 10;
