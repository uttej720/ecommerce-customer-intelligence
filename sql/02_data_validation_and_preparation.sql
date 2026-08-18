--populate categories
INSERT INTO categories (
    product_category_id,
    category_name
)
SELECT DISTINCT
    product_category_id,
    category_name
FROM raw_supply_chain
WHERE product_category_id IS NOT NULL;
---Verify immediately
SELECT COUNT(*) AS categories_loaded
FROM categories;
--Then compare against the raw data:
SELECT COUNT(DISTINCT product_category_id) AS raw_categories
FROM raw_supply_chain
WHERE product_category_id IS NOT NULL;
--Inspect the data
SELECT *
FROM categories
ORDER BY product_category_id;



--Populate customers--
INSERT INTO customers (
    customer_id,
    customer_segment,
    customer_city,
    customer_state,
    customer_country
)
SELECT DISTINCT
    customer_id,
    customer_segment,
    customer_city,
    customer_state,
    customer_country
FROM raw_supply_chain
WHERE customer_id IS NOT NULL;
--Verify
select * from customers;
SELECT COUNT(*) AS customers_loaded
FROM customers;
--Compare:
SELECT COUNT(DISTINCT customer_id) AS raw_customers
FROM raw_supply_chain
WHERE customer_id IS NOT NULL;




--Populate products--
INSERT INTO products (
    product_card_id,
    product_name,
    product_price,
    product_category_id,
    department_id,
    department_name
)
SELECT DISTINCT
    product_card_id,
    product_name,
    product_price,
    product_category_id,
    department_id,
    department_name
FROM raw_supply_chain
WHERE product_card_id IS NOT NULL;
--Verify
SELECT COUNT(*) AS products_loaded
FROM products;
--Compare:
SELECT COUNT(DISTINCT product_card_id) AS raw_products
FROM raw_supply_chain
WHERE product_card_id IS NOT NULL;




--Populate orders
INSERT INTO orders (
    order_id,
    customer_id,
    order_date_dateorders,
    order_status,
    order_region,
    order_city,
    order_state,
    order_country,
    market
)
SELECT DISTINCT
    order_id,
    customer_id,
    order_date_dateorders,
    order_status,
    order_region,
    order_city,
    order_state,
    order_country,
    market
FROM raw_supply_chain
WHERE order_id IS NOT NULL;
--Verify
SELECT COUNT(*) AS orders_loaded
FROM orders;
--Compare:
SELECT COUNT(DISTINCT order_id) AS raw_orders
FROM raw_supply_chain
WHERE order_id IS NOT NULL;




--Populate order_items
INSERT INTO order_items (
    order_item_id,
    order_id,
    product_card_id,
    order_item_quantity,
    sales,
    order_item_total,
    order_item_discount,
    order_profit_per_order
)
SELECT
    order_item_id,
    order_id,
    product_card_id,
    order_item_quantity,
    sales,
    order_item_total,
    order_item_discount,
    order_profit_per_order
FROM raw_supply_chain
WHERE order_item_id IS NOT NULL;
--Verify
SELECT COUNT(*) AS order_items_loaded
FROM order_items;
--Compare:
SELECT COUNT(DISTINCT order_item_id) AS raw_order_items
FROM raw_supply_chain
WHERE order_item_id IS NOT NULL;



--Populate shipping--
INSERT INTO shipping (
    order_id,
    shipping_date_dateorders,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    days_for_shipping_real,
    days_for_shipment_scheduled
)
SELECT DISTINCT
    order_id,
    shipping_date_dateorders,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    days_for_shipping_real,
    days_for_shipment_scheduled
FROM raw_supply_chain
WHERE order_id IS NOT NULL;
--Verify Shipping
SELECT COUNT(*) AS shipping_records
FROM shipping;
--Compare:
SELECT COUNT(DISTINCT order_id) AS raw_orders
FROM raw_supply_chain
WHERE order_id IS NOT NULL;


---all tables 
SELECT 'categories' AS table_name, COUNT(*) AS rows
FROM categories
UNION ALL
SELECT 'customers', COUNT(*)
FROM customers
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items
UNION ALL
SELECT 'shipping', COUNT(*)
FROM shipping;

