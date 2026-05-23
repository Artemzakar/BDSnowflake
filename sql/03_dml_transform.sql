INSERT INTO dim_supplier (supplier_name, contact, email, phone, address, city, country)
SELECT DISTINCT ON (supplier_name)
    supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
FROM source_data
WHERE supplier_name IS NOT NULL;

INSERT INTO dim_store (store_name, location, city, state, country, phone, email)
SELECT DISTINCT ON (store_name)
    store_name, store_location, store_city, store_state, store_country, store_phone, store_email
FROM source_data
WHERE store_name IS NOT NULL;

INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code, pet_type, pet_name, pet_breed)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id, customer_first_name, customer_last_name, customer_age, customer_email, customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed
FROM source_data
WHERE sale_customer_id IS NOT NULL;

INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id, seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code
FROM source_data
WHERE sale_seller_id IS NOT NULL;

INSERT INTO dim_product (product_id, product_name, product_category, pet_category, product_price, weight, color, size, brand, material, description, rating, reviews, release_date, expiry_date, supplier_id)
SELECT DISTINCT ON (s.sale_product_id)
    s.sale_product_id, s.product_name, s.product_category, s.pet_category, s.product_price, s.product_weight, s.product_color, s.product_size, s.product_brand, s.product_material, s.product_description, s.product_rating, s.product_reviews, s.product_release_date, s.product_expiry_date,
    sup.supplier_id
FROM source_data s
LEFT JOIN dim_supplier sup ON s.supplier_name = sup.supplier_name
WHERE s.sale_product_id IS NOT NULL;

INSERT INTO fact_sales (sale_id, sale_date, customer_id, seller_id, product_id, store_id, sale_quantity, sale_total_price)
SELECT
    s.id,
    s.sale_date,
    s.sale_customer_id,
    s.sale_seller_id,
    s.sale_product_id,
    st.store_id,
    s.sale_quantity,
    s.sale_total_price
FROM source_data s
LEFT JOIN dim_store st ON s.store_name = st.store_name;