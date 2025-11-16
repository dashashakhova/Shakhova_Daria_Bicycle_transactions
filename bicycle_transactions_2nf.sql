--Вторая нормальная форма:
-- - удалены из transactions: brand_id, product_line_id, product_class_id, product_size_id, list_price, standard_cost
-- - эти поля перенесены в таблицу products, где они полностью зависят от первичного ключа

CREATE TABLE "transactions" (
  "transaction_id" int PRIMARY KEY,
  "product_id" int,
  "customer_id" int,
  "transaction_date" date,
  "online_order" boolean,
  "order_status" varchar(20)
);

CREATE TABLE "products" (
  "product_id" int PRIMARY KEY,
  "product_name" varchar(255),
  "brand_id" int,
  "product_line_id" int,
  "product_class_id" int,
  "product_size_id" int,
  "list_price" decimal(10,2),
  "standard_cost" decimal(10,2)
);

CREATE TABLE "customers" (
  "customer_id" int PRIMARY KEY,
  "customer_name" varchar(255),
  "email" varchar(255),
  "phone" varchar(50)
);

CREATE TABLE "brands" (
  "brand_id" int PRIMARY KEY,
  "brand_name" varchar(100)
);

CREATE TABLE "product_lines" (
  "product_line_id" int PRIMARY KEY,
  "product_line_name" varchar(100)
);

CREATE TABLE "product_classes" (
  "product_class_id" int PRIMARY KEY,
  "class_name" varchar(50)
);

CREATE TABLE "product_sizes" (
  "product_size_id" int PRIMARY KEY,
  "size_name" varchar(50)
);

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "products" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id");

ALTER TABLE "products" ADD FOREIGN KEY ("product_line_id") REFERENCES "product_lines" ("product_line_id");

ALTER TABLE "products" ADD FOREIGN KEY ("product_class_id") REFERENCES "product_classes" ("product_class_id");

ALTER TABLE "products" ADD FOREIGN KEY ("product_size_id") REFERENCES "product_sizes" ("product_size_id");