--raw vs normalized
SELECT
    (SELECT COUNT(DISTINCT customer_id)
     FROM raw_supply_chain) AS raw_customers,
    (SELECT COUNT(*)
     FROM customers) AS normalized_customers,
    (SELECT COUNT(DISTINCT order_id)
     FROM raw_supply_chain) AS raw_orders,
    (SELECT COUNT(*)
     FROM orders) AS normalized_orders,
    (SELECT COUNT(DISTINCT order_item_id)
     FROM raw_supply_chain) AS raw_order_items,
    (SELECT COUNT(*)
     FROM order_items) AS normalized_order_items,
    (SELECT COUNT(DISTINCT product_card_id)
     FROM raw_supply_chain) AS raw_products,
    (SELECT COUNT(*)
     FROM products) AS normalized_products,
    (SELECT COUNT(DISTINCT product_category_id)
     FROM raw_supply_chain) AS raw_categories,
    (SELECT COUNT(*)
     FROM categories) AS normalized_categories;

--Check that the relationships actually work
SELECT
    c.customer_id,
    c.customer_segment,
    o.order_id,
    o.order_date_dateorders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;

--Test Orders → Order Items
SELECT
    o.order_id,
    o.customer_id,
    oi.order_item_id,
    oi.product_card_id,
    oi.sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;

--Test Order Items → Products
SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.product_price,
    oi.sales
FROM order_items oi
JOIN products p
    ON oi.product_card_id = p.product_card_id;

--Test Products → Categories
SELECT
    p.product_card_id,
    p.product_name,
    c.category_name
FROM products p
JOIN categories c
    ON p.product_category_id = c.product_category_id;

--Test the complete business chain
SELECT
    c.customer_id,
    c.customer_segment,
    o.order_id,
    o.order_date_dateorders,
    oi.order_item_id,
    p.product_name,
    cat.category_name,
    oi.sales,
    s.shipping_mode,
    s.delivery_status,
    s.late_delivery_risk
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_card_id = p.product_card_id
JOIN categories cat
    ON p.product_category_id = cat.product_category_id
JOIN shipping s
    ON o.order_id = s.order_id

--Primary Key Validation
SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    order_item_id,
    COUNT(*) AS occurrences
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

SELECT
    product_card_id,
    COUNT(*) AS occurrences
FROM products
GROUP BY product_card_id
HAVING COUNT(*) > 1;

SELECT
    product_category_id,
    COUNT(*) AS occurrences
FROM categories
GROUP BY product_category_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM shipping
GROUP BY order_id
HAVING COUNT(*) > 1;

--Foreign Key / Orphan Validation
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_product_items
FROM order_items oi
LEFT JOIN products p
    ON oi.product_card_id = p.product_card_id
WHERE p.product_card_id IS NULL;

SELECT COUNT(*) AS orphan_products
FROM products p
LEFT JOIN categories c
    ON p.product_category_id = c.product_category_id
WHERE c.product_category_id IS NULL;

SELECT COUNT(*) AS orphan_shipping
FROM shipping s
LEFT JOIN orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL;

--NULL Validation
SELECT
    COUNT(*) AS total_customers,
    COUNT(customer_id) AS customer_ids,
    COUNT(customer_segment) AS segments,
    COUNT(customer_city) AS cities,
    COUNT(customer_state) AS states,
    COUNT(customer_country) AS countries
FROM customers;

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_id) AS order_ids,
    COUNT(customer_id) AS customer_ids,
    COUNT(order_date_dateorders) AS order_dates,
    COUNT(order_status) AS statuses,
    COUNT(market) AS markets
FROM orders;

SELECT
    COUNT(*) AS total_items,
    COUNT(order_id) AS order_ids,
    COUNT(product_card_id) AS product_ids,
    COUNT(order_item_quantity) AS quantities,
    COUNT(sales) AS sales,
    COUNT(order_item_total) AS totals
FROM order_items;

SELECT
    COUNT(*) AS total_products,
    COUNT(product_name) AS product_names,
    COUNT(product_price) AS prices,
    COUNT(product_category_id) AS categories,
    COUNT(department_id) AS departments
