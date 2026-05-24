SET datestyle = 'MDY';

DROP TABLE IF EXISTS source_data;

CREATE TABLE source_data (
    id INT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age INT,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    product_price NUMERIC,
    product_quantity INT,
    sale_date DATE,
    sale_customer_id INT,
    sale_seller_id INT,
    sale_product_id INT,
    sale_quantity INT,
    sale_total_price NUMERIC,
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_weight TEXT,
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_rating NUMERIC,
    product_reviews INT,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT
);

COPY source_data FROM '/data/MOCK_DATA.csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (1).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (2).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (3).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (4).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (5).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (6).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (7).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (8).csv' DELIMITER ',' CSV HEADER;
COPY source_data FROM '/data/MOCK_DATA (9).csv' DELIMITER ',' CSV HEADER;

ALTER TABLE source_data ADD COLUMN source_row_id BIGINT;
CREATE SEQUENCE source_data_source_row_id_seq OWNED BY source_data.source_row_id;

UPDATE source_data
SET source_row_id = nextval('source_data_source_row_id_seq');

SELECT setval('source_data_source_row_id_seq', MAX(source_row_id))
FROM source_data;

ALTER TABLE source_data ALTER COLUMN source_row_id SET DEFAULT nextval('source_data_source_row_id_seq');
ALTER TABLE source_data ALTER COLUMN source_row_id SET NOT NULL;
ALTER TABLE source_data ADD PRIMARY KEY (source_row_id);
