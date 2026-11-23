-- ORDERS TABLE --
DROP TABLE ORDERS;

USE `reliance`;

-- =========================================================================== 
-- CREATE ORDER TABLE -
-- ===========================================================================
CREATE TABLE ORD AS
SELECT 
    O.SRC_ID,
    -- CUSTOMER INFO
    O.CUSTOMERID,
    C.CUSTOMERNAME,
    -- PRODUCT INFO
    O.PRODUCTID,
    P.BRAND,
    P.SERIES,
    -- STORE INFO
    O.STOREID,
    S.STORESTATE,
    S.STORECITY,
    O.REGION,
    -- ORDERS INFO
    O.ORDERID,
    O.ORDERDATE,
    O.ORDERTIME,
    O.FINANCIALYEAR,
    O.QUARTER,
    O.QUANTITY,
    -- AMOUNT INFO: DIRECTLY FROM ORIGINAL DATA
    O.MRP,
    O.UNITPRICE,
    O.DISCOUNTPERCENT,
    O.DISCOUNTAMOUNT,
    O.TAXABLEAMOUNT,
    O.GSTPERCENT,
    O.GSTAMOUNT,
    O.INVOICEAMOUNT,
    O.PAYMENTMETHOD,
    O.ORDERSTATUS,
    O.DELIVERYDAYS,
    O.CHANNELTYPE

FROM main O
LEFT JOIN CUSTOMERs C ON O.CUSTOMERID = C.CUSTOMERID
LEFT JOIN PRODUCT P ON O.PRODUCTID = P.PRODUCTID
LEFT JOIN STORE S ON O.STOREID = S.STOREID;

-- =========================================================================== 
-- NULL BLANK SPACES AND TRIM -
-- ===========================================================================
UPDATE ORD
SET 
CUSTOMERID = NULLIF(REGEXP_REPLACE(TRIM(CUSTOMERID), ' +', ' '), ''),
PRODUCTID = NULLIF(REGEXP_REPLACE(TRIM(PRODUCTID), ' +', ' '), ''),
STOREID = NULLIF(REGEXP_REPLACE(TRIM(STOREID), ' +', ' '), ''),
ORDERID = NULLIF(REGEXP_REPLACE(TRIM(ORDERID), ' +', ' '), ''),
OrderTime = NULLIF(REGEXP_REPLACE(TRIM(OrderTime), ' +', ' '), ''),
OrderDate = NULLIF(REGEXP_REPLACE(TRIM(OrderDate), ' +', ' '), ''),
FinancialYear = NULLIF(REGEXP_REPLACE(TRIM(FinancialYear), ' +', ' '), ''),
Quarter = NULLIF(REGEXP_REPLACE(TRIM(Quarter), ' +', ' '), ''),
REGION = NULLIF(REGEXP_REPLACE(TRIM(REGION), ' +', ' '), ''),
MRP = NULLIF(REGEXP_REPLACE(TRIM(MRP), ' +', ' '), ''),
Quantity = NULLIF(REGEXP_REPLACE(TRIM(Quantity), ' +', ' '), ''),
UNITPRICE = NULLIF(REGEXP_REPLACE(TRIM(UNITPRICE), ' +', ' '), ''),
DISCOUNTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTPERCENT), ' +', ' '), ''),
DISCOUNTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTAMOUNT), ' +', ' '), ''),
TAXABLEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(TAXABLEAMOUNT), ' +', ' '), ''),
GSTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(GSTPERCENT), ' +', ' '), ''),
GSTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(GSTAMOUNT), ' +', ' '), ''),
INVOICEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(INVOICEAMOUNT), ' +', ' '), ''),
PAYMENTMETHOD = NULLIF(REGEXP_REPLACE(TRIM(PAYMENTMETHOD), ' +', ' '), ''),
ORDERSTATUS = NULLIF(REGEXP_REPLACE(TRIM(ORDERSTATUS), ' +', ' '), ''),
DELIVERYDAYS = NULLIF(REGEXP_REPLACE(TRIM(DELIVERYDAYS), ' +', ' '), ''),
CHANNELTYPE = NULLIF(REGEXP_REPLACE(TRIM(CHANNELTYPE), ' +', ' '), '');

-- =========================================================================== 
-- REMOVE SPECIAL CHARACTER  -
-- ===========================================================================