FROM products;

SELECT
    COUNT(*) AS total_shipping,
    COUNT(shipping_date_dateorders) AS shipping_dates,
    COUNT(shipping_mode) AS shipping_modes,
    COUNT(delivery_status) AS delivery_statuses,
    COUNT(late_delivery_risk) AS late_risk,
    COUNT(days_for_shipping_real) AS actual_days,
    COUNT(days_for_shipment_scheduled) AS scheduled_days
FROM shipping;


--Business Consistency Checks
--A. Order should belong to one customer
SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS customer_count
FROM raw_supply_chain
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1;
--B. Product should have one category
SELECT
    product_card_id,
    COUNT(DISTINCT product_category_id) AS category_count
FROM raw_supply_chain
GROUP BY product_card_id
HAVING COUNT(DISTINCT product_category_id) > 1;
--C. Product should have consistent price
SELECT
    product_card_id,
    COUNT(DISTINCT product_price) AS price_versions
FROM raw_supply_chain
GROUP BY product_card_id
HAVING COUNT(DISTINCT product_price) > 1;
--D. Customer attributes consistency
SELECT
    customer_id,
    COUNT(DISTINCT customer_segment) AS segment_versions,
    COUNT(DISTINCT customer_city) AS city_versions,
    COUNT(DISTINCT customer_state) AS state_versions,
    COUNT(DISTINCT customer_country) AS country_versions
FROM raw_supply_chain
GROUP BY customer_id
HAVING
    COUNT(DISTINCT customer_segment) > 1
    OR COUNT(DISTINCT customer_city) > 1
    OR COUNT(DISTINCT customer_state) > 1
    OR COUNT(DISTINCT customer_country) > 1;
--E. Shipping consistency
SELECT
    order_id,
    COUNT(DISTINCT shipping_mode) AS modes,
    COUNT(DISTINCT shipping_date_dateorders) AS dates,
    COUNT(DISTINCT delivery_status) AS statuses,
    COUNT(DISTINCT late_delivery_risk) AS risks
FROM raw_supply_chain
GROUP BY order_id
HAVING
    COUNT(DISTINCT shipping_mode) > 1
    OR COUNT(DISTINCT shipping_date_dateorders) > 1
    OR COUNT(DISTINCT delivery_status) > 1
    OR COUNT(DISTINCT late_delivery_risk) > 1;


--Source-to-Target Reconciliation--
--Compare customer population
SELECT
    COUNT(DISTINCT r.customer_id) AS raw_count,
    COUNT(c.customer_id) AS normalized_count
FROM raw_supply_chain r
FULL OUTER JOIN customers c
    ON r.customer_id = c.customer_id;
--Customers in raw but missing from normalized
SELECT DISTINCT r.customer_id
FROM raw_supply_chain r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
--Customers in normalized but absent from raw
SELECT c.customer_id
FROM customers c
LEFT JOIN raw_supply_chain r
    ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL;
------------------------------------------
--Orders reconciliation
--Raw → normalized
SELECT DISTINCT r.order_id
FROM raw_supply_chain r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;
--Normalized → raw
SELECT o.order_id
FROM orders o
LEFT JOIN raw_supply_chain r
    ON o.order_id = r.order_id
WHERE r.order_id IS NULL;
------------------------------------------
--Products reconciliation
SELECT DISTINCT r.product_card_id
FROM raw_supply_chain r
LEFT JOIN products p
    ON r.product_card_id = p.product_card_id
WHERE p.product_card_id IS NULL;
--Order Items reconciliation
SELECT DISTINCT r.order_item_id
FROM raw_supply_chain r
LEFT JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;
--Categories reconciliation
SELECT DISTINCT r.product_category_id
FROM raw_supply_chain r
LEFT JOIN categories c
    ON r.product_category_id = c.product_category_id
WHERE c.product_category_id IS NULL;


