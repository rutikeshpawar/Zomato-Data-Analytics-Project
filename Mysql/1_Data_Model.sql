-- STEP 1 Data Model
CREATE TABLE dim_country(
	country_id INT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO dim_country
SELECT DISTINCT CountryID, Countryname
FROM country
WHERE CountryID IS NOT NULL;

-- CURRENCY FOR USD CONVERSION LATER
CREATE TABLE dim_currency (
	currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL UNIQUE,
    usd_rate DECIMAL(12, 6) NOT NULL
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO dim_currency (currency_name, usd_rate)
SELECT DISTINCT Currency, `USD Rate`
FROM currency
WHERE Currency IS NOT NULL;

-- CITY UNIQUE PER COUNTRY
CREATE TABLE dim_city (
	city_id    INT AUTO_INCREMENT PRIMARY KEY,
  city_name  VARCHAR(100) NOT NULL,
  country_id INT NOT NULL,
  CONSTRAINT uk_city UNIQUE (city_name, country_id),
  CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES dim_country(country_id)
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO dim_city (city_name, country_id)
SELECT DISTINCT TRIM(City), CountryCode
FROM main
WHERE City IS NOT NULL AND CountryCode IS NOT NULL;

-- CUISINE (split comma list)
CREATE TABLE dim_cuisine (
  cuisine_id   INT AUTO_INCREMENT PRIMARY KEY,
  cuisine_name VARCHAR(100) NOT NULL UNIQUE
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO dim_cuisine (cuisine_name)
SELECT DISTINCT TRIM(j.cuisine)
FROM (
  SELECT DISTINCT
    NULLIF(TRIM(REPLACE(REPLACE(REPLACE(Cuisines, ', ', ','), ' ,', ','), ',,', ',')), '') AS cuisines
  FROM main
) s
JOIN JSON_TABLE(CONCAT('["', REPLACE(s.cuisines, ',', '","'), '"]'),
               '$[*]' COLUMNS (cuisine VARCHAR(100) PATH '$')) AS j
WHERE j.cuisine IS NOT NULL AND j.cuisine <> '';

-- FACT TABLE 
CREATE TABLE fact_restaurant (
  restaurant_id           BIGINT PRIMARY KEY,
  restaurant_name         VARCHAR(255) NOT NULL,
  address                 TEXT,
  locality                VARCHAR(100),
  locality_verbose        VARCHAR(255),
  longitude               DECIMAL(10,6),
  latitude                DECIMAL(10,6),
  city_id                 INT,
  country_id              INT,
  currency_id             INT,
  price_range             INT,
  votes                   INT,
  avg_cost_for_two_local  DECIMAL(10,2),
  avg_cost_for_two_usd    DECIMAL(12,2) NULL,  -- Step 3 will fill this
  rating                  DECIMAL(3,2),
  has_table_booking       TINYINT(1),
  has_online_delivery     TINYINT(1),
  is_delivering_now       TINYINT(1),
  switch_to_order_menu    TINYINT(1),
  datekey_opening         INT,                 -- used in Step 2 calendar
  CONSTRAINT fk_fr_city     FOREIGN KEY (city_id)    REFERENCES dim_city(city_id),
  CONSTRAINT fk_fr_country  FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
  CONSTRAINT fk_fr_currency FOREIGN KEY (currency_id)REFERENCES dim_currency(currency_id)
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;





-- Deduplicate stg_main by RestaurantID: keep the first row per id
CREATE TEMPORARY TABLE dedup AS
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY RestaurantID ORDER BY RestaurantID) AS rn
FROM main;

INSERT INTO fact_restaurant (
  restaurant_id, restaurant_name, address, locality, locality_verbose,
  longitude, latitude, city_id, country_id, currency_id,
  price_range, votes, avg_cost_for_two_local, rating,
  has_table_booking, has_online_delivery, is_delivering_now, switch_to_order_menu,
  datekey_opening
)
SELECT
  d.RestaurantID,
  d.RestaurantName,
  d.Address,
  d.Locality,
  d.LocalityVerbose,
  d.Longitude,
  d.Latitude,
  dc.city_id,
  d.CountryCode,
  cur.currency_id,
  d.Price_range,
  d.Votes,
  d.Average_Cost_for_two,
  d.Rating,
  CASE UPPER(COALESCE(d.Has_Table_booking, 'NO')) WHEN 'YES' THEN 1 WHEN 'Y' THEN 1 WHEN '1' THEN 1 ELSE 0 END,
  CASE UPPER(COALESCE(d.Has_Online_delivery, 'NO')) WHEN 'YES' THEN 1 WHEN 'Y' THEN 1 WHEN '1' THEN 1 ELSE 0 END,
  CASE UPPER(COALESCE(d.Is_delivering_now, 'NO')) WHEN 'YES' THEN 1 WHEN 'Y' THEN 1 WHEN '1' THEN 1 ELSE 0 END,
  CASE UPPER(COALESCE(d.Switch_to_order_menu, 'NO')) WHEN 'YES' THEN 1 WHEN 'Y' THEN 1 WHEN '1' THEN 1 ELSE 0 END,
  CASE
    WHEN d.`Year Opening` IS NOT NULL AND d.`Month Opening` IS NOT NULL AND d.`Day Opening` IS NOT NULL
      THEN (d.`Year Opening`*10000 + d.`Month Opening`*100 + d.`Day Opening`)
    ELSE NULL
  END
FROM dedup d
LEFT JOIN dim_city dc
  ON dc.city_name = TRIM(d.City) AND dc.country_id = d.CountryCode
LEFT JOIN dim_currency cur
  ON cur.currency_name = d.Currency
WHERE d.rn = 1;


-- CUISINE BRIDGE MANY TO MANY
CREATE TABLE bridge_restaurant_cuisine (
  restaurant_id BIGINT NOT NULL,
  cuisine_id    INT NOT NULL,
  PRIMARY KEY (restaurant_id, cuisine_id),
  CONSTRAINT fk_brc_rest FOREIGN KEY (restaurant_id) REFERENCES fact_restaurant(restaurant_id),
  CONSTRAINT fk_brc_cui  FOREIGN KEY (cuisine_id)    REFERENCES dim_cuisine(cuisine_id)
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO bridge_restaurant_cuisine (restaurant_id, cuisine_id)
SELECT
  m.RestaurantID,
  c.cuisine_id
FROM main m
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(REPLACE(REPLACE(m.Cuisines, ', ', ','), ' ,', ','), ',,', ','), '"]'),
       '$[*]' COLUMNS (cuisine VARCHAR(100) PATH '$')
     ) jt
JOIN dim_cuisine c
  ON c.cuisine_name COLLATE utf8mb4_unicode_ci = TRIM(jt.cuisine) COLLATE utf8mb4_unicode_ci
WHERE jt.cuisine IS NOT NULL
  AND jt.cuisine <> '';
  
  SELECT Count(*) FROM bridge_restaurant_cuisine;
  
  -- HELPFUL INDEXES
CREATE INDEX ix_fr_city            ON fact_restaurant (city_id);
CREATE INDEX ix_fr_country         ON fact_restaurant (country_id);
CREATE INDEX ix_fr_rating          ON fact_restaurant (rating);
CREATE INDEX ix_fr_price_range     ON fact_restaurant (price_range);
CREATE INDEX ix_fr_datekey_opening ON fact_restaurant (datekey_opening);


-- QUICK VALIDATION 
SELECT 'main' t, COUNT(*) FROM main
UNION ALL SELECT 'fact_restaurant', COUNT(*) FROM fact_restaurant
UNION ALL SELECT 'dim_city', COUNT(*) FROM dim_city
UNION ALL SELECT 'dim_country', COUNT(*) FROM dim_country
UNION ALL SELECT 'dim_cuisine', COUNT(*) FROM dim_cuisine
UNION ALL SELECT 'bridge_restaurant_cuisine', COUNT(*) FROM bridge_restaurant_cuisine;