UPDATE ORD
SET
MRP = NULLIF(REGEXP_REPLACE(TRIM(MRP), '[^0-9.]', ''), ''),
quantity = NULLIF(REGEXP_REPLACE(TRIM(quantity), '[^0-9.]', ''), ''),
UNITPRICE = NULLIF(REGEXP_REPLACE(TRIM(UNITPRICE), '[^0-9.]', ''), ''),
DISCOUNTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTPERCENT), '[^0-9.]', ''), ''),
DISCOUNTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTAMOUNT), '[^0-9.]', ''), ''),
TAXABLEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(TAXABLEAMOUNT), '[^0-9.]', ''), ''),
GSTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(GSTPERCENT), '[^0-9.]', ''), ''),
GSTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(GSTAMOUNT), '[^0-9.]', ''), ''),
INVOICEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(INVOICEAMOUNT), '[^0-9.]', ''), '');

SELECT * FROM ORD;

-- =========================================================================== 
-- REMOVE POINT FROM MRP AND UNITPRICE-
-- ===========================================================================
UPDATE ORD
SET MRP= REPLACE(MRP,'.',''),
UNITPRICE= REPLACE(UNITPRICE,'.','');


-- =========================================================================== 
-- DELETE QUERY -
-- ===========================================================================
DELETE FROM ORD WHERE SRC_ID NOT IN (SELECT MIN(SRC_ID)FROM (SELECT SRC_ID,CUSTOMERID,PRODUCTID,SERIES,ORDERID FROM ORD) AS x
GROUP BY CUSTOMERID,PRODUCTID,SERIES,ORDERID);

-- =========================================================================== 
-- REMOVE ONLINE AND OFFLINE REMAIN-> STORE, WEBSITE, APP -
-- ===========================================================================

UPDATE ord
SET CHANNELTYPE = REPLACE(REPLACE(CHANNELTYPE, 'Online - ', ''),
    'Offline - ', '');

SELECT * FROM ORDERS;
-- =========================================================================== 
-- DATE QUERY -
-- ===========================================================================
-- STEP 1: Remove Time (M/D/YYYY 0:00)
UPDATE ord
SET OrderDate = TRIM(SUBSTRING_INDEX(OrderDate, ' ', 1))
WHERE OrderDate LIKE '% %:%';

-- QUERY 2: DD/MM/YYYY FORMAT
UPDATE ord SET ORDERDATE = DATE_FORMAT(STR_TO_DATE(TRIM(ORDERDATE),'%e/%c/%Y'),'%Y-%m-%d')
WHERE TRIM(ORDERDATE) REGEXP '^(1[3-9]|2[0-9]|3[01])/[0-9]{1,2}/[0-9]{4}$';

-- QUERY 3: DD-MMM-YY FORMAT
UPDATE ord
SET ORDERDATE = DATE_FORMAT(STR_TO_DATE(TRIM(ORDERDATE), '%d %b %Y'),'%Y-%m-%d')
WHERE TRIM(ORDERDATE) REGEXP '^[0-9]{1,2} [A-Za-z]{3} [0-9]{4}$';

-- QUERY 4: MM/DD/YYYY FORMAT KO YYYY-MM-DD FORMAT MAI CONVERT KARNA
UPDATE ord
SET ORDERDATE = DATE_FORMAT(STR_TO_DATE(ORDERDATE,'%c/%e/%Y'),'%Y-%m-%d')
WHERE ORDERDATE LIKE '%/%/%';

-- QUERY 5: DD-MM-YYYY FORMAT
UPDATE ord
SET ORDERDATE = DATE_FORMAT(STR_TO_DATE(TRIM(ORDERDATE), '%e-%c-%Y'),'%Y-%m-%d')
WHERE TRIM(ORDERDATE) REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$';

-- QUERY 6: CHANGE DATATYPE TO DATE
ALTER TABLE ord
MODIFY COLUMN OrderDate date;

