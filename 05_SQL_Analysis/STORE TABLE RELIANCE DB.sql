USE RELIANCE;
-- ===========================================================================
-- CREATE STORE TABLE  -
-- =========================================================================== 
CREATE TABLE STORE AS
SELECT SRC_ID,
    StoreID,
    StoreName,
    StoreCity,
    StoreState,
    Region,
    Dealername
FROM COPYDATA;

SELECT * FROM STORE;
-- ===========================================================================
-- FILL NULL AND REMOVE SPACES  -
-- =========================================================================== 
UPDATE STORE
SET 
STOREID=NULLIF(REGEXP_REPLACE(TRIM(STOREID),' +',' '),''),
ID=NULLIF(REGEXP_REPLACE(TRIM(ID),' +',' '),''),
STORENAME=NULLIF(REGEXP_REPLACE(TRIM(STORENAME),' +',' '),''),
STORECITY=NULLIF(REGEXP_REPLACE(TRIM(STORECITY),' +',' '),''),
STORESTATE=NULLIF(REGEXP_REPLACE(TRIM(STORESTATE),' +',' '),''),
REGION=NULLIF(REGEXP_REPLACE(TRIM(REGION),' +',' '),'');

SELECT *FROM STORE;

-- =========================================================================== 
-- QUERY  : FILL WRONG STATE AND CITY 
-- =========================================================================== 
UPDATE STORE s
JOIN (SELECT StoreID, StoreState FROM (SELECT StoreID,StoreState,COUNT(*) AS state_count,
            ROW_NUMBER() OVER (PARTITION BY StoreID ORDER BY COUNT(*) DESC) AS rn 
            FROM store GROUP BY StoreID, StoreState)
            ranked
    WHERE rn = 1) best 
    ON s.StoreID = best.StoreID
SET s.StoreState = best.StoreState;

-- =========================================================================== 
-- QUERY  : DELETE DUPLICATE ROWS (65 rows expected)
-- =========================================================================== 
DELETE FROM STORE
WHERE SRC_ID NOT IN (SELECT MIN(SRC_ID)FROM (
SELECT SRC_ID,StoreID,StoreName,StoreCity,StoreState,Region,DealerName FROM STORE) AS x
WHERE STORENAME IS NOT NULL
GROUP BY StoreID,StoreName,StoreCity,StoreState,Region,DealerName) ;

select * from store;

-- -------------------------------------------------------------------------------------------

select * from store;  
SELECT * FROM STO;

