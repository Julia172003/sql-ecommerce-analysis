-- Учебный pet-проект: аналитика продаж интернет-магазина
-- PostgreSQL: выполните этот файл первым в отдельной базе ecommerce_pet.
-- Все объекты будут созданы в схеме shop.

CREATE SCHEMA IF NOT EXISTS shop;
SET search_path TO shop, public;

CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    registered_at DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    product_name VARCHAR(120) NOT NULL,
    list_price NUMERIC(10, 2) NOT NULL CHECK (list_price > 0)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    status VARCHAR(12) NOT NULL CHECK (status IN ('completed', 'cancelled', 'returned', 'pending')),
    sales_channel VARCHAR(12) NOT NULL CHECK (sales_channel IN ('website', 'mobile_app'))
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0)
);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Важно: list_price = текущая цена в каталоге,
-- unit_price = фактическая цена товара в заказе (на дату покупки).