---------------------------------------------------
--End-to-End JOIN Validation
SELECT
    c.customer_id,
    c.customer_segment,

    o.order_id,
    o.order_date_dateorders,

    oi.order_item_id,
    oi.sales,

    p.product_name,
    p.product_price,

    cat.category_name,
	
    s.shipping_mode,
    s.delivery_status,
    s.late_delivery_risk
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_card_id = p.product_card_id
JOIN categories cat
    ON p.product_category_id = cat.product_category_id
JOIN shipping s
    ON o.order_id = s.order_id
LIMIT 20;

--Check for Unexpected Data Loss During JOIN
SELECT COUNT(*)
FROM order_items;
--Then see how many survive the complete JOIN:
SELECT COUNT(*)
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_card_id = p.product_card_id
JOIN categories c
    ON p.product_category_id = c.product_category_id
JOIN shipping s
    ON oi.order_id = s.order_id;

--Validate Financial Fields
--Sales
SELECT
    MIN(sales) AS minimum_sales,
    MAX(sales) AS maximum_sales,
    AVG(sales) AS average_sales,
    SUM(sales) AS total_sales
FROM order_items;
--Quantity
SELECT
    MIN(order_item_quantity) AS min_quantity,
    MAX(order_item_quantity) AS max_quantity,
    AVG(order_item_quantity) AS avg_quantity
FROM order_items;
--Discount
SELECT
    MIN(order_item_discount) AS min_discount,
    MAX(order_item_discount) AS max_discount,
    AVG(order_item_discount) AS avg_discount
FROM order_items;

--Validate Shipping Measures
SELECT
    MIN(days_for_shipping_real) AS min_actual_days,
    MAX(days_for_shipping_real) AS max_actual_days,
    AVG(days_for_shipping_real) AS avg_actual_days,

    MIN(days_for_shipment_scheduled) AS min_scheduled_days,
    MAX(days_for_shipment_scheduled) AS max_scheduled_days,
    AVG(days_for_shipment_scheduled) AS avg_scheduled_days
FROM shipping;

SELECT
    late_delivery_risk,
    COUNT(*) AS orders
FROM shipping
GROUP BY late_delivery_risk
ORDER BY late_delivery_risk;

--Validate Delivery Delay Logic
SELECT
    order_id,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    days_for_shipping_real - days_for_shipment_scheduled
        AS delay_days,
    late_delivery_risk
FROM shipping;

--Validate Dates
---Check orders:
SELECT
    MIN(order_date_dateorders) AS first_order,
    MAX(order_date_dateorders) AS last_order
FROM orders;
---Shipping:
SELECT
    MIN(shipping_date_dateorders) AS first_shipping,
    MAX(shipping_date_dateorders) AS last_shipping
FROM shipping;

--------Final Database Summary-------------
SELECT
    'categories' AS table_name,
    COUNT(*) AS row_count
FROM categories
UNION ALL
SELECT 'customers', COUNT(*)
FROM customers
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items
UNION ALL
SELECT 'shipping', COUNT(*)
FROM shipping
UNION ALL
SELECT 'raw_supply_chain', COUNT(*)
FROM raw_supply_chain;

---------------------------PHASE-04------------------------------------------------
----Missing Value Analysis
--4.1.1 Customers
SELECT
    COUNT(*) AS total_customers,

    COUNT(*) - COUNT(customer_segment) AS missing_segment,
    COUNT(*) - COUNT(customer_city) AS missing_city,
    COUNT(*) - COUNT(customer_state) AS missing_state,
    COUNT(*) - COUNT(customer_country) AS missing_country
FROM customers;
--4.1.2 Orders
SELECT
    COUNT(*) AS total_orders,

    COUNT(*) - COUNT(customer_id) AS missing_customer,
    COUNT(*) - COUNT(order_date_dateorders) AS missing_order_date,
    COUNT(*) - COUNT(order_status) AS missing_status,
    COUNT(*) - COUNT(order_region) AS missing_region,
    COUNT(*) - COUNT(order_city) AS missing_city,
    COUNT(*) - COUNT(order_state) AS missing_state,
    COUNT(*) - COUNT(order_country) AS missing_country,
    COUNT(*) - COUNT(market) AS missing_market
