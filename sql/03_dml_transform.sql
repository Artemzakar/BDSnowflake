TRUNCATE TABLE
    fact_sales,
    dim_product,
    dim_store,
    dim_customer,
    dim_seller,
    dim_supplier,
    dim_category,
    dim_pet_category,
    dim_pet_breed,
    dim_pet_type,
    dim_country,
    dim_date
RESTART IDENTITY CASCADE;

CREATE TEMP TABLE source_keys AS
SELECT
    source_row_id,

    MIN(source_row_id) OVER (
        PARTITION BY sale_customer_id, customer_first_name, customer_last_name,
        customer_age, customer_email, customer_country, customer_postal_code,
        customer_pet_type, customer_pet_name, customer_pet_breed
    ) AS customer_key,

    MIN(source_row_id) OVER (
        PARTITION BY sale_seller_id, seller_first_name, seller_last_name,
        seller_email, seller_country, seller_postal_code
    ) AS seller_key,

    MIN(source_row_id) OVER (
        PARTITION BY store_name, store_location, store_city, store_state,
        store_country, store_phone, store_email
    ) AS store_key,

    MIN(source_row_id) OVER (
        PARTITION BY supplier_name, supplier_contact, supplier_email,
        supplier_phone, supplier_address, supplier_city, supplier_country
    ) AS supplier_key,

    MIN(source_row_id) OVER (
        PARTITION BY sale_product_id, product_name, product_category,
        product_price, product_quantity, pet_category, product_weight,
        product_color, product_size, product_brand, product_material,
        product_description, product_rating, product_reviews,
        product_release_date, product_expiry_date, supplier_name,
        supplier_contact, supplier_email, supplier_phone, supplier_address,
        supplier_city, supplier_country
    ) AS product_key
FROM source_data;

INSERT INTO dim_date (full_date, year, quarter, month, day)
SELECT DISTINCT
    sale_date,
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(QUARTER FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    EXTRACT(DAY FROM sale_date)
FROM source_data
WHERE sale_date IS NOT NULL;

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM source_data
    UNION
    SELECT seller_country FROM source_data
    UNION
    SELECT store_country FROM source_data
    UNION
    SELECT supplier_country FROM source_data
) AS countries
WHERE country_name IS NOT NULL;

INSERT INTO dim_pet_type (type_name)
SELECT DISTINCT customer_pet_type
FROM source_data
WHERE customer_pet_type IS NOT NULL;

INSERT INTO dim_pet_breed (breed_name, type_id)
SELECT DISTINCT
    s.customer_pet_breed,
    pt.type_id
FROM source_data AS s
JOIN dim_pet_type AS pt
    ON s.customer_pet_type = pt.type_name
WHERE s.customer_pet_breed IS NOT NULL;

INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category
FROM source_data
WHERE pet_category IS NOT NULL;

INSERT INTO dim_category (category_name, pet_category_id)
SELECT DISTINCT
    s.product_category,
    pc.pet_category_id
FROM source_data AS s
JOIN dim_pet_category AS pc
    ON s.pet_category = pc.pet_category_name
WHERE s.product_category IS NOT NULL;

INSERT INTO dim_supplier (
    source_key,
    supplier_name,
    contact,
    email,
    phone,
    address,
    city,
    country_id
)
SELECT
    k.supplier_key,
    s.supplier_name,
    s.supplier_contact,
    s.supplier_email,
    s.supplier_phone,
    s.supplier_address,
    s.supplier_city,
    c.country_id
FROM source_data AS s
JOIN source_keys AS k
    ON s.source_row_id = k.source_row_id
LEFT JOIN dim_country AS c
    ON s.supplier_country = c.country_name
WHERE s.source_row_id = k.supplier_key;

INSERT INTO dim_customer (
    source_key,
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    postal_code,
    country_id,
    pet_name,
    breed_id
)
SELECT
    k.customer_key,
    s.sale_customer_id,
    s.customer_first_name,
    s.customer_last_name,
    s.customer_age,
    s.customer_email,
    s.customer_postal_code,
    c.country_id,
    s.customer_pet_name,
    pb.breed_id
FROM source_data AS s
JOIN source_keys AS k
    ON s.source_row_id = k.source_row_id
LEFT JOIN dim_country AS c
    ON s.customer_country = c.country_name
LEFT JOIN dim_pet_type AS pt
    ON s.customer_pet_type = pt.type_name
LEFT JOIN dim_pet_breed AS pb
    ON s.customer_pet_breed = pb.breed_name
    AND pt.type_id = pb.type_id
WHERE s.source_row_id = k.customer_key;

INSERT INTO dim_seller (
    source_key,
    source_seller_id,
    first_name,
    last_name,
    email,
    postal_code,
    country_id
)
SELECT
    k.seller_key,
    s.sale_seller_id,
    s.seller_first_name,
    s.seller_last_name,
    s.seller_email,
    s.seller_postal_code,
    c.country_id
FROM source_data AS s
JOIN source_keys AS k
    ON s.source_row_id = k.source_row_id
LEFT JOIN dim_country AS c
    ON s.seller_country = c.country_name
WHERE s.source_row_id = k.seller_key;

INSERT INTO dim_store (
    source_key,
    store_name,
    location,
    city,
    state,
    phone,
    email,
    country_id
)
SELECT
    k.store_key,
    s.store_name,
    s.store_location,
    s.store_city,
    s.store_state,
    s.store_phone,
    s.store_email,
    c.country_id
FROM source_data AS s
JOIN source_keys AS k
    ON s.source_row_id = k.source_row_id
LEFT JOIN dim_country AS c
    ON s.store_country = c.country_name
WHERE s.source_row_id = k.store_key;

INSERT INTO dim_product (
    source_key,
    source_product_id,
    product_name,
    category_id,
    supplier_id,
    price,
    source_product_quantity,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date
)
SELECT
    k.product_key,
    s.sale_product_id,
    s.product_name,
    cat.category_id,
    sup.supplier_id,
    s.product_price,
    s.product_quantity,
    s.product_weight,
    s.product_color,
    s.product_size,
    s.product_brand,
    s.product_material,
    s.product_description,
    s.product_rating,
    s.product_reviews,
    s.product_release_date,
    s.product_expiry_date
FROM source_data AS s
JOIN source_keys AS k
    ON s.source_row_id = k.source_row_id
LEFT JOIN dim_pet_category AS pc
    ON s.pet_category = pc.pet_category_name
LEFT JOIN dim_category AS cat
    ON s.product_category = cat.category_name
    AND pc.pet_category_id = cat.pet_category_id
LEFT JOIN dim_supplier AS sup
    ON k.supplier_key = sup.source_key
WHERE s.source_row_id = k.product_key;

INSERT INTO fact_sales (
    source_row_id,
    source_sale_id,
    date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    sale_quantity,
    sale_total_price
)
SELECT
    s.source_row_id,
    s.id,
    d.date_id,
    cust.customer_id,
    sel.seller_id,
    prod.product_id,
    st.store_id,
    s.sale_quantity,
    s.sale_total_price
FROM source_data AS s
JOIN source_keys AS k
    ON s.source_row_id = k.source_row_id
JOIN dim_date AS d
    ON s.sale_date = d.full_date
JOIN dim_customer AS cust
    ON k.customer_key = cust.source_key
JOIN dim_seller AS sel
    ON k.seller_key = sel.source_key
JOIN dim_product AS prod
    ON k.product_key = prod.source_key
JOIN dim_store AS st
    ON k.store_key = st.source_key
ORDER BY s.source_row_id;
