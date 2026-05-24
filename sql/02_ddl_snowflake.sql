CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    quarter INT,
    month INT,
    day INT
);

CREATE TABLE dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT UNIQUE
);

CREATE TABLE dim_pet_type (
    type_id SERIAL PRIMARY KEY,
    type_name TEXT UNIQUE
);

CREATE TABLE dim_pet_breed (
    breed_id SERIAL PRIMARY KEY,
    breed_name TEXT UNIQUE,
    type_id INT REFERENCES dim_pet_type(type_id)
);

CREATE TABLE dim_category (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT UNIQUE,
    pet_category TEXT
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name TEXT UNIQUE,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country_id INT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
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
    seller_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    postal_code TEXT,
    country_id INT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name TEXT UNIQUE,
    location TEXT,
    city TEXT,
    state TEXT,
    phone TEXT,
    email TEXT,
    country_id INT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    price NUMERIC,
    weight TEXT,
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC,
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    category_id INT REFERENCES dim_category(category_id),
    supplier_id INT REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE fact_sales (
    fact_id SERIAL PRIMARY KEY,
    sale_id INT,
    date_id INT REFERENCES dim_date(date_id),
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    product_id INT REFERENCES dim_product(product_id),
    store_id INT REFERENCES dim_store(store_id),
    sale_quantity INT,
    sale_total_price NUMERIC
);