FROM orders;
--4.1.3 Order Items
SELECT
    COUNT(*) AS total_items,

    COUNT(*) - COUNT(order_id) AS missing_order,
    COUNT(*) - COUNT(product_card_id) AS missing_product,
    COUNT(*) - COUNT(order_item_quantity) AS missing_quantity,
    COUNT(*) - COUNT(sales) AS missing_sales,
    COUNT(*) - COUNT(order_item_total) AS missing_total,
    COUNT(*) - COUNT(order_item_discount) AS missing_discount,
    COUNT(*) - COUNT(order_profit_per_order) AS missing_profit
FROM order_items;
--4.1.4 Products
SELECT
    COUNT(*) AS total_products,

    COUNT(*) - COUNT(product_name) AS missing_name,
    COUNT(*) - COUNT(product_price) AS missing_price,
    COUNT(*) - COUNT(product_category_id) AS missing_category,
    COUNT(*) - COUNT(department_id) AS missing_department,
    COUNT(*) - COUNT(department_name) AS missing_department_name
FROM products;
--4.1.5 Shipping
SELECT
    COUNT(*) AS total_shipping,

    COUNT(*) - COUNT(shipping_date_dateorders) AS missing_shipping_date,
    COUNT(*) - COUNT(shipping_mode) AS missing_mode,
    COUNT(*) - COUNT(delivery_status) AS missing_delivery_status,
    COUNT(*) - COUNT(late_delivery_risk) AS missing_risk,
    COUNT(*) - COUNT(days_for_shipping_real) AS missing_actual_days,
    COUNT(*) - COUNT(days_for_shipment_scheduled) AS missing_scheduled_days
FROM shipping;
--4.2.1 Customer consistency
SELECT
    customer_id,
    COUNT(DISTINCT customer_segment) AS segment_count,
    COUNT(DISTINCT customer_city) AS city_count,
    COUNT(DISTINCT customer_state) AS state_count,
    COUNT(DISTINCT customer_country) AS country_count
FROM raw_supply_chain
GROUP BY customer_id
HAVING
    COUNT(DISTINCT customer_segment) > 1
    OR COUNT(DISTINCT customer_city) > 1
    OR COUNT(DISTINCT customer_state) > 1
    OR COUNT(DISTINCT customer_country) > 1;
--4.2.2 Order consistency
SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_date_dateorders) AS order_dates,
    COUNT(DISTINCT order_status) AS statuses,
    COUNT(DISTINCT market) AS markets
FROM raw_supply_chain
GROUP BY order_id
HAVING
    COUNT(DISTINCT customer_id) > 1
    OR COUNT(DISTINCT order_date_dateorders) > 1
    OR COUNT(DISTINCT order_status) > 1
    OR COUNT(DISTINCT market) > 1;
--4.2.3 Product consistency
SELECT
    product_card_id,
    COUNT(DISTINCT product_name) AS names,
    COUNT(DISTINCT product_category_id) AS categories,
    COUNT(DISTINCT department_id) AS departments
FROM raw_supply_chain
GROUP BY product_card_id
HAVING
    COUNT(DISTINCT product_name) > 1
    OR COUNT(DISTINCT product_category_id) > 1
    OR COUNT(DISTINCT department_id) > 1;
--4.3 — Validate Numeric Values
--4.3.1 Quantity
SELECT
    COUNT(*) AS invalid_quantity_records
FROM order_items
WHERE order_item_quantity <= 0;
--4.3.2 Sales
SELECT
    COUNT(*) AS invalid_sales_records
FROM order_items
WHERE sales < 0;
--4.3.3 Order Item Total
SELECT
    COUNT(*) AS invalid_totals
FROM order_items
WHERE order_item_total < 0;
--4.3.4 Discount
SELECT
    MIN(order_item_discount) AS min_discount,
    MAX(order_item_discount) AS max_discount
FROM order_items;
--then
SELECT COUNT(*) AS suspicious_discounts
FROM order_items
WHERE order_item_discount < 0;
--4.3.5 Product price
SELECT
    MIN(product_price) AS minimum_price,
    MAX(product_price) AS maximum_price
