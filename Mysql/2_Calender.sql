-- Q.2 Calendar Table - Build a Calendar Table using the Columns Datekey_Opening
CREATE TABLE dim_calendar (
    datekey INT PRIMARY KEY,         -- YYYYMMDD format
    full_date DATE NOT NULL,
    year INT NOT NULL,
    monthno INT NOT NULL,
    monthfullname VARCHAR(20) NOT NULL,
    quarter VARCHAR(2) NOT NULL,
    yearmonth VARCHAR(8) NOT NULL,
    weekdayno INT NOT NULL,
    weekdayname VARCHAR(15) NOT NULL,
    financialmonth VARCHAR(5) NOT NULL,
    financialquarter VARCHAR(5) NOT NULL
);

-- GET MIN AND MAX DATE FROM FACT TABLE
SELECT 
	MIN(STR_TO_DATE(datekey_opening, '%Y%m%d')) AS min_date,
    MAX(STR_TO_DATE(datekey_opening, '%Y%m%d')) AS max_date
FROM fact_restaurant;


-- CTE FOR DATEKEY 
SET SESSION cte_max_recursion_depth = 10000;

INSERT INTO dim_calendar
WITH RECURSIVE cte AS (
    SELECT MIN(STR_TO_DATE(datekey_opening, '%Y%m%d')) AS dt
    FROM fact_restaurant
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM cte
    WHERE dt < (SELECT MAX(STR_TO_DATE(datekey_opening, '%Y%m%d')) FROM fact_restaurant)
)
SELECT 
    DATE_FORMAT(dt, '%Y%m%d') AS datekey,
    dt AS full_date,
    YEAR(dt) AS year,
    MONTH(dt) AS monthno,
    MONTHNAME(dt) AS monthfullname,
    CONCAT('Q', QUARTER(dt)) AS quarter,
    DATE_FORMAT(dt, '%Y-%b') AS yearmonth,
    DAYOFWEEK(dt) AS weekdayno,
    DAYNAME(dt) AS weekdayname,
    CONCAT('FM', (MONTH(dt) + 9) % 12 + 1) AS financialmonth,
    CONCAT('FQ', (((MONTH(dt) + 9) % 12) DIV 3) + 1) AS financialquarter
FROM cte;

select * from dim_calendar;


-- Q4. Find the Numbers of Resturants based on City and Country.
-- Resturants based on City
SELECT City, count(RestaurantID) AS Total_Restaurant
FROM main
GROUP BY City;

-- Resturants based on Country
SELECT Countryname, COUNT(RestaurantID) 
FROM main m
JOIN country c ON m.CountryCode = c.CountryID
GROUP BY Countryname;

-- Resturants based on Country, City
SELECT c.Countryname, m.City, COUNT(m.RestaurantID) AS Total_Restaurant
FROM main m
JOIN Country c ON m.CountryCode = c.CountryID
GROUP BY m.City, c.CountryName;


-- Q5. Numbers of Resturants opening based on Year , Quarter , Month
-- Total Resturants open YEARWISE
SELECT YEAR(Datekey_Opening) AS Opening_Year, COUNT(*) AS Total_Restaurants
FROM fact_restaurant
GROUP BY YEAR(Datekey_Opening)
ORDER BY Opening_Year;

-- Total Resturants open Quarter-wise
SELECT YEAR(Datekey_Opening) AS Opening_Year,
QUARTER(Datekey_Opening) AS Opening_Quarter,
COUNT(*) AS Total_Restaurants
FROM fact_restaurant
GROUP BY Opening_Year, Opening_Quarter
ORDER BY Opening_Year, Opening_Quarter;

-- Total Resturants open MONTHWISE
SELECT 	YEAR(Datekey_Opening) AS Opening_Year, 
		MONTH(Datekey_Opening) AS Opening_Month_Number,
		MONTHNAME(Datekey_Opening) AS Opening_Month_Name,
		COUNT(*) AS Total_Restaurants
FROM fact_restaurant
GROUP BY Opening_Year, Opening_Month_Number, Opening_Month_Name
ORDER BY Opening_Year, Opening_Month_Number;

-- Only Month
SELECT 	MONTH(Datekey_Opening) AS Opening_Month_Number,
		MONTHNAME(Datekey_Opening) AS Opening_Month_Name,
		COUNT(*) AS Total_Restaurants
FROM fact_restaurant
GROUP BY Opening_Month_Number, Opening_Month_Name
ORDER BY Opening_Month_Number;

-- Q6. Count of Resturants based on Average Ratings
SELECT Rating, COUNT(*) Total_Restaurants
FROM fact_restaurant
GROUP BY Rating
ORDER BY Rating DESC;

-- Rating with 1,2,3,4,5
SELECT 
    CASE 
        WHEN Rating < 1 THEN '1'
        WHEN Rating < 2 THEN '2'
        WHEN Rating < 3 THEN '3'
        WHEN Rating < 4 THEN '4'
        WHEN Rating <= 5 THEN '5'
        ELSE 'No Rating'
    END AS Rating_Range,
    COUNT(*) AS Total_Restaurants
FROM fact_restaurant
GROUP BY Rating_Range
ORDER BY Rating_Range;


-- Q7. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
SELECT 
    CASE 
        WHEN avg_cost_for_two_local <= 500 THEN '0 - 500'
        WHEN avg_cost_for_two_local <= 1000 THEN '501 - 1000'
        WHEN avg_cost_for_two_local <= 2000 THEN '1001 - 2000'
        WHEN avg_cost_for_two_local <= 5000 THEN '2001 - 5000'
        ELSE '5001+'
    END AS Price_Bucket,
    COUNT(*) AS Total_Restaurants
FROM fact_restaurant
GROUP BY Price_Bucket
ORDER BY MIN(avg_cost_for_two_local);

-- Q8. Percentage of Resturants based on "Has_Table_booking"
SELECT Has_Table_booking, COUNT(*) AS Total_Restaurants, 
	ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_restaurant)), 2) AS Percentage
FROM fact_restaurant
GROUP BY Has_Table_booking;

-- Q9. Percentage of Resturants based on "Has_Online_delivery"
SELECT Has_Online_delivery, COUNT(*) AS Total_Restaurants,
ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_restaurant)), 2) AS Percentage
FROM fact_restaurant
GROUP BY Has_Online_delivery;


-- Q10.-- Cuisine-wise Restaurants
SELECT Cuisines, COUNT(*) AS Total_Restaurants
FROM main
GROUP BY Cuisines
ORDER BY Total_Restaurants DESC;