SELECT*FROM ORD;
-- =========================================================================== 
-- PAYMENT METHOD -- 
-- ===========================================================================
-- PAYMENT METHOD -- 
UPDATE ORD
SET PaymentMethod = CASE 
WHEN PaymentMethod = 'EMI - Credit Card' THEN 'EMI'
WHEN PaymentMethod = 'EMI-NoCost' THEN 'EMI'
WHEN PaymentMethod = 'EMI - No Cost' THEN 'EMI'
WHEN PaymentMethod = 'EMI-CreditCard' THEN 'EMI'
WHEN PaymentMethod = 'CreditCard' THEN 'Credit Card'
WHEN PaymentMethod = 'NetBanking' THEN 'Net Banking'
WHEN PaymentMethod = 'DebitCard' THEN 'Debit Card'
WHEN PaymentMethod = 'RelianceDigitalGiftCard' THEN 'Gift Card'
WHEN PaymentMethod = 'Reliance Digital Gift Card' THEN 'Gift Card'
ELSE PaymentMethod END;

-- =========================================================================== 
-- DAY PERIOD COLUMN ADD --
-- ===========================================================================
ALTER TABLE ORD ADD COLUMN DAYPERIOD VARCHAR(20);

ALTER TABLE ORD modify column DAYPERIOD VARCHAR(20) AFTER ORDERTIME;

UPDATE ORD
SET DAYPERIOD = CASE
    WHEN ORDERTIME < '12:00:00' THEN 'Morning'
    WHEN ORDERTIME < '17:00:00' THEN 'Afternoon'
    WHEN ORDERTIME < '21:00:00' THEN 'Evening'
    ELSE 'Night'
END;


ALTER TABLE ORD
MODIFY MRP DECIMAL(15,2),
MODIFY UNITPRICE DECIMAL(15,2),
MODIFY QUANTITY DECIMAL(10,2),
MODIFY DISCOUNTPERCENT DECIMAL(10,2),
MODIFY DISCOUNTAMOUNT DECIMAL(15,2),
MODIFY TAXABLEAMOUNT DECIMAL(15,2),
MODIFY GSTPERCENT DECIMAL(10,2),
MODIFY GSTAMOUNT DECIMAL(15,2),
MODIFY INVOICEAMOUNT DECIMAL(15,2);

-- =========================================================================== 
-- QUANTITY 0 WHEN 0 AND 500 --
-- ===========================================================================
UPDATE ORD
SET QUANTITY=0 WHERE QUANTITY=500.00;

SELECT * FROM ORDers;
-- =========================================================================== 
-- outliers in deliverydays --
-- ===========================================================================
update ord
set deliverydays=0 where deliverydays=450;

-- =========================================================================== 
-- standerdize the  orderstuats --
-- ===========================================================================
UPDATE ord SET orderstatus= LOWER(TRIM(orderstatus)) WHERE orderstatus IS NOT NULL;

UPDATE ord SET orderstatus= CONCAT(UPPER(LEFT(orderstatus, 1)), MID(orderstatus, 2)) WHERE orderstatus IS NOT NULL;
-- =========================================================================== 
-- GST PERCENT 18 WHERE IS NOT--
-- ===========================================================================
UPDATE ORD
SET GSTPERCENT=18 WHERE GSTPERCENT != 18;

-- =========================================================================== 
-- SROTRE ORDERSTATUS SHOULD BE DELIVERED --
-- ===========================================================================
UPDATE ORD
SET ORDERSTATUS='DELIVERED' WHERE CHANNELTYPE ='STORE' AND ORDERSTATUS NOT IN ('DELIVERED');


-- =========================================================================== 
-- DELETE 0 QUANTITY --
-- ===========================================================================
DELETE FROM ORD
WHERE QUANTITY = 0;

SELECT * FROM ORDERS;
-- =========================================================================== 
-- DISCOUNTAMOUNT SHOULDE BE 0 WHERE DISOCUNT % IS NULL  --
-- ===========================================================================
UPDATE ORD
SET DISCOUNTPERCENT=0 WHERE DISCOUNTPERCENT IS NULL;

-- =========================================================================== 
-- DISCOUNTAMOUNT SHOULD BE 0 WHERE GREATER THN 25--
-- ===========================================================================
UPDATE ORD
SET DiscountPercent = 0
WHERE TRIM(DiscountPercent) = 150.00;


SELECT * FROM ORD;
-- =========================================================================== 
-- 1. Unit Price ko MRP se zyada hone par MRP ke equal karo
-- ===========================================================================

UPDATE ORD
SET UnitPrice = MRP
WHERE UnitPrice > MRP; -- 9999999

-- =========================================================================== 
-- 1.1 where the unitprice is 999 replace with mrp
-- ===========================================================================
UPDATE ORD
SET UnitPrice = MRP
where unitprice=999.00;

