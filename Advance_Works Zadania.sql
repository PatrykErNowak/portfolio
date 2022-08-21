/*
Exercises from sqlzoo.net based on Microsoft's AdventureWorksLT database.
*/

/*
EASY QUESTIONS

1. Show the first name and the email address of customer with CompanyName 'Bike World'
*/
SELECT FirstName
		,EmailAddress
FROM SalesLT.Customer
WHERE CompanyName= 'Bike World';

/*
EASY QUESTIONS

2. Show the CompanyName for all customers with an address in City 'Dallas'.
*/
SELECT C.CompanyName
FROM SalesLT.Customer AS C
	INNER JOIN SalesLT.CustomerAddress AS CA
			ON C.CustomerID=CA.CustomerID
	INNER JOIN SalesLT.Address AS A
			ON CA.AddressID=A.AddressID
WHERE A.City='DALLAS';

/*
EASY QUESTIONS

3. How many items with ListPrice more than $1000 have been sold?
*/
SELECT COUNT(*) AS TOTAL
FROM SalesLT.SalesOrderDetail AS SOD
	INNER JOIN SalesLT.Product AS P
		ON SOD.ProductID=P.ProductID
WHERE ListPrice>1000;

/*
EASY QUESTIONS

4. Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.
*/
SELECT C.CompanyName
FROM SalesLT.Customer AS C
	INNER JOIN SalesLT.SalesOrderHeader AS SOH
		ON C.CustomerID=SOH.CustomerID
WHERE SOH.SubTotal+SOH.TaxAmt+SOH.Freight> 100000;

/*
EASY QUESTIONS

5. Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
*/
SELECT P.Name
		,SOD.OrderQty

FROM SalesLT.Customer AS C
	INNER JOIN SalesLT.SalesOrderHeader AS SOH
		ON C.CustomerID=SOH.CustomerID
	INNER JOIN SalesLT.SalesOrderDetail AS SOD
		ON SOH.SalesOrderID=SOD.SalesOrderID
	INNER JOIN SalesLT.Product AS P
		ON P.ProductID=SOD.ProductID

WHERE C.CompanyName='Riding Cycles' AND P.Name='Racing Socks, L';

/*
MEDIUM QUESTIONS

6. A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.
*/

WITH TEMP AS 
		(
		SELECT  SalesOrderID
			,SUM(OrderQty) AS One_Item
		FROM SalesLT.SalesOrderDetail
		GROUP BY SalesOrderID
		HAVING SUM(OrderQty) = 1
		)

SELECT SalesOrderID
		,UnitPrice
FROM SalesLT.SalesOrderDetail
WHERE SalesOrderID IN(SELECT SalesOrderID FROM TEMP);

/*
MEDIUM QUESTIONS

7. Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
*/

SELECT P.Name
		,C.CompanyName
FROM SalesLT.Product AS P
INNER JOIN SalesLT.SalesOrderDetail AS SOD
			ON P.ProductID=SOD.ProductID
INNER JOIN SalesLT.SalesOrderHeader as SOH
			ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN SalesLT.Customer AS C
			ON SOH.CustomerID=C.CustomerID
WHERE NAME LIKE '%Racing Socks%';

/*
MEDIUM QUESTIONS

8. Show the product description for culture 'fr' for product with ProductID 736.
*/
SELECT PD.Description
FROM SalesLT.ProductDescription AS PD
INNER JOIN SalesLT.ProductModelProductDescription AS PMPD
			ON PD.ProductDescriptionID=PMPD.ProductDescriptionID
INNER JOIN SalesLT.Product AS P
			ON PMPD.ProductModelID=P.ProductModelID
WHERE ProductID=736 AND Culture='FR';

/*
MEDIUM QUESTIONS

9. Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.
*/

SELECT C.CompanyName  
		,SOH.SubTotal
		,SUM(OrderQty*Weight) AS WEIGHT_OF_ORDER
FROM SalesLT.SalesOrderHeader AS SOH
INNER JOIN SalesLT.Customer AS C
		 ON SOH.CustomerID=C.CustomerID
INNER JOIN SalesLT.SalesOrderDetail AS SOD
		 ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN SalesLT.Product AS P
		 ON SOD.ProductID=P.ProductID
GROUP BY SOH.SalesOrderID , C.CompanyName, SOH.SubTotal
ORDER BY SubTotal DESC;

/*
MEDIUM QUESTIONS

10. How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
*/

SELECT SUM(OrderQty) AS CRANKSETS_TO_LONDON 
FROM SalesLT.ProductCategory AS C
INNER JOIN SalesLT.Product AS P
			ON C.ProductCategoryID=P.ProductCategoryID
INNER JOIN SalesLT.SalesOrderDetail AS SOD
			ON P.ProductID=SOD.ProductID
INNER JOIN SalesLT.SalesOrderHeader AS SOH
			ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN SalesLT.Address AS A
			ON A.AddressID=SOH.ShipToAddressID
WHERE C.Name='Cranksets' AND A.City='London';

/*
HARD QUESTIONS

11. For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.
*/
SELECT CompanyName
		,MAX(CASE WHEN CA.AddressType='Main Office' THEN A.AddressLine1 ELSE '' END) AS MAIN
		,MAX(CASE WHEN CA.AddressType='Shipping' THEN A.AddressLine1 ELSE '' END) AS SHIPPING
FROM SalesLT.Customer AS C
INNER JOIN SalesLT.CustomerAddress AS CA
			ON C.CustomerID=CA.CustomerID
INNER JOIN SalesLT.Address AS A
			ON CA.AddressID=A.AddressID
WHERE A.City='Dallas'
GROUP BY C.CompanyName;

/*
HARD QUESTIONS

12. For each order show the SalesOrderID and SubTotal calculated three ways:
	A) From the SalesOrderHeader
	B) Sum of OrderQty*UnitPrice
	C) Sum of OrderQty*ListPrice
*/

WITH TEMP1 AS (
				SELECT SD.SalesOrderID
						,SUM(OrderQty*UnitPrice) AS ORDER_UNIT_PRICE
				FROM SalesLT.SalesOrderDetail AS SD
				GROUP BY SD.SalesOrderID
				)

,TEMP2 AS (
				SELECT SalesOrderID
						,SUM(OrderQty*ListPrice) AS LIST_PRICE
				FROM SalesLT.SalesOrderDetail
				INNER JOIN SalesLT.Product ON SalesLT.SalesOrderDetail.ProductID=SalesLT.Product.ProductID
				GROUP BY SalesOrderID
				)

SELECT SOH.SalesOrderID
		,SOH.SubTotal
		,ORDER_UNIT_PRICE
		,LIST_PRICE
FROM SalesLT.SalesOrderHeader AS SOH
INNER JOIN TEMP1	ON SOH.SalesOrderID=TEMP1.SalesOrderID
INNER JOIN TEMP2	ON SOH.SalesOrderID=TEMP2.SalesOrderID;

/*
HARD QUESTIONS

13. Show the best selling item by value.
*/

SELECT TOP 1 P.Name
		,SUM(SOD.OrderQty*SOD.UnitPrice) AS TOTAL
FROM SalesLT.Product AS P
INNER JOIN SalesLT.SalesOrderDetail AS SOD
			ON SOD.ProductID=P.ProductID
GROUP BY P.Name
ORDER BY TOTAL DESC
