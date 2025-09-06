-- ORDERS / CUSTOMERS / SALESPEOPLE case study
CREATE DATABASE sales_db;
USE sales_db;

-- 1.	Create the Salespeople as below screenshot.
CREATE TABLE salespeople (
		snum INT PRIMARY KEY,
        sname VARCHAR(20) NOT NULL,
        city VARCHAR(20),
        comm DECIMAL(4,2)
);

INSERT INTO salespeople(snum, sname, city, comm) VALUES
(1001, "Peel", "London", 0.12),
(1002, "Serres", "San jose", 0.13),
(1003, "Axelrod", "New York", 0.10),
(1004, "Motika", "London", 0.11),
(1005, "Rafkin", "Barcelona", 0.15);

SELECT * FROM salespeople;




-- 2. Create the Cust Table as below Screenshot     
CREATE TABLE customer (
	cnum INT PRIMARY KEY,
    cname VARCHAR(20) NOT NULL,
    city VARCHAR(20),
    rating INT,
    snum INT,
    CONSTRAINT fk_cust_sales FOREIGN KEY (snum) REFERENCES salespeople(snum)
);

INSERT INTO customer (cnum, cname, city, rating, snum) VALUES
(2001, 'Hoffman',  'London',   100, 1001),
(2002, 'Giovanni', 'Rome',     200, 1003),
(2003, 'Liu',      'San Jose', 200, 1002),
(2004, 'Grass',    'Berlin',   300, 1002),
(2006, 'Clemens',  'London',   100, 1001),
(2007, 'Pereira',  'Rome',     100, 1004),
(2008, 'Cisneros', 'San Jose', 300, 1007),
(2009, 'Storn',    'New York', 200, 1003);

SELECT * FROM customer;




-- 3.	Create orders table as below screenshot.
CREATE TABLE orders (
    onum INT PRIMARY KEY,
    amt DECIMAL(10,2) NOT NULL CHECK (amt > 0),
    odate DATE NOT NULL,
    cnum INT NOT NULL,
    snum INT NOT NULL,
    CONSTRAINT fk_order_cust FOREIGN KEY (cnum) REFERENCES customers(cnum),
    CONSTRAINT fk_order_sales FOREIGN KEY (snum) REFERENCES salespeople(snum)
);

INSERT INTO orders (onum, amt, odate, cnum, snum) VALUES
(3001,   18.69, '1990-10-03', 2008, 1007),
(3002, 1900.10, '1990-10-03', 2007, 1004),
(3003,  767.19, '1990-10-03', 2001, 1001),
(3005, 5160.45, '1990-10-03', 2003, 1002),
(3006, 1098.16, '1990-10-03', 2008, 1007),
(3007,   75.75, '1990-10-04', 2004, 1002),
(3008, 4723.00, '1990-10-05', 2006, 1001),
(3009, 1713.23, '1990-10-04', 2002, 1003),
(3010, 1309.95, '1990-10-06', 2004, 1002),
(3011, 9891.88, '1990-10-06', 2006, 1001);

select * from orders;





-- 4.	Write a query to match the salespeople to the customers according to the city they are living.
SELECT s.sname AS SELESPERSON, c.cname AS CUSTOMER, s.city AS CITY
FROM salespeople s 
JOIN customers c ON s.city = c.city
ORDER BY s.city, s.sname, c.cname;




-- 5.	Write a query to select the names of customers and the salespersons who are providing service to them.
SELECT c.cname AS CUSTOMER, s.sname AS SALESPERSON
FROM customers c 
JOIN salespeople s ON c.snum  = s.snum
ORDER BY c.cname;





-- 6.	Write a query to find out all orders by customers not located in the same cities as that of their salespeople
SELECT o.onum, o.amt, o.odate, c.cname AS customer, c.city AS cust_city,
    s.sname AS salesperson, s.city AS sp_city
FROM orders o
JOIN customers c ON o.cnum = c.cnum
JOIN salespeople s ON o.snum = s.snum
WHERE c.city <> s.city
ORDER BY o.onum;





-- 7.	Write a query that lists each order number followed by name of customer who made that order
SELECT o.onum AS ORDER_NO, c.cname AS Customer_Name
FROM orders o
JOIN customers c ON o.cnum = c.cnum
ORDER BY o.onum;




-- 8.	Write a query that finds all pairs of customers having the same rating.
SELECT c1.cnum AS cust1_id, c1.cname AS cust1_name, 
		c2.cnum AS cust2_id, c2.cname AS cust2_name, c1.rating
FROM customers c1
JOIN customers c2  ON c1.rating = c2.rating AND c1.cnum < c2.cnum
ORDER BY c1.rating, c1.cnum, c2.cnum;





-- 9.	Write a query to find out all pairs of customers served by a single salesperson.
SELECT c1.cnum AS cust1_id, c1.cname AS cust1_name,
    c2.cnum AS cust2_id, c2.cname AS cust2_name,
    c1.snum AS salesperson_id
FROM customers c1
JOIN customers c2 ON c1.snum = c2.snum AND c1.cnum < c2.cnum
ORDER BY c1.snum, c1.cnum, c2.cnum;




-- 10.	Write a query that produces all pairs of salespeople who are living in same city.
SELECT s1.snum AS sp1_id, s1.sname AS sp1_name,
    s2.snum AS sp2_id, s2.sname AS sp2_name, s1.city
FROM salespeople s1 
JOIN salespeople s2 ON s1.city = s2.city AND s1.snum < s2.snum
ORDER BY s1.city, s1.snum, s2.snum;





-- 11.	Write a Query to find all orders credited to the same salesperson who services Customer 2008
SELECT *
FROM orders
WHERE snum = (
    SELECT snum 
    FROM customers 
    WHERE cnum = 2008
);





-- 12.	Write a Query to find out all orders that are greater than the average for Oct 4th
SELECT *
FROM orders
WHERE amt > (
    SELECT AVG(amt)
    FROM orders
    WHERE odate = '1990-10-04'
)
ORDER BY onum;





-- 13.	Write a Query to find all orders attributed to salespeople in London.
SELECT o.*, s.city
FROM orders o
JOIN salespeople s ON o.snum = s.snum
WHERE s.city = 'London'
ORDER BY o.onum;




-- 14.	Write a query to find all the customers whose cnum is 1000 above the snum of Serres. 
SELECT *
FROM customers
WHERE cnum = (
    SELECT snum + 1000
    FROM salespeople
    WHERE sname = 'Serres'
);





-- 15.	Write a query to count customers with ratings above San Jose’s average rating.
SELECT COUNT(*) AS cust_count
FROM customers
WHERE rating > (
    SELECT AVG(rating)
    FROM customers
    WHERE city = 'San Jose'
);






-- 16.	Write a query to show each salesperson with multiple customers.
SELECT s.snum, s.sname, COUNT(c.cnum) AS customer_count
FROM salespeople s
JOIN customers c ON s.snum = c.snum
GROUP BY s.snum, s.sname
HAVING COUNT(c.cnum) > 1
ORDER BY customer_count DESC, s.sname;












