CREATE TABLE "transactions" (
  "transaction_id" int PRIMARY KEY,
  "product_id" int,
  "customer_id" int,
  "transaction_date" date,
  "online_order" boolean,
  "order_status" varchar,
  "brand_id" int,
  "product_line_id" int,
  "product_class_id" int,
  "product_size_id" int,
  "list_price" decimal(10,2),
  "standard_cost" decimal(10,2),
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "brands" (
  "brand_id" int PRIMARY KEY,
  "brand_name" varchar,
  "created_at" timestamp
);

CREATE TABLE "product_lines" (
  "product_line_id" int PRIMARY KEY,
  "product_line_name" varchar,
  "created_at" timestamp
);

CREATE TABLE "product_classes" (
  "product_class_id" int PRIMARY KEY,
  "class_name" varchar,
  "created_at" timestamp
);

CREATE TABLE "product_sizes" (
  "product_size_id" int PRIMARY KEY,
  "size_name" varchar,
  "created_at" timestamp
);

CREATE TABLE "customers" (
  "customer_id" int PRIMARY KEY,
  "first_name" varchar,
  "last_name" varchar,
  "email" varchar,
  "phone" varchar,
  "address" text,
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "products" (
  "product_id" int PRIMARY KEY,
  "product_name" varchar,
  "brand_id" int,
  "product_line_id" int,
  "product_class_id" int,
  "product_size_id" int,
  "list_price" decimal(10,2),
  "standard_cost" decimal(10,2),
  "created_at" timestamp,
  "updated_at" timestamp
);

ALTER TABLE "transactions" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_line_id") REFERENCES "product_lines" ("product_line_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_class_id") REFERENCES "product_classes" ("product_class_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_size_id") REFERENCES "product_sizes" ("product_size_id");

ALTER TABLE "products" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id");

ALTER TABLE "products" ADD FOREIGN KEY ("product_line_id") REFERENCES "product_lines" ("product_line_id");

ALTER TABLE "products" ADD FOREIGN KEY ("product_class_id") REFERENCES "product_classes" ("product_class_id");

ALTER TABLE "products" ADD FOREIGN KEY ("product_size_id") REFERENCES "product_sizes" ("product_size_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");