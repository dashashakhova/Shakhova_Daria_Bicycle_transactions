--DROP TABLE IF EXISTS temp_import;

CREATE TABLE temp_import (
    transaction_id integer,
    product_id integer,
    customer_id integer,
    transaction_date varchar(100),
    online_order varchar(50),
    order_status varchar(100),
    brand varchar(200),
    product_line varchar(100),
    product_class varchar(100),
    product_size varchar(100),
    list_price decimal(10,2),
    standard_cost decimal(10,2),
    customer_id_1 integer,
    first_name varchar(200),
    last_name varchar(200),
    gender varchar(10),
    dob varchar(500),
    job_title varchar(200),
    job_industry_category varchar(100),
    wealth_segment varchar(100),
    deceased_indicator varchar(10),
    owns_car varchar(10),
    address text,
    postcode integer,
    state varchar(100),
    country varchar(100),
    property_valuation integer
);

TRUNCATE TABLE transactions CASCADE;
TRUNCATE TABLE product_prices CASCADE;
TRUNCATE TABLE product_catalog CASCADE;
TRUNCATE TABLE brands CASCADE;
TRUNCATE TABLE product_lines CASCADE;
TRUNCATE TABLE product_classes CASCADE;
TRUNCATE TABLE product_sizes CASCADE;
TRUNCATE TABLE customers CASCADE;

INSERT INTO brands (brand_id, brand_name)
SELECT 
    ROW_NUMBER() OVER (ORDER BY brand) as brand_id,
    brand as brand_name
FROM temp_import
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand;

INSERT INTO product_lines (product_line_id, product_line_name)
SELECT 
    ROW_NUMBER() OVER (ORDER BY product_line) as product_line_id,
    product_line as product_line_name
FROM temp_import
WHERE product_line IS NOT NULL AND product_line != ''
GROUP BY product_line;

INSERT INTO product_classes (product_class_id, class_name)
SELECT 
    ROW_NUMBER() OVER (ORDER BY product_class) as product_class_id,
    product_class as class_name
FROM temp_import
WHERE product_class IS NOT NULL AND product_class != ''
GROUP BY product_class;

INSERT INTO product_sizes (product_size_id, size_name)
SELECT 
    ROW_NUMBER() OVER (ORDER BY product_size) as product_size_id,
    product_size as size_name
FROM temp_import
WHERE product_size IS NOT NULL AND product_size != ''
GROUP BY product_size;

INSERT INTO customers (customer_id, customer_name, address, registration_date)
SELECT 
    ti.customer_id_1 as customer_id,
    COALESCE(ti.first_name, '') || ' ' || COALESCE(ti.last_name, '') as customer_name,
    ti.address,
    CURRENT_DATE as registration_date
FROM temp_import ti
WHERE ti.customer_id_1 IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = ti.customer_id_1)
GROUP BY ti.customer_id_1, ti.first_name, ti.last_name, ti.address;

INSERT INTO product_catalog (product_id, product_name, brand_id, product_line_id, product_class_id, product_size_id)
SELECT 
    ti.product_id,
    'Product ' || ti.product_id as product_name,
    b.brand_id,
    pl.product_line_id,
    pc.product_class_id,
    ps.product_size_id
FROM temp_import ti
LEFT JOIN brands b ON ti.brand = b.brand_name
LEFT JOIN product_lines pl ON ti.product_line = pl.product_line_name
LEFT JOIN product_classes pc ON ti.product_class = pc.class_name
LEFT JOIN product_sizes ps ON ti.product_size = ps.size_name
WHERE ti.product_id IS NOT NULL
GROUP BY ti.product_id, b.brand_id, pl.product_line_id, pc.product_class_id, ps.product_size_id
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO product_prices (price_id, product_id, list_price, standard_cost, effective_date, is_current)
SELECT 
    ROW_NUMBER() OVER (ORDER BY ti.product_id) as price_id,
    ti.product_id,
    ti.list_price,
    ti.standard_cost,
    CURRENT_DATE as effective_date,
    true as is_current
FROM temp_import ti
WHERE ti.product_id IS NOT NULL
GROUP BY ti.product_id, ti.list_price, ti.standard_cost;

INSERT INTO transactions (transaction_id, product_id, customer_id, transaction_date, online_order, order_status, sold_price, cost_price)
SELECT 
    ti.transaction_id,
    ti.product_id,
    ti.customer_id,
    TO_DATE(ti.transaction_date, 'MM/DD/YYYY') as transaction_date,
    CASE 
        WHEN ti.online_order = 'TRUE' THEN true 
        WHEN ti.online_order = 'ИСТИНА' THEN true
        ELSE false 
    END as online_order,
    ti.order_status,
    ti.list_price as sold_price,
    ti.standard_cost as cost_price
FROM temp_import ti
WHERE ti.transaction_id IS NOT NULL
AND ti.customer_id IN (SELECT customer_id FROM customers)
AND ti.product_id IN (SELECT product_id FROM product_catalog);

DROP TABLE temp_import;

SELECT 'brands' as table_name, COUNT(*) as count FROM brands
UNION ALL SELECT 'product_lines', COUNT(*) FROM product_lines
UNION ALL SELECT 'product_classes', COUNT(*) FROM product_classes
UNION ALL SELECT 'product_sizes', COUNT(*) FROM product_sizes
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'product_catalog', COUNT(*) FROM product_catalog
UNION ALL SELECT 'product_prices', COUNT(*) FROM product_prices
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;