use reliance;
-- Question1: What is the total revenue generated per financial year?
-- Objective: To analyze business growth over time.
-- Approach: Group the data by financial year and calculate the sum of revenue for orders where the status is "Delivered."

SELECT FinancialYear, 
ROUND(SUM(InvoiceAmount) / 10000000, 2) AS 'Total Amount (in Million)'
FROM orders
WHERE OrderStatus = 'Delivered'
GROUP BY FinancialYear
ORDER BY FinancialYear;


-- Question2: Which brand and series combinations have a return rate or refund rate exceeding the 5% target?
-- Objective: Track brand-series return/refund percentages and flag underperforming products above the 5% limit.
-- Approach: Group by Brand and Series. Calculate distinct returned orders vs. distinct total orders, alongside 
-- the refunded share of the invoice amount. Filter the final output using HAVING where Return Rate > 5% or Refund Rate > 5%

SELECT Brand, Series, 
COUNT(DISTINCT OrderID) AS Total_Order,
COUNT(DISTINCT CASE WHEN OrderStatus = 'Returned' THEN OrderID END) AS Return_orders,
CONCAT(ROUND(COUNT(DISTINCT CASE WHEN OrderStatus = 'Returned' THEN OrderID END) * 100 
/ COUNT(DISTINCT OrderID),2), ' %') AS Returned_Percentage
FROM orders 
GROUP BY Brand, Series;


-- Question3: What are the Average Order Value (AOV), average units per order, and percentage revenue share across each sales channel?
-- Objective: Compare the commercial performance of different sales channels using delivered order metrics.
-- Approach: Filter for Delivered orders and group by Channel Type. Compute order count, revenue, AOV, and units per order, 
-- then use a subquery to calculate each channel's share of total revenue.

SELECT ChannelType,
COUNT(DISTINCT OrderID) AS Total_Orders,
ROUND(SUM(InvoiceAmount) / 10000000, 2) AS Total_Amount_in_Million,
ROUND(SUM(InvoiceAmount) / COUNT(DISTINCT OrderID), 2) AS Average_Amount,
CONCAT(ROUND(SUM(InvoiceAmount) * 100 / (SELECT SUM(InvoiceAmount) FROM orders
WHERE OrderStatus = 'Delivered'),2), ' %') AS Total_Amount_Share
FROM orders WHERE OrderStatus = 'Delivered' GROUP BY ChannelType;

-- Question4: How does delivery duration impact the order return rate, and after how many days do returns start rising?
-- Objective: Analyze return rates across delivery time buckets to minimize delivery delays and return costs.
-- Approach: Filter for Delivered and Returned orders with delivery times between 0 and 30 days. Group orders into delivery
-- buckets (0-2, 3-5, 6-7, 8-10, >10 days) and compare total orders, returned orders, and return rates for each bucket.

SELECT 
    CASE
        WHEN DELIVERYDAYS BETWEEN 0 AND 2 THEN '1) 0-2 DAYS'
        WHEN DELIVERYDAYS BETWEEN 3 AND 5 THEN '2) 3-5 DAYS'
        WHEN DELIVERYDAYS BETWEEN 6 AND 7 THEN '3) 6-7 DAYS'
        WHEN DELIVERYDAYS BETWEEN 8 AND 10 THEN '4) 8-10 DAYS'
        ELSE '5) AS MORE THEN 10 DAYS' END AS DELIVERY_DAYS,
COUNT(DISTINCT ORDERID) AS TOTAL_SHIP_ORDER,
COUNT(DISTINCT CASE WHEN ORDERSTATUS = 'RETURNED' OR ORDERSTATUS = 'Cancelled' THEN ORDERID END) AS RETURN_OR_CANCEL_ORDER,
CONCAT(ROUND(COUNT(DISTINCT CASE WHEN ORDERSTATUS = 'RETURNED' THEN ORDERID END) * 100 /COUNT(DISTINCT ORDERID),2),'%') AS RETURN_AND_CANCEL_RATE_PERCENTAGE,
CONCAT(ROUND(SUM(RefundAmount)/ 100000,2), ' LAKH') AS REFUND_MONEY_IN_LAKH
FROM orders
WHERE ORDERSTATUS IN ('Delivered','Returned') AND DELIVERYDAYS BETWEEN 0 AND 30
GROUP BY DELIVERY_DAYS
ORDER BY DELIVERY_DAYS DESC;

-- Question5: What is the total revenue and percentage revenue share by financial year and quarter?
-- Objective: Track quarterly and yearly revenue trends and their share of total revenue.
-- Approach: Group by Financial Year and Quarter, compute total revenue and percentage share, and order chronologically by Financial Year and Quarter

SELECT FinancialYear, 
	   Quarter,
       CONCAT(ROUND(SUM(InvoiceAmount) / 100000, 2), ' Lakh') AS Total_Revenue,
       CONCAT(ROUND(SUM(InvoiceAmount * 100.0) / SUM(SUM(InvoiceAmount)) OVER(), 2), ' %') AS Revenue_Percentage 
FROM orders
WHERE OrderStatus = 'Delivered'
GROUP BY FinancialYear, Quarter
ORDER BY FinancialYear, Quarter;


