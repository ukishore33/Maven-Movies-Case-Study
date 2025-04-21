-- Advanced SQL Queries for Maven Movies Database

-- 1️⃣ Finding the Top 5 Most Rented Movies (Using Window Function)
WITH MovieRentals AS (
    SELECT F.TITLE, COUNT(R.RENTAL_ID) AS Rental_Count,
           RANK() OVER (ORDER BY COUNT(R.RENTAL_ID) DESC) AS Rank
    FROM RENTAL R
    JOIN FILM_LIST F ON R.FILM_ID = F.FID
    GROUP BY F.TITLE
)
SELECT * FROM MovieRentals WHERE Rank <= 5;

-- 2️⃣ Running Total of Revenue Per Store (Cumulative Sum)
SELECT S.STORE_ID, P.PAYMENT_DATE, P.AMOUNT,
       SUM(P.AMOUNT) OVER (PARTITION BY S.STORE_ID ORDER BY P.PAYMENT_DATE) AS Running_Total
FROM STORE S
JOIN STAFF ST ON S.STORE_ID = ST.STORE_ID
JOIN PAYMENT P ON ST.STAFF_ID = P.STAFF_ID;

-- 3️⃣ Identifying High-Value Customers (Customers Who Spent More than 500)
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(P.AMOUNT) AS Total_Spent
FROM CUSTOMER C
JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME
HAVING SUM(P.AMOUNT) > 500
ORDER BY Total_Spent DESC;

-- 4️⃣ Monthly Revenue Trends for the Past Year
SELECT DATE_FORMAT(P.PAYMENT_DATE, '%Y-%m') AS Month,
       SUM(P.AMOUNT) AS Total_Revenue
FROM PAYMENT P
WHERE P.PAYMENT_DATE >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY Month
ORDER BY Month;

-- 5️⃣ Find Customers Who Rented More Than Once in the Same Day
SELECT CUSTOMER_ID, RENTAL_DATE, COUNT(RENTAL_ID) AS Rentals_Per_Day
FROM RENTAL
GROUP BY CUSTOMER_ID, RENTAL_DATE
HAVING COUNT(RENTAL_ID) > 1;

-- 6️⃣ Recursive Query: Finding Managers and Their Employees (Assuming a Staff Hierarchy Table)
WITH RECURSIVE StaffHierarchy AS (
    SELECT STAFF_ID, MANAGER_ID, FIRST_NAME, LAST_NAME
    FROM STAFF
    WHERE MANAGER_ID IS NULL -- Start with top-level managers
    
    UNION ALL
    
    SELECT S.STAFF_ID, S.MANAGER_ID, S.FIRST_NAME, S.LAST_NAME
    FROM STAFF S
    INNER JOIN StaffHierarchy SH ON S.MANAGER_ID = SH.STAFF_ID
)
SELECT * FROM StaffHierarchy;

-- 7️⃣ Optimizing Query Performance: Indexing Example
CREATE INDEX idx_customer_rental ON RENTAL(CUSTOMER_ID, RENTAL_DATE);

-- 8️⃣ Dynamic Query: Stored Procedure to Get Rentals for a Given Month
DELIMITER //
CREATE PROCEDURE GetMonthlyRentals(IN RentalMonth VARCHAR(7))
BEGIN
    SELECT * FROM RENTAL
    WHERE DATE_FORMAT(RENTAL_DATE, '%Y-%m') = RentalMonth;
END;
//
DELIMITER;

-- Call Procedure Example:
CALL GetMonthlyRentals('2024-03');

-- 9️⃣ Find Customers Who Have Never Rented a Movie
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME
FROM CUSTOMER C
LEFT JOIN RENTAL R ON C.CUSTOMER_ID = R.CUSTOMER_ID
WHERE R.CUSTOMER_ID IS NULL;

