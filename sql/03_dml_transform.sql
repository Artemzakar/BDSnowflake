-- 1. Заполняем даты
INSERT INTO dim_date (full_date, year, quarter, month, day)
SELECT DISTINCT
    sale_date,
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(QUARTER FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    EXTRACT(DAY FROM sale_date)
FROM source_data
WHERE sale_date IS NOT NULL;

-- 2. Заполняем единый справочник стран (Снежинка)
INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name FROM (
    SELECT customer_country AS country_name FROM source_data
    UNION SELECT seller_country FROM source_data
    UNION SELECT store_country FROM source_data
    UNION SELECT supplier_country FROM source_data
) sub WHERE country_name IS NOT NULL;

-- 3. Заполняем типы питомцев (Снежинка)
INSERT INTO dim_pet_type (type_name)
SELECT DISTINCT customer_pet_type FROM source_data WHERE customer_pet_type IS NOT NULL;

-- 4. Заполняем породы питомцев (Снежинка: Порода -> Тип)
INSERT INTO dim_pet_breed (breed_name, type_id)
SELECT DISTINCT ON (s.customer_pet_breed)
    s.customer_pet_breed, pt.type_id
FROM source_data s
JOIN dim_pet_type pt ON s.customer_pet_type = pt.type_name
WHERE s.customer_pet_breed IS NOT NULL;

-- 5. Заполняем категории товаров (Снежинка)
INSERT INTO dim_category (category_name, pet_category)
SELECT DISTINCT ON (product_category)
    product_category, pet_category
FROM source_data
WHERE product_category IS NOT NULL;

-- 6. Заполняем Поставщиков (Снежинка: Поставщик -> Страна)
INSERT INTO dim_supplier (supplier_name, contact, email, phone, address, city, country_id)
SELECT DISTINCT ON (s.supplier_name)
    s.supplier_name, s.supplier_contact, s.supplier_email, s.supplier_phone, s.supplier_address, s.supplier_city, c.country_id
FROM source_data s
LEFT JOIN dim_country c ON s.supplier_country = c.country_name
WHERE s.supplier_name IS NOT NULL;

-- 7. Заполняем Клиентов (Снежинка: Клиент -> Страна, Клиент -> Порода)
INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, postal_code, country_id, pet_name, breed_id)
SELECT DISTINCT ON (s.sale_customer_id)
    s.sale_customer_id, s.customer_first_name, s.customer_last_name, s.customer_age, s.customer_email, s.customer_postal_code,
    c.country_id, s.customer_pet_name, pb.breed_id
FROM source_data s
LEFT JOIN dim_country c ON s.customer_country = c.country_name
LEFT JOIN dim_pet_breed pb ON s.customer_pet_breed = pb.breed_name
WHERE s.sale_customer_id IS NOT NULL;

-- 8. Заполняем Продавцов (Снежинка: Продавец -> Страна)
INSERT INTO dim_seller (seller_id, first_name, last_name, email, postal_code, country_id)
SELECT DISTINCT ON (s.sale_seller_id)
    s.sale_seller_id, s.seller_first_name, s.seller_last_name, s.seller_email, s.seller_postal_code, c.country_id
FROM source_data s
LEFT JOIN dim_country c ON s.seller_country = c.country_name
WHERE s.sale_seller_id IS NOT NULL;

-- 9. Заполняем Магазины (Снежинка: Магазин -> Страна)
INSERT INTO dim_store (store_name, location, city, state, phone, email, country_id)
SELECT DISTINCT ON (s.store_name)
    s.store_name, s.store_location, s.store_city, s.store_state, s.store_phone, s.store_email, c.country_id
FROM source_data s
LEFT JOIN dim_country c ON s.store_country = c.country_name
WHERE s.store_name IS NOT NULL;

-- 10. Заполняем Товары (Снежинка: Товар -> Категория, Товар -> Поставщик)
INSERT INTO dim_product (product_id, product_name, price, weight, color, size, brand, material, description, rating, reviews, release_date, expiry_date, category_id, supplier_id)
SELECT DISTINCT ON (s.sale_product_id)
    s.sale_product_id, s.product_name, s.product_price, s.product_weight, s.product_color, s.product_size, s.product_brand, s.product_material, s.product_description, s.product_rating, s.product_reviews, s.product_release_date, s.product_expiry_date,
    cat.category_id, sup.supplier_id
FROM source_data s
LEFT JOIN dim_category cat ON s.product_category = cat.category_name
LEFT JOIN dim_supplier sup ON s.supplier_name = sup.supplier_name
WHERE s.sale_product_id IS NOT NULL;

-- 11. Заполняем Факты
INSERT INTO fact_sales (sale_id, date_id, customer_id, seller_id, product_id, store_id, sale_quantity, sale_total_price)
SELECT
    s.id,
    d.date_id,
    s.sale_customer_id,
    s.sale_seller_id,
    s.sale_product_id,
    st.store_id,
    s.sale_quantity,
    s.sale_total_price
FROM source_data s
LEFT JOIN dim_date d ON s.sale_date = d.full_date
LEFT JOIN dim_store st ON s.store_name = st.store_name;