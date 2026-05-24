DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_category CASCADE;
DROP TABLE IF EXISTS dim_pet_category CASCADE;
DROP TABLE IF EXISTS dim_pet_breed CASCADE;
DROP TABLE IF EXISTS dim_pet_type CASCADE;
DROP TABLE IF EXISTS dim_country CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INT,
    quarter INT,
    month INT,
    day INT
);

CREATE TABLE dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_type (
    type_id SERIAL PRIMARY KEY,
    type_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_breed (
    breed_id SERIAL PRIMARY KEY,
    breed_name TEXT NOT NULL,
    type_id INT NOT NULL REFERENCES dim_pet_type(type_id),
    UNIQUE (breed_name, type_id)
);

CREATE TABLE dim_pet_category (
    pet_category_id SERIAL PRIMARY KEY,
    pet_category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_category (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL,
    pet_category_id INT NOT NULL REFERENCES dim_pet_category(pet_category_id),
    UNIQUE (category_name, pet_category_id)
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    source_key BIGINT NOT NULL UNIQUE,
    supplier_name TEXT,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country_id INT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    source_key BIGINT NOT NULL UNIQUE,
    source_customer_id INT,
    first_name TEXT,
    last_name TEXT,
    age INT,
    email TEXT,
    postal_code TEXT,
    country_id INT REFERENCES dim_country(country_id),
    pet_name TEXT,
    breed_id INT REFERENCES dim_pet_breed(breed_id)
);

CREATE TABLE dim_seller (
    seller_id SERIAL PRIMARY KEY,
    source_key BIGINT NOT NULL UNIQUE,
    source_seller_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    postal_code TEXT,
    country_id INT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    source_key BIGINT NOT NULL UNIQUE,
    store_name TEXT,
    location TEXT,
    city TEXT,
    state TEXT,
    phone TEXT,
    email TEXT,
    country_id INT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    source_key BIGINT NOT NULL UNIQUE,
    source_product_id INT,
    product_name TEXT,
    category_id INT REFERENCES dim_category(category_id),
    supplier_id INT REFERENCES dim_supplier(supplier_id),
    price NUMERIC,
    source_product_quantity INT,
    weight TEXT,
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC,
    reviews INT,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE fact_sales (
    fact_id SERIAL PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE,
    source_sale_id INT,
    date_id INT NOT NULL REFERENCES dim_date(date_id),
    customer_id INT NOT NULL REFERENCES dim_customer(customer_id),
    seller_id INT NOT NULL REFERENCES dim_seller(seller_id),
    product_id INT NOT NULL REFERENCES dim_product(product_id),
    store_id INT NOT NULL REFERENCES dim_store(store_id),
    sale_quantity INT,
    sale_total_price NUMERIC
);
