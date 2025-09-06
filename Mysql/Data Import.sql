CREATE DATABASE zomato;
USE zomato;

CREATE TABLE main (
    RestaurantID BIGINT PRIMARY KEY,
    RestaurantName VARCHAR(255),
    CountryCode INT,
    City VARCHAR(100),
    Address TEXT,
    Locality VARCHAR(100),
    LocalityVerbose VARCHAR(255),
    Longitude DECIMAL(10,6),
    Latitude DECIMAL(10,6),
    Cuisines VARCHAR(255),
    Currency VARCHAR(50),
    Has_Table_booking VARCHAR(10),
    Has_Online_delivery VARCHAR(10),
    Is_delivering_now VARCHAR(10),
    Switch_to_order_menu VARCHAR(10),
    Price_range INT,
    Votes INT,
    Average_Cost_for_two DECIMAL(10,2),
    Rating DECIMAL(3,1),
    `Year Opening` INT,
    `Month Opening` INT,
    `Day Opening` INT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/main.csv'
IGNORE
INTO TABLE main
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(RestaurantID, RestaurantName, CountryCode, City, Address, Locality, LocalityVerbose, Longitude, Latitude, Cuisines, Currency, Has_Table_booking, Has_Online_delivery, Is_delivering_now, Switch_to_order_menu, Price_range, Votes, Average_Cost_for_two, Rating, `Year Opening`, `Month Opening`, `Day Opening`);

SELECT COUNT(*) FROM main;

CREATE TABLE country (
	CountryID INT,
    Countryname VARCHAR(100)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/country.csv'
IGNORE
INTO TABLE main
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(CountryID, Countryname);

CREATE TABLE currency (
  Currency VARCHAR(100),
  `USD Rate` DECIMAL(12,6)
) CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/currency.csv'
IGNORE
INTO TABLE main
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Currency, `USD Rate`);

