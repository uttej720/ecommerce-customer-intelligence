/*
Purpose: Build the analytics-ready customer-order base table.
Grain: One row per order item.
Valid purchase: Order status is COMPLETE or CLOSED.
*/

DROP TABLE IF EXISTS customer_order_base;

CREATE TABLE customer_order_base AS
SELECT
    c.customer_id,
    c.customer_segment,
    c.customer_city,
    c.customer_state,
    c.customer_country,

    o.order_id,
    o.order_date_dateorders,
    o.order_status,
    o.order_region,
    o.order_city,
    o.order_state,
    o.order_country,
    o.market,

    oi.order_item_id,
    oi.product_card_id,
    oi.order_item_quantity,
    oi.sales,
    oi.order_item_total,
    oi.order_item_discount,
    oi.order_profit_per_order,

    p.product_name,
    p.product_price,
    p.product_category_id,
    p.department_name,

    cat.category_name,

    s.shipping_date_dateorders,
    s.shipping_mode,
    s.delivery_status,
    s.late_delivery_risk,
    s.days_for_shipping_real AS actual_shipping_days,
    s.days_for_shipment_scheduled AS scheduled_shipping_days,

    CASE
        WHEN o.order_status IN ('COMPLETE', 'CLOSED') THEN 1
        ELSE 0
    END AS valid_purchase,

    s.days_for_shipping_real
        - s.days_for_shipment_scheduled AS delay_days

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
    ON o.order_id = s.order_id;


