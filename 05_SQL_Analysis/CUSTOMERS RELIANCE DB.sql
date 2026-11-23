-- USE YOUR DATABASE --
use reliance;

-- DROP TABLE IF EXISTS ON YOUR DATABASE --
DROP TABLE IF EXISTS customer;

CREATE TABLE customer SELECT SRC_ID,
    CustomerID,
    CustomerName,
    Gender,
    AGE,
    CustomerPhone,
    CustomerEmail,
    CustomerAddress,
    City,
    State,
    PinCode,
    customersegment FROM
    main;
    
UPDATE CUSTOMER
SET
    CustomerID = NULLIF(REGEXP_REPLACE(TRIM(CustomerID), ' +', ' '), ''),
    CustomerName = NULLIF(REGEXP_REPLACE(TRIM(CustomerName), ' +', ' '), ''),
    Gender = NULLIF(REGEXP_REPLACE(TRIM(Gender), ' +', ' '), ''),
    AGE = NULLIF(REGEXP_REPLACE(TRIM(AGE), ' +', ' '), ''),
    City = NULLIF(REGEXP_REPLACE(TRIM(City), ' +', ' '), ''),
    State = NULLIF(REGEXP_REPLACE(TRIM(State), ' +', ' '), ''),
    CustomerSegment = NULLIF(REGEXP_REPLACE(TRIM(CustomerSegment), ' +', ' '), '');
-- ==========================================================================================
-- DROP THE COLUMN THT NO LONGER NEEDED --
-- ===========================================================================================
ALTER TABLE customer
    DROP COLUMN CustomerPhone,
    DROP COLUMN CustomerEmail,
    DROP COLUMN CustomerAddress,
    DROP COLUMN PinCode;

    
-- ==========================================================================================
-- REMOVING THE SPECIAL CHARACTERS FROM THE CUSTOMERNAME 
-- ===========================================================================================
UPDATE customer
SET CustomerName = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(CustomerName, '[^a-zA-Z ]', ' '), ' +', ' '))
WHERE CustomerName IS NOT NULL;

-- ==========================================================================================
-- REMOVE OUTLIERS FROM THE AGE COLUMN 
-- ===========================================================================================
UPDATE customer
SET AGE = CASE
    WHEN AGE <= 15 OR AGE > 70 THEN NULL
    ELSE AGE
END;


-- before 3975
-- after 7624

-- ==========================================================================================
-- MAKE A TEMOPORARY COLUMN TO FILL THE AGE --
-- ===========================================================================================

CREATE TEMPORARY TABLE TEMP_CUSTOMER AS
SELECT CustomerID, AGE, COUNT(*) AS CNT
FROM customer WHERE AGE IS NOT NULL GROUP BY CustomerID, AGE;

ALTER TABLE TEMP_CUSTOMER ADD INDEX idx_customer (CustomerID);

UPDATE customer t
JOIN TEMP_CUSTOMER m ON t.CustomerID = m.CustomerID
SET t.AGE = m.AGE
WHERE t.AGE IS NULL;

DROP TABLE TEMP_CUSTOMER;


-- before 7624 null
-- after 1194 null remain

-- ==========================================================================================
-- fill the null age whith average age --
-- ===========================================================================================
UPDATE customer
SET AGE= (SELECT KASHISH FROM (SELECT ROUND(AVG(AGE)) AS KASHISH FROM customer) AS KA)
WHERE AGE IS NULL;

-- ==========================================================================================
-- ADD A ADDITIONAL COLUMN FOR AGE CATEGORY --
-- ===========================================================================================
ALTER TABLE customer ADD COLUMN AgeGroup VARCHAR(50) AFTER AGE;

UPDATE customer
SET AgeGroup = CASE
    WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
    WHEN Age BETWEEN 36 AND 59 THEN 'Adult'
    WHEN Age >= 60 THEN 'Senior'
END;


-- ==========================================================================================
-- STANDARDIZE THE GENDER  --
-- ===========================================================================================
UPDATE customer
SET Gender = CASE
    WHEN Gender IN ('MALE', 'M') THEN 'Men'
    WHEN Gender IN ('FEMALE', 'F') THEN 'Women'
    ELSE Gender
    
END;


-- ==========================================================================================
-- FILL NULL CITY VALUES USING THE EXISTING CITY AVAILABLE IN THE SAME CUSTOMERID --
-- ===========================================================================================


CREATE TEMPORARY TABLE TEMP_CITY AS
SELECT CustomerID, City, COUNT(*) AS CNT
FROM customer WHERE City IS NOT NULL GROUP BY CustomerID, City;

ALTER TABLE TEMP_CITY ADD INDEX idx_customer (CustomerID);

UPDATE customer t
JOIN TEMP_CITY m ON t.CustomerID = m.CustomerID
SET t.City = m.City
WHERE t.City IS NULL;

DROP TABLE TEMP_CITY;


