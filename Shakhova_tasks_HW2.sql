--1. Уникальные бренды со стоимостью > 1500 и продажами ≥ 1000
SELECT 
    p.brand,
    SUM(oi.quantity) as total_quantity_sold
FROM product p
JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.standard_cost > 1500
    AND EXISTS (
        SELECT 1 
        FROM product p2 
        WHERE p2.brand = p.brand 
        AND p2.standard_cost > 1500
    )
GROUP BY p.brand
HAVING SUM(oi.quantity) >= 1000
ORDER BY total_quantity_sold DESC;

--2. Количество подтвержденных онлайн-заказов и количество уникальных клиентов, совершивших эти заказы с 2017-04-01 по 2017-04-09
SELECT 
    DATE(o.order_date) as order_day,
    COUNT(o.order_id) as total_orders_count,
    COUNT(DISTINCT o.customer_id) as unique_customers_count
FROM orders o
WHERE DATE(o.order_date) BETWEEN '2017-04-01' AND '2017-04-09'
GROUP BY DATE(o.order_date)
ORDER BY order_day;

--3. Вывести профессии клиентов:
-- - из сферы IT, чья профессия начинается с Senior;
-- - из сферы Financial Services, чья профессия начинается с Lead.
SELECT 
    customer_id,
    first_name,
    last_name,
    job_title,
    job_industry_category,
    EXTRACT(YEAR FROM AGE(DOB)) as age
FROM customer
WHERE job_industry_category = 'IT'
    AND job_title LIKE 'Senior%'
    AND EXTRACT(YEAR FROM AGE(DOB)) > 35

UNION ALL

SELECT 
    customer_id,
    first_name,
    last_name,
    job_title,
    job_industry_category,
    EXTRACT(YEAR FROM AGE(DOB)) as age
FROM customer
WHERE job_industry_category = 'Financial Services'
    AND job_title LIKE 'Lead%'
    AND EXTRACT(YEAR FROM AGE(DOB)) > 35
ORDER BY job_industry_category, age DESC;

--4. Вывести бренды, которые были куплены клиентами из сферы Financial Services, но не были куплены клиентами из сферы IT.
SELECT 
    p.brand,
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'Financial Services' THEN o.customer_id END) as fs_customers,
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'IT' THEN o.customer_id END) as it_customers
FROM product p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN customer c ON o.customer_id = c.customer_id
WHERE c.job_industry_category IN ('Financial Services', 'IT')
GROUP BY p.brand
HAVING 
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'Financial Services' THEN o.customer_id END) > 0
    AND COUNT(DISTINCT CASE WHEN c.job_industry_category = 'IT' THEN o.customer_id END) > 0
ORDER BY p.brand;

--Все бренды, которые покупали Financial Services, также покупали и IT клиенты. 
--Посмотрим бренды, которые Financial Services покупали больше, чем IT
SELECT 
    p.brand,
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'Financial Services' THEN o.customer_id END) as fs_customers,
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'IT' THEN o.customer_id END) as it_customers
FROM product p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN customer c ON o.customer_id = c.customer_id
WHERE c.job_industry_category IN ('Financial Services', 'IT')
GROUP BY p.brand
HAVING 
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'Financial Services' THEN o.customer_id END) > 
    COUNT(DISTINCT CASE WHEN c.job_industry_category = 'IT' THEN o.customer_id END)
ORDER BY 
    (COUNT(DISTINCT CASE WHEN c.job_industry_category = 'Financial Services' THEN o.customer_id END) - 
     COUNT(DISTINCT CASE WHEN c.job_industry_category = 'IT' THEN o.customer_id END)) DESC;

--5. Вывести 10 клиентов (ID, имя, фамилия), которые совершили наибольшее количество онлайн-заказов (в штуках) брендов Giant Bicycles, Norco Bicycles, Trek Bicycles, при условии, что они активны и имеют оценку имущества (property_valuation) выше среднего среди клиентов из того же штата.
-- Начнем с базового запроса без строгих условий
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.state,
        c.property_valuation,
        c.deceased_indicator,
        COUNT(o.order_id) as online_orders_count
    FROM customer c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    WHERE o.online_order = true
        AND p.brand IN ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
    GROUP BY 
        c.customer_id, c.first_name, c.last_name, c.state, 
        c.property_valuation, c.deceased_indicator
)
SELECT 
    customer_id,
    first_name,
    last_name,
    online_orders_count,
    state,
    property_valuation,
    deceased_indicator
