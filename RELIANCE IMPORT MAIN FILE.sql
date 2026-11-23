CREATE DATABASE Reliance;
USE reliance;
CREATE TABLE MAIN (
    SRC_id int,
    TransactionID VARCHAR(255),
    OrderID VARCHAR(255),
    OrderDate VARCHAR(255),
    OrderTime VARCHAR(255),
    FinancialYear VARCHAR(255),
    Quarter VARCHAR(255),
    CustomerID VARCHAR(255),
    CustomerName VARCHAR(255),
    Gender VARCHAR(255),
    Age VARCHAR(255),
    CustomerPhone VARCHAR(255),
    CustomerEmail VARCHAR(255),
    CustomerAddress VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    PinCode VARCHAR(255),
    CustomerSegment VARCHAR(255),
    ProductID VARCHAR(255),
    Brand VARCHAR(255),
    Series VARCHAR(255),
    ModelName VARCHAR(255),
    ModelCode VARCHAR(255),
    ProcessorBrand VARCHAR(255),
    ProcessorModel VARCHAR(255),
    RAM_GB VARCHAR(255),
    StorageType VARCHAR(255),
    StorageCapacity_GB VARCHAR(255),
    GraphicsCard VARCHAR(255),
    ScreenSize_inch VARCHAR(255),
    OperatingSystem VARCHAR(255),
    Color VARCHAR(255),
    LaunchYear VARCHAR(255),
    ProductCategory VARCHAR(255),
    MRP VARCHAR(255),
    Quantity VARCHAR(255),
    UnitPrice VARCHAR(255),
    DiscountPercent VARCHAR(255),
    DiscountAmount VARCHAR(255),
    TaxableAmount VARCHAR(255),
    GSTPercent VARCHAR(255),
    GSTAmount VARCHAR(255),
    InvoiceAmount VARCHAR(255),
    PaymentMethod VARCHAR(255),
    EMITenureMonths VARCHAR(255),
    EMIAmountPerMonth VARCHAR(255),
    OrderStatus VARCHAR(255),
    DeliveryDate VARCHAR(255),
    DeliveryDays VARCHAR(255),
    ChannelType VARCHAR(255),
    StoreID VARCHAR(255),
    StoreName VARCHAR(255),
    StoreCity VARCHAR(255),
    StoreState VARCHAR(255),
    Region VARCHAR(255),
    DealerName VARCHAR(255),
    SalesRepID VARCHAR(255),
    SalesRepName VARCHAR(255)
);
SELECT * FROM MAIN;
-- ---------------------------------------------------------------------------------------------------------;
-- IMPORT DATA INTO THE TABLE --
SET GLOBAL LOCAL_INFILE=1;
SHOW GLOBAL VARIABLES LIKE 'LOCAL_INFILE';

LOAD DATA LOCAL INFILE "E:/Freelancing project (reliance digital)/reliance/Reliance_Digital_Laptop_Sales_DIRTY_FULL.csv"
INTO TABLE MAIN
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;