-- before 3043 null
-- after 455 null
create table temp select * from customer;
-- ==========================================================================================
-- STANDARDIZE CITY NAMES TO LOWERCASE AND CAPITALIZE THE FIRST LETTER--
-- ===========================================================================================
UPDATE customer SET City = LOWER(TRIM(City)) WHERE City IS NOT NULL;

UPDATE customer SET City = CONCAT(UPPER(LEFT(City, 1)), MID(City, 2)) WHERE City IS NOT NULL;


-- ==========================================================================================
--  CONVERT STATE ABBREVIATIONS INTO THEIR FULL STATE NAMES --
-- ===========================================================================================
UPDATE customer
SET State = CASE
    WHEN UPPER(TRIM(State)) = 'JH' THEN 'Jharkhand'
    WHEN UPPER(TRIM(State)) = 'OD' THEN 'Odisha'
    WHEN UPPER(TRIM(State)) = 'MP' THEN 'Madhya Pradesh'
    WHEN UPPER(TRIM(State)) = 'AP' THEN 'Andhra Pradesh'
    WHEN UPPER(TRIM(State)) = 'DL' THEN 'Delhi'
    WHEN UPPER(TRIM(State)) = 'KA' THEN 'Karnataka'
    WHEN UPPER(TRIM(State)) = 'UP' THEN 'Uttar Pradesh'
    WHEN UPPER(TRIM(State)) = 'GJ' THEN 'Gujarat'
    WHEN UPPER(TRIM(State)) = 'PB' THEN 'Punjab'
    WHEN UPPER(TRIM(State)) = 'KL' THEN 'Kerala'
    WHEN UPPER(TRIM(State)) = 'RJ' THEN 'Rajasthan'
    WHEN UPPER(TRIM(State)) = 'MH' THEN 'Maharashtra'
    WHEN UPPER(TRIM(State)) = 'UK' THEN 'Uttarakhand'
    WHEN UPPER(TRIM(State)) = 'WB' THEN 'West Bengal'
    WHEN UPPER(TRIM(State)) = 'TN' THEN 'Tamil Nadu'
    WHEN UPPER(TRIM(State)) = 'HR' THEN 'Haryana'
    WHEN UPPER(TRIM(State)) = 'TS' THEN 'Telangana'
    WHEN UPPER(TRIM(State)) = 'AS' THEN 'Assam'
    WHEN UPPER(TRIM(State)) = 'BR' THEN 'Bihar'
    ELSE TRIM(State)
END;
select * from customer;
-- ==========================================================================================
--  STANDARDIZE THE STATE --
-- ===========================================================================================
UPDATE customer SET state = LOWER(TRIM(state)) WHERE state IS NOT NULL;

UPDATE customer SET state = CONCAT(UPPER(LEFT(state, 1)), MID(state, 2)) WHERE state IS NOT NULL;
-- ==========================================================================================
-- UPDATE STATE USING THE STATE VALUES AVAILABLE IN THE DATASET --
-- ===========================================================================================

SELECT C.City, C.State AS Current_State, M.State AS Expected_State
FROM CUSTOMER C
JOIN
(SELECT City, State,
ROW_NUMBER() OVER(PARTITION BY City ORDER BY COUNT(*) DESC) rn
FROM CUSTOMER WHERE City IS NOT NULL AND State IS NOT NULL GROUP BY City, State) M
ON C.City = M.City
WHERE M.rn = 1 AND C.State <> M.State;

UPDATE CUSTOMER C
JOIN 
(SELECT City, State,
ROW_NUMBER() OVER(PARTITION BY City ORDER BY COUNT(*) DESC) AS rn
FROM CUSTOMER WHERE City IS NOT NULL AND State IS NOT NULL GROUP BY City, State) M
ON C.City = M.City
SET C.State = M.State WHERE M.rn = 1;




-- ===========================================================================
-- CUSTOMER SEGMENT LABELS --
-- =========================================================================== 

UPDATE customer
SET customersegment = CASE
    WHEN customersegment = 'Reliance One Member' THEN 'Premium'
    WHEN customersegment = 'Returning' THEN 'Repeat'
    WHEN customersegment = 'New' THEN 'New customer'
    ELSE customersegment
END;

-- ===========================================================================
-- REMOVING THE DUPLICATE VLAUES --
-- =========================================================================== 
DELETE FROM customer
WHERE SRC_ID NOT IN (SELECT MIN(SRC_ID)FROM (
SELECT SRC_ID,CustomerID, CustomerName, Gender, Age, City, state,customersegment FROM customer) AS x
GROUP BY CustomerID, CustomerName, Gender, Age, City, state,customersegment);

select*from customer;


-- ==========================================================================================
-- REPLACE NULL CITY VALUES WITH 'Not Available' --
-- ===========================================================================================
UPDATE customer SET City = 'Not Available' WHERE City IS NULL;

select count(*) from customer where city is null;

-- 0 null
-- ===========================================================================
-- FINAL COUNT FOR UNIQUE CUSTOMERID --
-- =========================================================================== 
SELECT COUNT(*) AS 'FINAL ROW COUNT' FROM customer;


-- 78365 UNIQUE ROWS LEFT--