FROM products;
--then
SELECT COUNT(*) AS invalid_prices
FROM products
WHERE product_price <= 0;
--4.4 — Validate Dates
--4.4.1 Order date range
SELECT
    MIN(order_date_dateorders) AS first_order,
    MAX(order_date_dateorders) AS last_order
FROM orders;
--4.4.2 Shipping date range
SELECT
    MIN(shipping_date_dateorders) AS first_shipping,
    MAX(shipping_date_dateorders) AS last_shipping
FROM shipping;
--4.4.3 Shipping before order
SELECT
    COUNT(*) AS invalid_shipping_dates
FROM orders o
JOIN shipping s
    ON o.order_id = s.order_id
WHERE s.shipping_date_dateorders < o.order_date_dateorders;
--4.4.4 Calculate actual delivery delay
SELECT
    order_id,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    days_for_shipping_real
        - days_for_shipment_scheduled AS delay_days
FROM shipping
LIMIT 20;
--4.5 — Understand order_status
SELECT
    order_status,
    COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;
--Then calculate percentages:
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY orders DESC;
--4.8 — Calculate the Purchase Cycle
SELECT
    customer_id,
    order_date_dateorders,
    LAG(order_date_dateorders)
        OVER (
            PARTITION BY customer_id
            ORDER BY order_date_dateorders
        ) AS previous_order_date
FROM orders
ORDER BY customer_id, order_date_dateorders;
--
SELECT
    customer_id,
    order_date_dateorders,
    LAG(order_date_dateorders)
        OVER (
            PARTITION BY customer_id
            ORDER BY order_date_dateorders
        ) AS previous_order_date,

    order_date_dateorders
    - LAG(order_date_dateorders)
        OVER (
            PARTITION BY customer_id
            ORDER BY order_date_dateorders
        ) AS days_between_orders

FROM orders;
--4.9 — Customer Purchase Interval Distribution
WITH purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM orders
)
SELECT
    COUNT(*) AS intervals,
    AVG(days_between_orders) AS avg_days,
    MIN(days_between_orders) AS min_days,
    MAX(days_between_orders) AS max_days
FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;

------
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;
---------
SELECT
    MIN(order_date_dateorders) AS first_order_date,
    MAX(order_date_dateorders) AS last_order_date
FROM orders;
---------------
SELECT
    SUM(sales) AS total_sales,
    SUM(order_item_total) AS total_order_item_total,
    SUM(order_profit_per_order) AS total_profit,
    AVG(sales) AS avg_sales,
    AVG(order_item_total) AS avg_order_item_total,
    AVG(order_profit_per_order) AS avg_profit
FROM order_items;
----------------
WITH purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders,
        LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS previous_order_date
    FROM orders
)
SELECT
    COUNT(*) AS total_intervals,
    AVG(
        order_date_dateorders - previous_order_date
    ) AS average_days_between_orders,
    MIN(
        order_date_dateorders - previous_order_date
    ) AS minimum_days_between_orders,
    MAX(
        order_date_dateorders - previous_order_date
    ) AS maximum_days_between_orders
FROM purchase_intervals
WHERE previous_order_date IS NOT NULL;
----------------------
WITH purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM orders
)
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY days_between_orders) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY days_between_orders) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY days_between_orders) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY days_between_orders) AS p90
FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;
--
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;
--
SELECT
    MIN(order_date_dateorders) AS first_order_date,
    MAX(order_date_dateorders) AS last_order_date
FROM orders;
--
SELECT
    SUM(sales) AS total_sales,
    SUM(order_item_total) AS total_order_item_total,
    SUM(order_profit_per_order) AS total_profit,
    AVG(sales) AS avg_sales,
    AVG(order_item_total) AS avg_order_item_total,
    AVG(order_profit_per_order) AS avg_profit
FROM order_items;
------------
WITH purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM orders
)
SELECT
    COUNT(*) AS total_intervals,
    AVG(days_between_orders) AS average_days,
    MIN(days_between_orders) AS minimum_days,
    MAX(days_between_orders) AS maximum_days
FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;
--------------------
WITH purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM orders
)
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY days_between_orders) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY days_between_orders) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY days_between_orders) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY days_between_orders) AS p90
FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;

