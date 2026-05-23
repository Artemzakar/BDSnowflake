CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INT,
    email TEXT,
    country TEXT,
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT
);

CREATE TABLE dim_seller (
    seller_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    country TEXT,
    postal_code TEXT
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name TEXT UNIQUE,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name TEXT UNIQUE,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    product_category TEXT,
    pet_category TEXT,
    product_price NUMERIC,
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
    supplier_id INT REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE fact_sales (
    fact_id SERIAL PRIMARY KEY,
    sale_id INT,
    sale_date DATE,
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    product_id INT REFERENCES dim_product(product_id),
    store_id INT REFERENCES dim_store(store_id),
    sale_quantity INT,
    sale_total_price NUMERIC
);