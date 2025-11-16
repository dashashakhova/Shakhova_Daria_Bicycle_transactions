-- Третья нормальная форма:
-- - создана таблица product_prices для отдельного хранения истории цен
-- - цены вынесены из product_catalog, так как они могут меняться независимо от основных данных продукта
-- - в transactions добавлены sold_price и cost_price для фиксации цен на момент сделки

CREATE TABLE "transactions" (
  "transaction_id" int PRIMARY KEY,
  "product_id" int,
  "customer_id" int,
  "transaction_date" date,
  "online_order" boolean,
  "order_status" varchar(20),
  "sold_price" decimal(10,2),
  "cost_price" decimal(10,2)
);

CREATE TABLE "customers" (
  "customer_id" int PRIMARY KEY,
  "customer_name" varchar(255),
  "email" varchar(255),
  "phone" varchar(50),
  "address" text,
  "registration_date" date
);

CREATE TABLE "product_catalog" (
  "product_id" int PRIMARY KEY,
  "product_name" varchar(255),
  "brand_id" int,
  "product_line_id" int,
  "product_class_id" int,
  "product_size_id" int
);

CREATE TABLE "product_prices" (
  "price_id" int PRIMARY KEY,
  "product_id" int,
  "list_price" decimal(10,2),
  "standard_cost" decimal(10,2),
  "effective_date" date,
  "is_current" boolean
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

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_id") REFERENCES "product_catalog" ("product_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "product_prices" ADD FOREIGN KEY ("product_id") REFERENCES "product_catalog" ("product_id");

ALTER TABLE "product_catalog" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id");

ALTER TABLE "product_catalog" ADD FOREIGN KEY ("product_line_id") REFERENCES "product_lines" ("product_line_id");

ALTER TABLE "product_catalog" ADD FOREIGN KEY ("product_class_id") REFERENCES "product_classes" ("product_class_id");

ALTER TABLE "product_catalog" ADD FOREIGN KEY ("product_size_id") REFERENCES "product_sizes" ("product_size_id");
