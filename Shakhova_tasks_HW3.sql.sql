--1. Распределение клиентов по сферам деятельности

SELECT
    job_industry_category,
    COUNT(*) AS customer_count
FROM customer
GROUP BY job_industry_category
ORDER BY customer_count DESC;

--2. Общий доход по месяцам и сферам деятельности

SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    c.job_industry_category,
    SUM(oi.item_list_price_at_sale * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customer c ON o.customer_id = c.customer_id
WHERE o.order_status = 'Approved'
GROUP BY 
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date), 
    c.job_industry_category
ORDER BY year, month, c.job_industry_category;

--3. Уникальные онлайн-заказы по брендам для IT-клиентов

SELECT
    p.brand,
    COUNT(DISTINCT CASE WHEN o.online_order = true THEN o.order_id END) AS unique_online_orders
FROM product p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN customer c ON o.customer_id = c.customer_id
    AND c.job_industry_category = 'IT'
    AND o.order_status = 'Approved'
GROUP BY p.brand
ORDER BY unique_online_orders DESC;

--4. Статистика по клиентам

--С использованием GROUP BY:

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.item_list_price_at_sale * oi.quantity) AS total_revenue,
    MAX(oi.item_list_price_at_sale * oi.quantity) AS max_order_amount,
    MIN(oi.item_list_price_at_sale * oi.quantity) AS min_order_amount,
    COUNT(o.order_id) AS order_count,
    AVG(oi.item_list_price_at_sale * oi.quantity) AS avg_order_amount
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Approved'
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_revenue DESC NULLS LAST, order_count DESC;

--С использованием оконных функций:

SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.item_list_price_at_sale * oi.quantity) OVER (PARTITION BY c.customer_id) AS total_revenue,
    MAX(oi.item_list_price_at_sale * oi.quantity) OVER (PARTITION BY c.customer_id) AS max_order_amount,
    MIN(oi.item_list_price_at_sale * oi.quantity) OVER (PARTITION BY c.customer_id) AS min_order_amount,
    COUNT(o.order_id) OVER (PARTITION BY c.customer_id) AS order_count,
    AVG(oi.item_list_price_at_sale * oi.quantity) OVER (PARTITION BY c.customer_id) AS avg_order_amount
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Approved'
LEFT JOIN order_items oi ON o.order_id = oi.order_id
ORDER BY total_revenue DESC NULLS LAST, order_count DESC;

--5. Топ-3 клиентов по минимальной и максимальной сумме транзакций

WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(oi.item_list_price_at_sale * oi.quantity), 0) AS total_revenue
    FROM customer c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Approved'
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
ranked_customers AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        total_revenue,
        ROW_NUMBER() OVER (ORDER BY total_revenue ASC) AS min_rank,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS max_rank
    FROM customer_totals
)
SELECT
    first_name,
    last_name,
    total_revenue,
    'Min Top-3' AS rank_type
FROM ranked_customers
WHERE min_rank <= 3

UNION ALL

SELECT
    first_name,
    last_name,
    total_revenue,
    'Max Top-3' AS rank_type
FROM ranked_customers
WHERE max_rank <= 3
ORDER BY rank_type, total_revenue;

--6. Вторые транзакции клиентов

WITH ordered_orders AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_rank
    FROM orders o
    WHERE o.order_status = 'Approved'
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    oo.order_id,
    oo.order_date
FROM ordered_orders oo
JOIN customer c ON oo.customer_id = c.customer_id
WHERE oo.order_rank = 2;

--7. Максимальный интервал между заказами

WITH order_intervals AS (
    SELECT
        o.customer_id,
        o.order_date,
        LEAD(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS next_order_date,
        LEAD(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) - o.order_date AS days_between_orders
    FROM orders o
    WHERE o.order_status = 'Approved'
),
max_intervals AS (
    SELECT
        customer_id,
        MAX(days_between_orders) AS max_interval_days
    FROM order_intervals
    WHERE days_between_orders IS NOT NULL
    GROUP BY customer_id
    HAVING COUNT(*) >= 1 -- минимум два заказа (один интервал)
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_title,
    mi.max_interval_days
FROM max_intervals mi
JOIN customer c ON mi.customer_id = c.customer_id
ORDER BY mi.max_interval_days DESC;

--8. Топ-5 клиентов по доходу в каждом сегменте благосостояния

WITH customer_wealth_revenue AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.wealth_segment,
        COALESCE(SUM(oi.item_list_price_at_sale * oi.quantity), 0) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY c.wealth_segment ORDER BY COALESCE(SUM(oi.item_list_price_at_sale * oi.quantity), 0) DESC) AS wealth_rank
    FROM customer c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Approved'
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.wealth_segment
)
SELECT
    first_name,
    last_name,
    wealth_segment,
    total_revenue
FROM customer_wealth_revenue
WHERE wealth_rank <= 5
ORDER BY wealth_segment, wealth_rank;