-- 🔟 Most Profitable Movie Categories (Revenue Per Category)
SELECT F.CATEGORY, SUM(P.AMOUNT) AS Total_Revenue
FROM FILM_LIST F
JOIN RENTAL R ON F.FID = R.FILM_ID
JOIN PAYMENT P ON R.RENTAL_ID = P.RENTAL_ID
GROUP BY F.CATEGORY
ORDER BY Total_Revenue DESC;

-- 1️⃣1️⃣ Common Table Expressions (CTEs) for Complex Queries
WITH HighSpendingCustomers AS (
    SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(P.AMOUNT) AS Total_Spent
    FROM CUSTOMER C
    JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
    GROUP BY C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME
    HAVING SUM(P.AMOUNT) > 300
)
SELECT * FROM HighSpendingCustomers;

-- 1️⃣2️⃣ Pivot Tables: Monthly Rental Count Per Store
SELECT * FROM (
    SELECT STORE_ID, DATE_FORMAT(RENTAL_DATE, '%Y-%m') AS Rental_Month, COUNT(RENTAL_ID) AS Total_Rentals
    FROM RENTAL
    GROUP BY STORE_ID, Rental_Month
) src
PIVOT (
    SUM(Total_Rentals) FOR Rental_Month IN ('2024-01', '2024-02', '2024-03')
) AS PivotTable;

-- 1️⃣3️⃣ JSON Handling in SQL (If Supported)
SELECT JSON_EXTRACT(CUSTOMER_DATA, '$.email') AS Email
FROM CUSTOMER;

-- 1️⃣4️⃣ Advanced Window Functions: Using NTILE to Segment Customers by Spending
SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, SUM(AMOUNT) AS Total_Spent,
       NTILE(4) OVER (ORDER BY SUM(AMOUNT) DESC) AS Spending_Quartile
FROM PAYMENT
JOIN CUSTOMER USING (CUSTOMER_ID)
GROUP BY CUSTOMER_ID, FIRST_NAME, LAST_NAME;

-- 1️⃣5️⃣ Query Performance Tuning: Analyzing Execution Plan
EXPLAIN ANALYZE SELECT * FROM RENTAL WHERE CUSTOMER_ID = 10;