-- Question6: How do monthly new customer sign-ups and repeat order rates perform across customer segments?
-- Objective: Measure monthly customer acquisition and reorder behavior by segment.
-- Approach: Join the Customers table for segment details, filter for Delivered orders, group by Customer Segment 
-- and Order Month, and sort chronologically by Order Month.


SELECT YEAR(OrderDate) AS 'Year',
MONTH(OrderDate) AS 'Month_num',
MONTHNAME(OrderDate) AS 'Month',
CONCAT(ROUND(COUNT(DISTINCT CASE WHEN CustomerSegment = 'New' THEN c.CustomerID END) / COUNT(DISTINCT o.CustomerID) * 100.0, 2), ' %') AS 'New',
CONCAT(ROUND(COUNT(DISTINCT CASE WHEN CustomerSegment = 'Repeat' THEN c.CustomerID END) / COUNT(DISTINCT o.CustomerID) * 100.0, 2), ' %') AS 'Repeat',
CONCAT(ROUND(COUNT(DISTINCT CASE WHEN CustomerSegment = 'Premium' THEN c.CustomerID END) / COUNT(DISTINCT o.CustomerID) * 100.0, 2), ' %') AS 'Premium',
COUNT(DISTINCT o.CustomerID) AS Total_Customer,
COUNT(OrderID) AS Total_Order
FROM orders o 
JOIN customer c on o.CustomerID = c.CustomerID
WHERE OrderStatus = 'Delivered'
GROUP BY YEAR(OrderDate), MONTH(OrderDate), MONTHNAME(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);     

-- Question7: Which gender generates the highest sales revenue, and what is the revenue percentage split by gender?
-- Objective: Compare total sales revenue and percentage contribution across genders.
-- Approach: Join the Customers table for Gender, filter for Delivered orders, group by Gender, and 
-- divide each group's revenue by the total invoice amount to get the revenue percentage.

SELECT
FinancialYear, C.Gender, 
ROUND(SUM(O.InvoiceAmount) / 10000000, 2) AS Total_Amount_in_Millions,
CONCAT(ROUND(SUM(O.InvoiceAmount) * 100.0 / SUM(SUM(O.InvoiceAmount)) OVER(),2), ' %') AS Amount_Percentage
FROM orders O
INNER JOIN CUSTOMER C ON O.CustomerID = C.CustomerID
WHERE O.OrderStatus = 'Delivered'
GROUP BY FinancialYear, C.Gender
ORDER BY FinancialYear, Total_Amount_in_Millions DESC;

-- Question8: Which payment method has the highest usage frequency, highest total revenue, and largest revenue percentage share?
-- Objective: Compare payment methods based on transaction count, total revenue generated, and percentage revenue contribution.
-- Approach: Filter for Delivered orders using PaymentMethod and InvoiceAmount. Group by PaymentMethod to compute 
-- order count, total revenue, and revenue percentage, then sort using ORDER BY to identify the top contributors.

SELECT PaymentMethod,
COUNT(*) AS Total_Orders,
ROUND(SUM(InvoiceAmount) / 10000000, 2) AS Total_Amount_in_Millions,
CONCAT(ROUND(SUM(InvoiceAmount) * 100.0 / SUM(SUM(InvoiceAmount)) OVER(), 2), ' %') AS Amount_Percentage
FROM orders
WHERE OrderStatus = 'Delivered'
GROUP BY PaymentMethod
ORDER BY Total_Amount_in_Millions DESC;


-- Question: How do online and offline sales ratios compare across different time zones?
-- Objective: Measure channel-wise order distribution by time zone to identify peak operating windows.
-- Approach: Group delivered orders by Timezone and Sales Channel to analyze traffic flow, order counts, and the online vs. offline sales ratio.
SELECT dayperiod,CHANNELTYPE, COUNT(DISTINCT ORDERID) AS TOTAL_ORDERS
FROM ORDERS WHERE ORDERSTATUS = 'DELIVERED' GROUP BY  dayperiod,CHANNELTYPE ORDER BY dayperiod DESC;

-- Question: Which quarter performs the best and lowest in terms of revenue within each financial year?
-- Objective: Pinpoint the highest- and lowest-performing quarters per financial year to understand seasonal sales trends.
-- Approach: Aggregate total revenue by FINANCIALYEAR and QUARTER inside a CTE, rank the quarters in both ascending and 
-- descending order using ROW_NUMBER(), and combine the top (RN = 1) rows from each via UNION ALL.
WITH CTE AS 
(SELECT FINANCIALYEAR,QUARTER, CONCAT(ROUND(SUM(INVOICEAMOUNT)/10000000,2),' CR') AS TOTAL_AMOUNT
FROM ORDERS GROUP BY FINANCIALYEAR,QUARTER),
RANKED AS(SELECT*, ROW_NUMBER() OVER (partition by FINANCIALYEAR ORDER BY TOTAL_AMOUNT DESC )AS RN FROM CTE)
SELECT FINANCIALYEAR,QUARTER,TOTAL_AMOUNT, 'BEST QUARTER'AS REPORT FROM RANKED WHERE RN = 1
UNION ALL
SELECT FINANCIALYEAR,QUARTER,TOTAL_AMOUNT, 'LOWEST QUARTER'AS REPORT FROM
(SELECT*, ROW_NUMBER() OVER (partition by FINANCIALYEAR ORDER BY TOTAL_AMOUNT ASC) AS RN FROM CTE)AS LOWEST
WHERE RN = 1;
