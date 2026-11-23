use reliance;
select * from ord;
-- =========================================================================== 
-- CREATE AMOUNT TABLE -
-- ===========================================================================
create table AMOUNT select src_id,
ProductID,
Series,
Mrp,
UnitPrice,
DiscountPercent,
DiscountAmount,
TaxableAmount,
GSTPercent,
GSTAmount,
InvoiceAmount from MAIN_COPY;

select * from COPYDATA;

-- =========================================================================== 
-- FILL NULL AND REMOVE SPACES -
-- ===========================================================================
UPDATE AMOUNT
SET PRODUCTID = NULLIF(REGEXP_REPLACE(TRIM(PRODUCTID), ' +', ' '), ''),
Series = NULLIF(REGEXP_REPLACE(TRIM(Series), ' +', ' '), ''),
MRP = NULLIF(REGEXP_REPLACE(TRIM(MRP), ' +', ' '), ''),
UNITPRICE = NULLIF(REGEXP_REPLACE(TRIM(UNITPRICE), ' +', ' '), ''),
DISCOUNTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTPERCENT), ' +', ' '), ''),
DISCOUNTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTAMOUNT), ' +', ' '), ''),
TAXABLEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(TAXABLEAMOUNT), ' +', ' '), ''),
GSTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(GSTPERCENT), ' +', ' '), ''),
GSTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(GSTAMOUNT), ' +', ' '), ''),
INVOICEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(INVOICEAMOUNT), ' +', ' '), '');

-- =========================================================================== 
-- -- quick alternative for triming -- 
-- ===========================================================================
call trim_value('amount');

-- =========================================================================== 
-- REMOVE SPECIAL CHARACTER FILL NULL AND REMOVE SPACES FROM NUMEICAL COLUMNS-- 
-- ===========================================================================
UPDATE AMOUNT
SET
MRP = NULLIF(REGEXP_REPLACE(TRIM(MRP), '[^0-9.]', ''), ''),
UNITPRICE = NULLIF(REGEXP_REPLACE(TRIM(UNITPRICE), '[^0-9.]', ''), ''),
DISCOUNTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTPERCENT), '[^0-9.]', ''), ''),
DISCOUNTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(DISCOUNTAMOUNT), '[^0-9.]', ''), ''),
TAXABLEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(TAXABLEAMOUNT), '[^0-9.]', ''), ''),
GSTPERCENT = NULLIF(REGEXP_REPLACE(TRIM(GSTPERCENT), '[^0-9.]', ''), ''),
GSTAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(GSTAMOUNT), '[^0-9.]', ''), ''),
INVOICEAMOUNT = NULLIF(REGEXP_REPLACE(TRIM(INVOICEAMOUNT), '[^0-9.]', ''), '');


-- =========================================================================== 
-- CHANGE THE DATATYPE OF NUMEICAL COLUMNS-- 
-- ===========================================================================
ALTER TABLE AMOUNT
MODIFY MRP DECIMAL(15,2),
MODIFY UNITPRICE DECIMAL(15,2),
MODIFY DISCOUNTPERCENT DECIMAL(10,2),
MODIFY DISCOUNTAMOUNT DECIMAL(15,2),
MODIFY TAXABLEAMOUNT DECIMAL(15,2),
MODIFY GSTPERCENT DECIMAL(10,2),
MODIFY GSTAMOUNT DECIMAL(15,2),
MODIFY INVOICEAMOUNT DECIMAL(15,2);


SELECT*FROM AMOUNT;

SELECT Quantity, COUNT(*) AS COUNT FROM AMOUNT GROUP BY Quantity ORDER BY cnt DESC;
-- =========================================================================== 
-- REMOVE OUTLIERS LIKE 150% FROM DISCOUNTPCT-- 
-- ===========================================================================
UPDATE AMOUNT
SET DiscountPercent = NULL
WHERE TRIM(DiscountPercent) = 150.00;

-- =========================================================================== 
-- 1. Unit_Price ko MRP se zyada hone par MRP ke equal karo
-- ===========================================================================

UPDATE AMOUNT SET UnitPrice = MRP
WHERE UnitPrice > MRP; 
-- =========================================================================== 
-- 2. Discount Amount recalculate karo
-- ===========================================================================

UPDATE AMOUNT SET DiscountAmount = ROUND(UnitPrice * DiscountPercent / 100,2); 
-- =========================================================================== 
-- 3. Taxable Amount recalculate karo
-- ===========================================================================

UPDATE AMOUNT SET TaxableAmount = ROUND((UnitPrice) - DiscountAmount,2); 
-- =========================================================================== 
-- 4. GST Amount recalculate karo
-- ===========================================================================

UPDATE AMOUNT SET GSTAmount = ROUND(TaxableAmount * GSTPercent / 100,2);
-- =========================================================================== 
-- 5. Final Invoice Amount recalculate karo
-- ===========================================================================

UPDATE AMOUNT SET InvoiceAmount = ROUND(TaxableAmount + GSTAmount,2);


-- =========================================================================== 
-- DELETE DUPLICATE --
-- ===========================================================================
DELETE FROM AMOUNT WHERE SRC_ID NOT IN (SELECT MIN(SRC_ID)FROM (SELECT SRC_ID,PRODUCTID,SERIES FROM AMOUNT) AS x
GROUP BY PRODUCTID,SERIES);

SELECT COUNT(*) FROM AMOUNT;


UPDATE AMOUNT
SET DISCOUNTPERCENT = 0,
    DISCOUNTAMOUNT = 0,
    TAXABLEAMOUNT = 0,
    GSTAMOUNT = 0,
    INVOICEAMOUNT = 0
WHERE DISCOUNTPERCENT IS NULL
   OR DISCOUNTAMOUNT IS NULL
   OR TAXABLEAMOUNT IS NULL
   OR GSTAMOUNT IS NULL
   OR INVOICEAMOUNT IS NULL;