select * from ord;
-- =========================================================================== 
-- 2. Discount Amount recalculate karo
-- ===========================================================================
UPDATE ORD
SET DiscountAmount = ROUND( Quantity * UnitPrice * DiscountPercent / 100,2); -- 3462

-- =========================================================================== 
-- 3. Taxable Amount recalculate karo
-- ===========================================================================
UPDATE ORD SET TaxableAmount = ROUND((Quantity * UnitPrice) - DiscountAmount,2); -- 169638

-- =========================================================================== 
-- 4. GST Amount recalculate karo
-- ===========================================================================
UPDATE ORD
SET GSTAmount =ROUND(TaxableAmount * GSTPercent / 100,2);

-- =========================================================================== 
-- 5. Final Invoice Amount recalculate karo
-- ===========================================================================
UPDATE ORD
SET InvoiceAmount =ROUND(TaxableAmount + GSTAmount,2);

SELECT * FROM ORD;

-- =========================================================================== 
-- ADD A NEW REFUNDAMOUNT COLUMN --
-- ===========================================================================
ALTER TABLE ORD
ADD COLUMN REFUNDAMOUNT DECIMAL(12,2) DEFAULT 0.00 AFTER ORDERSTATUS;


UPDATE ORD
SET REFUNDAMOUNT = INVOICEAMOUNT
WHERE ORDERSTATUS IN ('Cancelled', 'Returned');

-- =========================================================================== 
-- 0 where refund amount is available --
-- ===========================================================================
update ord
set invoiceamount=0 where refundamount >0;
-- =========================================================================== 
-- correct quater  --
-- ===========================================================================
SELECT
    ORDERDATE,
    FINANCIALYEAR,
    QUARTER,
    CASE
        WHEN MONTH(ORDERDATE) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(ORDERDATE) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(ORDERDATE) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS CORRECT_QUARTER
FROM ORDERS
WHERE QUARTER <>
    CASE
        WHEN MONTH(ORDERDATE) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(ORDERDATE) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(ORDERDATE) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END;

-- =========================================================================== 
-- update quater--
-- ===========================================================================
UPDATE ORDERS
SET QUARTER =
    CASE
        WHEN MONTH(ORDERDATE) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(ORDERDATE) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(ORDERDATE) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END
WHERE QUARTER <>
    CASE
        WHEN MONTH(ORDERDATE) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(ORDERDATE) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(ORDERDATE) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END;
-- =========================================================================== 
-- correct financial year --
-- ===========================================================================
      SELECT
    ORDERDATE,
    FINANCIALYEAR,
    CASE
        WHEN MONTH(ORDERDATE) >= 4
            THEN CONCAT('FY', YEAR(ORDERDATE), '-', RIGHT(YEAR(ORDERDATE) + 1, 2))
        ELSE CONCAT('FY', YEAR(ORDERDATE) - 1, '-', RIGHT(YEAR(ORDERDATE), 2))
    END AS CORRECT_FINANCIALYEAR
FROM ORDERS
WHERE FINANCIALYEAR <>
    CASE
        WHEN MONTH(ORDERDATE) >= 4
            THEN CONCAT('FY', YEAR(ORDERDATE), '-', RIGHT(YEAR(ORDERDATE) + 1, 2))
        ELSE CONCAT('FY', YEAR(ORDERDATE) - 1, '-', RIGHT(YEAR(ORDERDATE), 2))
    END;
-- =========================================================================== 
-- update financial year--
-- ===========================================================================
UPDATE ORDERS
SET FINANCIALYEAR =
    CASE
        WHEN MONTH(ORDERDATE) >= 4
            THEN CONCAT('FY', YEAR(ORDERDATE), '-', RIGHT(YEAR(ORDERDATE) + 1, 2))
        ELSE CONCAT('FY', YEAR(ORDERDATE) - 1, '-', RIGHT(YEAR(ORDERDATE), 2))
    END
WHERE FINANCIALYEAR <>
    CASE
        WHEN MONTH(ORDERDATE) >= 4
            THEN CONCAT('FY', YEAR(ORDERDATE), '-', RIGHT(YEAR(ORDERDATE) + 1, 2))
        ELSE CONCAT('FY', YEAR(ORDERDATE) - 1, '-', RIGHT(YEAR(ORDERDATE), 2))
    END;
    
