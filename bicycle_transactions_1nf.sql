--Первая нормальная форма:
-- - есть частичные зависимости
-- - нет повторяющихся групп
-- - поля атомарны
-- - ключи уникальны

CREATE TABLE "transactions" (
  "transaction_id" int PRIMARY KEY,
  "product_id" int,
  "customer_id" int,
  "transaction_date" date,
  "online_order" boolean,
  "order_status" varchar(20),
  "brand_id" int,
  "product_line_id" int,
  "product_class_id" int,
  "product_size_id" int,
  "list_price" decimal(10,2),
  "standard_cost" decimal(10,2)
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

ALTER TABLE "transactions" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_line_id") REFERENCES "product_lines" ("product_line_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_class_id") REFERENCES "product_classes" ("product_class_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_size_id") REFERENCES "product_sizes" ("product_size_id");

