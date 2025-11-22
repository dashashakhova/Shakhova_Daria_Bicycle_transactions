create table "customer" (
	customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    DOB DATE,
    job_title VARCHAR(200),
    job_industry_category VARCHAR(100),
    wealth_segment VARCHAR(50),
    deceased_indicator BOOLEAN DEFAULT FALSE,
    owns_car BOOLEAN,
    address TEXT,
    postcode VARCHAR(20),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Australia',
    property_valuation INTEGER
);


create table "product" (
	product_id INTEGER PRIMARY KEY,
	brand VARCHAR(50) not null,
	product_line VARCHAR (10) not null,
	product_class VARCHAR (10) not null,
	product_size VARCHAR (10) not null,
	list_price decimal(10,2),
	standard_cost decimal(10,2)
);


create table "orders" (
	order_id integer primary key,
	customer_id integer REFERENCES customer(customer_id),
	order_date timestamp,
	online_order boolean not null,
	order_status boolean not null
);

create table "order_items" (
	order_item_id integer primary key,
	order_id integer references orders(order_id),
	product_id integer references product(product_id),
	quantity decimal(10,2),
	item_list_price_at_sale decimal(10,2),
	item_standard_cost_at_sale decimal(10,2)
);
