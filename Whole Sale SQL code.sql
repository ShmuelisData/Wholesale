--1st I cleaned duplicates in Excel. 2nd: Imported the cleaned data into SQL.

--deleting some Null columns
delete from Online_retail..y2010  
where country IS NULL

delete from Online_retail..y2011  
where country IS NULL


SELECT * FROM Online_retail..y2010 y10



--Joining the y2010 and y2011 is broken because, there is no Primary Key.
--We will work on both at the same time but separately.


--Calculating total revenue for the year 2010
SELECT SUM(price*quantity) AS Yearly_Revenue
FROM online_retail..y2010

--As we can see the Total revenue is $9,505,775 Including credit transactions.

--2011
SELECT SUM(price*quantity) AS Yearly_Revenue
FROM online_retail..y2011 
--As we can see the Total revenue is $9,726,024 Including credit transactions.



--Looking at sales in terms of the month.

--2009-12
SELECT SUM(revenue) AS Total_revenue
FROM (
SELECT y10.quantity * y10.price AS revenue
FROM Online_retail..y2010 y10
WHERE invoice_date BETWEEN '2009-12-01' AND '2009-12-31'
)
subquery_alias;
-- $796,648.
-- On second thought, in Excel, we can convert the Yearly revenue into months using Pivot Table, easily.


--Looking at the top products in terms of the number of sales, before calculating product returns.

SELECT TOP 10 description, SUM(quantity) AS Sales_num 
FROM Online_retail..y2010 y10
GROUP BY description
ORDER BY sales_num DESC

--2011
SELECT TOP 10 description, SUM(quantity) AS Sales_num 
FROM Online_retail..y2011 y11
GROUP BY description
ORDER BY sales_num DESC

--Products Share GROSS
--2010
SELECT Description AS Products, SUM(quantity*price) AS Product_Share
FROM Online_retail..y2010
GROUP BY description
ORDER BY Product_Share DESC 
--1. REGECY CAKESTAN 3 TIER - 162,885$. 2. WHITE HANGING HEART T-LIGHT 157,580$. 3. DOTCOM POSTAGE 116,401$.

--2011 
SELECT Description AS Products, SUM(quantity*price) AS Product_Share
FROM Online_retail..y2011
GROUP BY description
ORDER BY Product_Share DESC
--1. DOTCOM POSTAGE 206,245$. 2. REGECY CAKESTAN 3 TIER 164,459$. 3. WHITE HANGING HEART T-LIGHT 99,612$.



--Looking at top products in revenue share (including different prices and returns)
With product_revenue AS(
SELECT description, price, SUM(quantity) AS top_products
FROM Online_retail..y2010 y10
GROUP BY description, price
)
SELECT description, price, top_products * price AS Products_Revenue
from product_revenue
ORDER BY products_revenue DESC

--Here I'd like to double-check if the Sum of Products_Revenue with different prices gives the Accurate product gross share.
--and it is Accurate.
With product_revenue AS(
SELECT description, price, SUM(quantity) AS top_products
FROM Online_retail..y2010 y10
WHERE description LIKE 'REGENCY CAKESTAND%'
GROUP BY description, price
)
SELECT description, price, top_products * price AS Products_Revenue
from product_revenue
ORDER BY products_revenue DESC

--2011
With product_revenue AS(
SELECT description, price, SUM(quantity) AS top_products
FROM Online_retail..y2011 y11
GROUP BY description, price
)
SELECT description, price, top_products * price AS Products_Revenue
from product_revenue
ORDER BY products_revenue DESC

 
-- Looking at the  top customers and where they are from
SELECT TOP 100 customer_id, country, SUM(price*quantity) AS Total_Orders_value
FROM Online_retail..y2010 y10
WHERE customer_id IS NOT NULL
GROUP BY customer_id, country
ORDER BY Total_Orders_value DESC

--2011
SELECT TOP 100 customer_id, country, SUM(price*quantity) AS Total_Orders_value
FROM Online_retail..y2011 y11
WHERE customer_id IS NOT NULL
GROUP BY customer_id, country
ORDER BY Total_Orders_value DESC

-- Looking at the Largest invoice volume
 
SELECT TOP 100 invoice, customer_id ,SUM(price*quantity) AS Largest_Invoice
FROM Online_retail..y2010 y10
WHERE customer_id IS NOT NULL
GROUP BY invoice, customer_id, country
ORDER BY Largest_Invoice DESC

--2011
SELECT invoice, customer_id ,SUM(price*quantity) AS Largest_Invoice
FROM Online_retail..y2011 y11
WHERE customer_id IS NOT NULL
GROUP BY invoice, customer_id, country
ORDER BY Largest_Invoice DESC


--Looking at the sales by countries
SELECT country, SUM(price*quantity) AS Order_value
FROM Online_retail..y2010 y10
WHERE customer_id IS NOT NULL
GROUP BY country
ORDER BY Order_value DESC

--2011
SELECT country, SUM(price*quantity) AS Order_value
FROM Online_retail..y2011 y11
WHERE customer_id IS NOT NULL
GROUP BY country
ORDER BY Order_value DESC


-- Comparing Yearly revenue to the Product sales revenue to assure accuracy.

--Taking the Top_products sales* price AS Products_revenue and Sum the Products_revenue AS Total_revenue

WITH product_revenue AS (
    SELECT description, price, SUM(quantity) AS top_products
    FROM Online_retail..y2010 y10
    GROUP BY description, price
)
SELECT SUM(Products_Revenue) AS Total_Revenue
FROM (
    SELECT description, price, top_products * price AS Products_Revenue
    FROM product_revenue
) subquery;



SELECT SUM(revenue) AS Total_revenue
FROM (
SELECT y10.quantity * y10.price AS revenue
FROM Online_retail..y2010 y10
) subquery;

--From these queries, we can see that our calculations are accurate, Same revenues.


--Looking at the average invoice value.
--2010
SELECT AVG(Order_value) AS Avg_order_value
FROM (
    SELECT invoice, customer_id, SUM(price * quantity) AS Order_value
    FROM Online_retail..y2010 y10
    WHERE customer_id IS NOT NULL
    GROUP BY invoice, customer_id, country
    HAVING SUM(price * quantity) > 0
) AS Orders;

--2011
SELECT AVG(Order_value) AS Avg_order_value
FROM (
    SELECT invoice, customer_id, SUM(price * quantity) AS Order_value
    FROM Online_retail..y2011 y11
    WHERE customer_id IS NOT NULL
    GROUP BY invoice, customer_id, country
    HAVING SUM(price * quantity) > 0
) AS Orders;


SELECT  invoice,  COUNT(invoice) AS Count_invoice
FROM online_retail..y2010
WHERE invoice IS NOT NULL
GROUP BY invoice