FROM customer_orders
ORDER BY online_orders_count DESC
LIMIT 10;

--6. Вывести всех клиентов (ID, имя, фамилия), у которых нет подтвержденных онлайн-заказов за последний год, но при этом они владеют автомобилем и их сегмент благосостояния не Mass Customer.
--Проверим, есть ли вообще клиенты, которые удовлетворяют условиям
SELECT 
    COUNT(*) as total_customers,
    COUNT(CASE WHEN owns_car = true THEN 1 END) as with_car,
    COUNT(CASE WHEN wealth_segment != 'Mass Customer' THEN 1 END) as not_mass_customer,
    COUNT(CASE WHEN owns_car = true AND wealth_segment != 'Mass Customer' THEN 1 END) as with_car_and_not_mass
FROM customer;

--Проверим, есть ли у этих клиентов заказы вообще
SELECT 
    COUNT(DISTINCT c.customer_id) as customers_with_any_orders
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.owns_car = true 
    AND c.wealth_segment != 'Mass Customer';

--7. Вывести всех клиентов из сферы 'IT' (ID, имя, фамилия), которые купили 2 из 5 продуктов с самой высокой list_price в продуктовой линейке Road.
WITH top_5_road_products AS (
    --Находим 5 самых дорогих продуктов в линейке Road
    SELECT 
        product_id,
        list_price
    FROM product
    WHERE product_line = 'Road'
    ORDER BY list_price DESC
    LIMIT 5
),
it_customers_road_purchases AS (
    --Находим IT клиентов и их покупки Road продуктов
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        p.product_id,
        p.list_price
    FROM customer c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    WHERE c.job_industry_category = 'IT'
        AND p.product_line = 'Road'
        AND p.product_id IN (SELECT product_id FROM top_5_road_products)
),
customers_with_2_or_more AS (
    --Выбираем клиентов, купивших минимум 2 разных продукта из топ-5
    SELECT 
        customer_id,
        first_name,
        last_name,
        COUNT(DISTINCT product_id) as unique_products_count
    FROM it_customers_road_purchases
    GROUP BY customer_id, first_name, last_name
    HAVING COUNT(DISTINCT product_id) >= 2
)
--Финальный результат
SELECT 
    customer_id,
    first_name,
    last_name,
    unique_products_count
FROM customers_with_2_or_more
ORDER BY unique_products_count DESC, customer_id;

--8. Вывести клиентов (ID, имя, фамилия, сфера деятельности) из сфер IT или Health, которые совершили не менее 3 подтвержденных заказов в период 2017-01-01 по 2017-03-01, и при этом их общий доход от этих заказов превышает 10 000 долларов.
--Разделить вывод на две группы (IT и Health) с помощью UNION.
-- - Клиенты из IT сферы
-- - IT клиенты

SELECT 
    job_industry_category,
    COUNT(*) as customer_count
FROM customer
WHERE job_industry_category IN ('IT', 'Health')
GROUP BY job_industry_category;

SELECT 
    COUNT(*) as total_orders,
    COUNT(CASE WHEN order_status = true THEN 1 END) as confirmed_orders
FROM orders
WHERE order_date BETWEEN '2017-01-01' AND '2017-03-01'; -- нет таких

-- Клиенты из IT сферы (без условия order_status)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_industry_category,
    COUNT(o.order_id) as order_count,
    SUM(oi.quantity * oi.item_list_price_at_sale) as total_revenue
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = o.order_id
WHERE c.job_industry_category = 'IT'
    AND o.order_date BETWEEN '2017-01-01' AND '2017-03-01'
GROUP BY c.customer_id, c.first_name, c.last_name, c.job_industry_category
HAVING COUNT(o.order_id) >= 3
    AND SUM(oi.quantity * oi.item_list_price_at_sale) > 10000

UNION

-- Клиенты из Health сферы (без условия order_status)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.job_industry_category,
    COUNT(o.order_id) as order_count,
    SUM(oi.quantity * oi.item_list_price_at_sale) as total_revenue
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE c.job_industry_category = 'Health'
    AND o.order_date BETWEEN '2017-01-01' AND '2017-03-01'
GROUP BY c.customer_id, c.first_name, c.last_name, c.job_industry_category
HAVING COUNT(o.order_id) >= 3
    AND SUM(oi.quantity * oi.item_list_price_at_sale) > 10000

ORDER BY job_industry_category, total_revenue DESC;
