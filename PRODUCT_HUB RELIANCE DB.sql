use reliance;
-- ===========================================================================
-- CREATE PRODUCT_HUB TABLE --
-- =========================================================================== 
DROP TABLE IF EXISTS PRODUCT;

CREATE TABLE PROduct SELECT 
src_id,ProductID , Brand , 
Series , ModelName , ModelCode ,
ProcessorBrand , ProcessorModel , 
RAM_GB , StorageType , 
StorageCapacity_GB , GraphicsCard , 
ScreenSize_inch , OperatingSystem , 
Color , LaunchYear , ProductCategory , MRP
FROM COPYDATA;


SELECT*FROM PRODUCT;


-- PROBLEMS IN THE PRODUCT TABLE
# DUPLICATES PRODUCT ID
# MULTIPLE PROCESSOR MODEL ASSIGN TO ONE PRODUCT ID 
# OULIERS IN LAUNCH YEAR 
# INCONSISTENT RAM_GB AND STORAGECAPACITY_GB
# GRAPHICS CARD NULL

-- ===========================================================================
-- FREQUENCY WISE CORRECTING THE LAUCNHYEAR--
-- =========================================================================== 

CREATE TEMPORARY TABLE TEMP_LAUNCHYEAR AS
SELECT
    PRODUCTID,
    LaunchYear,
    COUNT(*) AS CNT
FROM PRoduct
WHERE LaunchYear IS NOT NULL
GROUP BY PRODUCTID, LaunchYear;

ALTER TABLE TEMP_LAUNCHYEAR ADD INDEX idx_customer (PRODUCTID);

UPDATE PROduct t
JOIN TEMP_Launchyear m
    ON t.PRODUCTID = m.PRODUCTID
SET
    t.LaunchYear = m.LaunchYear
WHERE t.LaunchYear IS not NULL;

DROP TABLE TEMP_LAUNCHYEAR;


-- ===========================================================================
-- DELETE DUPLICATES WITH PRODUCTID BRAND AND MODELNAME --
-- =========================================================================== 

DELETE FROM PROduct
WHERE SRC_ID NOT IN (SELECT MIN(SRC_ID)FROM (
SELECT SRC_ID,PRODUCTID,BRAND,MODELNAME FROM PROduct) AS x
GROUP BY PRODUCTID,BRAND,MODELNAME);
-- ===========================================================================
-- REPLACE SPEACIAL CHARACTER WITH NOTHING --
-- =========================================================================== 
UPDATE PRODUCT
SET RAM_GB = REGEXP_REPLACE(RAM_GB,'[^0-9]','');

update product
set ram_gb=concat(ram_gb,' GB');

SELECT*FROM PRODUCT;
-- ===========================================================================
-- STANDARDIZE STORAGECAPACITY_GB --
-- =========================================================================== 
UPDATE product
SET StorageCapacity_GB = CASE
WHEN CAST(StorageCapacity_GB AS DECIMAL(10,2)) > 1000 
THEN CONCAT(CAST(CAST(StorageCapacity_GB AS DECIMAL(10,2)) / 1024 AS DECIMAL(10,2)),' TB')
ELSE CONCAT(StorageCapacity_GB, ' GB')END;

SELECT * FROM RELIANCE.PRODUCT;

-- ===========================================================================
-- UPDATING SCREENSIZE_INCH 55 TO 16  --
-- =========================================================================== 
SELECT 
    p.ProductID,
    p.ScreenSize_inch AS CurrentValue,
    c.ScreenSize_inch AS CorrectValue
FROM PRODUCT p
JOIN Copydata c
    ON p.ProductID = c.ProductID
WHERE p.ScreenSize_inch = 55
  AND c.ScreenSize_inch <> 55;

-- UPDATE --
UPDATE PRODUCT p
JOIN Copydata c
    ON p.ProductID = c.ProductID
SET p.ScreenSize_inch = c.ScreenSize_inch
WHERE p.ScreenSize_inch = 55
  AND c.ScreenSize_inch <> 55;
  
-- ===========================================================================
-- updating graphicscard with existing  --
-- =========================================================================== 
UPDATE PRODUCT p
JOIN Copydata c ON p.ProductID = c.ProductID
SET p.GraphicsCard = c.GraphicsCard
WHERE p.GraphicsCard IS NULL
AND c.GraphicsCard IS NOT NULL;

-- ===========================================================================
-- chnge the brand name -
-- ===========================================================================
 
update product
set brand= case when brand='ASUS ROG' then 'ASUS'else brand end;

-- ===========================================================================
-- data type chnge of numerical columns-
-- =========================================================================== 
ALTER TABLE PRODUCT
MODIFY ScreenSize_inch DECIMAL(4,1),
MODIFY RAM_GB INT,
MODIFY LaunchYear INT;
-- ----------------------------------------------------------------------------------------------------------
select * from product;
desc product;