-- 1️⃣6️⃣ Time-Series Analysis: Rolling Averages for Revenue
SELECT DATE_FORMAT(PAYMENT_DATE, '%Y-%m') AS Month,
       SUM(AMOUNT) AS Total_Revenue,
       AVG(SUM(AMOUNT)) OVER (ORDER BY DATE_FORMAT(PAYMENT_DATE, '%Y-%m') ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Rolling_Avg
FROM PAYMENT
GROUP BY Month;

-- 1️⃣7️⃣ Error Handling in Stored Procedures
DELIMITER //
CREATE PROCEDURE SafeInsertCustomer(IN CustID INT, IN CustName VARCHAR(50))
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    INSERT INTO CUSTOMER (CUSTOMER_ID, FIRST_NAME) VALUES (CustID, CustName);
    COMMIT;
END;
//
DELIMITER;

-- 1️⃣8️⃣ Top 5 Customers Who Spent the Most
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(P.AMOUNT) AS Total_Spent
FROM CUSTOMER C
JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME
ORDER BY Total_Spent DESC
LIMIT 5;

-- Missing Advanced SQL Queries for Real-World Scenarios

-- 1️⃣ Complex Recursive Query: Finding Customer Referral Chains
-- 📌 Best Use Case: When dealing with hierarchical data such as organizational structures, referral programs, or bill of materials.
WITH RECURSIVE ReferralHierarchy AS (
    SELECT CUSTOMER_ID, REFERRED_BY AS REFERRER_ID, 1 AS LEVEL
    FROM CUSTOMER
    WHERE REFERRED_BY IS NOT NULL
    
    UNION ALL
    
    SELECT C.CUSTOMER_ID, C.REFERRED_BY, RH.LEVEL + 1
    FROM CUSTOMER C
    JOIN ReferralHierarchy RH ON C.REFERRED_BY = RH.CUSTOMER_ID
)
SELECT * FROM ReferralHierarchy;

-- 2️⃣ Advanced Window Function: Dense Rank with Conditional Aggregation
-- 📌 Best Use Case: Ranking customers based on total spending while maintaining ranking gaps in case of ties.
SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, SUM(AMOUNT) AS Total_Spent,
       DENSE_RANK() OVER (PARTITION BY CUSTOMER_TYPE ORDER BY SUM(AMOUNT) DESC) AS Spending_Rank
FROM PAYMENT
JOIN CUSTOMER USING (CUSTOMER_ID)
GROUP BY CUSTOMER_ID, FIRST_NAME, LAST_NAME, CUSTOMER_TYPE;

-- 3️⃣ Dynamic SQL Query: Building Queries on the Fly
-- 📌 Best Use Case: When table names or filters need to be decided at runtime (e.g., handling multi-tenant databases).
DELIMITER //
CREATE PROCEDURE GenerateDynamicQuery(IN TableName VARCHAR(50))
BEGIN
    SET @sql_query = CONCAT('SELECT * FROM ', TableName, ' LIMIT 10');
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//
DELIMITER;

-- Call Procedure Example:
CALL GenerateDynamicQuery('FILM_LIST');

-- 4️⃣ Most Advanced Query Used in Work Experience: Customer Churn Prediction
-- 📌 Best Use Case: Predicting customer churn based on historical activity.
WITH CustomerActivity AS (
    SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME,
           COUNT(R.RENTAL_ID) AS Rental_Count,
           MAX(R.RENTAL_DATE) AS Last_Rental_Date,
           DATEDIFF(CURDATE(), MAX(R.RENTAL_DATE)) AS Days_Since_Last_Rental
    FROM CUSTOMER C
    LEFT JOIN RENTAL R ON C.CUSTOMER_ID = R.CUSTOMER_ID
    GROUP BY C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME
)
SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, Rental_Count, Last_Rental_Date,
       CASE 
           WHEN Rental_Count = 0 THEN 'Inactive'
           WHEN Days_Since_Last_Rental > 90 THEN 'High Churn Risk'
           ELSE 'Active'
       END AS Churn_Status
FROM CustomerActivity
ORDER BY Days_Since_Last_Rental DESC;

-- 5️⃣ Indexing and Performance Optimization
-- 📌 Best Use Case: Speeding up search queries on frequently used columns.
CREATE INDEX idx_customer_email ON CUSTOMER(EMAIL);
EXPLAIN SELECT * FROM CUSTOMER WHERE EMAIL = 'test@example.com';

-- 6️⃣ Pivoting Data Using Conditional Aggregation
-- 📌 Best Use Case: Transforming row-based data into a columnar format (e.g., sales by region).
SELECT CUSTOMER_ID,
       SUM(CASE WHEN MONTH(RENTAL_DATE) = 1 THEN 1 ELSE 0 END) AS January_Rentals,
       SUM(CASE WHEN MONTH(RENTAL_DATE) = 2 THEN 1 ELSE 0 END) AS February_Rentals
FROM RENTAL
GROUP BY CUSTOMER_ID;

-- 7️⃣ JSON Handling in SQL
-- 📌 Best Use Case: Working with semi-structured data stored as JSON in relational databases.
SELECT CUSTOMER_ID, JSON_EXTRACT(DETAILS, '$.preferences') AS Preferences
FROM CUSTOMER_DETAILS;

-- 8️⃣ Advanced Date & Time Functions
-- 📌 Best Use Case: Comparing time intervals and trends over time.
SELECT CUSTOMER_ID, FIRST_NAME, RENTAL_DATE,
       LAG(RENTAL_DATE) OVER (PARTITION BY CUSTOMER_ID ORDER BY RENTAL_DATE) AS Previous_Rental,
       DATEDIFF(RENTAL_DATE, LAG(RENTAL_DATE) OVER (PARTITION BY CUSTOMER_ID ORDER BY RENTAL_DATE)) AS Days_Between_Rentals
FROM RENTAL;

-- This document now covers **ALL** missing advanced SQL concepts! 🚀