------------------------------
SELECT
    order_status,
    COUNT(*) AS orders,
    SUM(oi.sales) AS total_sales,
    SUM(oi.order_item_total) AS total_order_value,
    SUM(oi.order_profit_per_order) AS total_profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE order_status IN ('COMPLETE', 'CLOSED')
GROUP BY order_status
ORDER BY order_status;

-----------------
SELECT
    SUM(sales) AS gross_sales,
    SUM(order_item_total) AS net_order_value,
    SUM(sales - order_item_total) AS sales_minus_total,
    SUM(order_item_discount) AS discount_field_total
FROM order_items;
----------------------
WITH valid_orders AS (
    SELECT
        customer_id,
        order_date_dateorders
    FROM orders
    WHERE order_status = 'COMPLETE'
),

purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM valid_orders
)

SELECT
    COUNT(*) AS total_intervals,

    AVG(days_between_orders) AS average_interval,

    MIN(days_between_orders) AS minimum_interval,

    MAX(days_between_orders) AS maximum_interval
FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;
-------------------------------
WITH valid_orders AS (
    SELECT
        customer_id,
        order_date_dateorders
    FROM orders
    WHERE order_status = 'COMPLETE'
),

purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM valid_orders
)

SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY days_between_orders) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY days_between_orders) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY days_between_orders) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY days_between_orders) AS p90

FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;
---------------------------------------------
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS unique_orders,
    COUNT(oi.order_item_id) AS order_items,
    SUM(oi.sales) AS total_sales,
    SUM(oi.order_item_total) AS total_order_value,
    SUM(oi.order_profit_per_order) AS total_profit,

    ROUND(
        SUM(oi.order_item_total) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status IN ('COMPLETE', 'CLOSED')

GROUP BY o.order_status
ORDER BY o.order_status;
---------------------------
SELECT
    o.order_status,

    COUNT(DISTINCT o.order_id) AS unique_orders,

    COUNT(DISTINCT o.customer_id) AS unique_customers,

    SUM(oi.sales) AS total_sales,

    SUM(oi.order_item_total) AS total_order_value,

    SUM(oi.order_profit_per_order) AS total_profit,

    AVG(oi.order_item_total) AS avg_item_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status IN ('COMPLETE', 'CLOSED')

GROUP BY o.order_status
ORDER BY o.order_status;
------------------------
SELECT
    o.order_status,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        100.0 *
        AVG(s.late_delivery_risk),
        2
    ) AS late_risk_percentage,

    ROUND(
        AVG(s.days_for_shipping_real),
        2
    ) AS avg_actual_shipping_days,

    ROUND(
        AVG(s.days_for_shipment_scheduled),
        2
    ) AS avg_scheduled_shipping_days

FROM orders o

JOIN shipping s
    ON o.order_id = s.order_id

WHERE o.order_status IN ('COMPLETE', 'CLOSED')

GROUP BY o.order_status;


------------------------------------------
WITH valid_orders AS (
    SELECT
        customer_id,
        order_date_dateorders
    FROM orders
    WHERE order_status IN ('COMPLETE', 'CLOSED')
),

purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM valid_orders
)

SELECT
    COUNT(*) AS total_intervals,

    AVG(days_between_orders) AS average_interval,

    MIN(days_between_orders) AS minimum_interval,

    MAX(days_between_orders) AS maximum_interval

FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;
------------------------
WITH valid_orders AS (
    SELECT
        customer_id,
        order_date_dateorders
    FROM orders
    WHERE order_status IN ('COMPLETE', 'CLOSED')
),

purchase_intervals AS (
    SELECT
        customer_id,
        order_date_dateorders
        - LAG(order_date_dateorders)
            OVER (
                PARTITION BY customer_id
                ORDER BY order_date_dateorders
            ) AS days_between_orders
    FROM valid_orders
)

SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY days_between_orders) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY days_between_orders) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY days_between_orders) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY days_between_orders) AS p90

FROM purchase_intervals
WHERE days_between_orders IS NOT NULL;
-----------------------------