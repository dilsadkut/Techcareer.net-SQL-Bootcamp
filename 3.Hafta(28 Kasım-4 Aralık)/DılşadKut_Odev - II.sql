/*
  Dılşad Kut                                      
  Techcareer.net MS SQL Bootcamp 3.hafta Ödevi
  03.12.2022 Cumartesi
*/

/* Londra'da yaşayan çalışanların ilgilendiği müşterilerden 
Almanya'da yaşayanlar kimlerdir? 
*/

SELECT *
FROM Employees E
JOIN Orders O
ON E.EmployeeID = O.EmployeeID
JOIN Customers C 
ON C.CustomerID = O.CustomerID
WHERE E.City= 'London' AND O.ShipCountry ='Germany'

/* Her yıl hangi ülkeye kaç adet sipariş gönderilmiş? 
Year | Country | TotalOrdersCount
*/

SELECT YEAR(OrderDate) AS Year,
       ShipCountry AS Country,
	   COUNT(OrderID) AS TotalOrdersCount
FROM Orders
GROUP BY YEAR(OrderDate), ShipCountry

-- En çok para kazandıran müşteri kimdir?

SELECT TOP 1 C.CompanyName, OD.UnitPrice, OD.Quantity, OD.Discount,
OD.UnitPrice*OD.Quantity-OD.Discount AS Tutar
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
ORDER BY Tutar DESC

/* Batı bölgesinden sorumlu çalışanları ilgilendikleri 
müşteri sayısı nedir? Calisan | MusteriSayisi
*/

SELECT E.FirstName + ' ' + E.LastName AS Calisan,
COUNT(C.CustomerID) AS MusteriSayisi
FROM Employees E
JOIN EmployeeTerritories ET
ON E.EmployeeID=ET.EmployeeID
JOIN Territories T
ON T.TerritoryID = ET.TerritoryID
JOIN Region R
ON T.RegionID = R.RegionID
JOIN Orders O
ON O.EmployeeID = E.EmployeeID 
JOIN Customers C
ON C.CustomerID = O.CustomerID
WHERE R.RegionDescription = 'Western'
GROUP BY E.FirstName, E.LastName

-- ALFKI kodlu müşteri hangi kategorilerden sipariş vermiştir?
SELECT CustomerID, CategoryName
FROM Orders O
JOIN Categories C
ON O.EmployeeID= C.CategoryID
WHERE CustomerID='ALFKI'

/* Müşterilerin verdikleri sipariş sayılarına göre 1-10 arası 
'Silver', 10-20 arası 'Gold', 20 üzeri 'Platinum' olacak şekilde 
müşteri tiplerini listeleyin. Musteri | SiparisSayisi | Tip 
*/

SELECT C.CompanyName AS Musteri,
COUNT(O.OrderID) AS SiparisSayisi,
       Tip = CASE 
             WHEN COUNT(O.OrderID)>=1 AND COUNT(O.OrderID)<10  THEN 'Silver'
		     WHEN COUNT(O.OrderID)>=10 AND COUNT(O.OrderID)<20  THEN 'Gold'
		     WHEN COUNT(O.OrderID)>=20 THEN 'Platinum'
	    ELSE 'Bilinmiyor'
	    END
		
FROM Orders O
JOIN Customers C
ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.CompanyName

/* Confections kategorisindeki ürünler hangi ülkelere toplam ne 
kadarlık satış ile gönderilmiştir? Ulke | ToplamKazanc */

SELECT S.Country AS Ulke, 
       P.ProductName AS UrunAdi,
	   P.UnitPrice * P.UnitsInStock AS ToplamKazanc   
FROM Products P
JOIN Categories C
ON P.CategoryID = C.CategoryID
JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE C.CategoryName = 'Confections'

/* 20'den fazla sayıda sipariş verilmiş ürünler hangi ülkelere 
gönderilmiştir? Product | Country | OrderCount  
*/
 
SELECT P.ProductName AS Product,
S.Country,
COUNT(OD.OrderID) AS OrderCount
FROM Products P
JOIN Suppliers S
ON P.SupplierID = S.SupplierID
JOIN [Order Details] OD
ON P.ProductID = OD.ProductID
GROUP BY P.ProductName, S.Country
HAVING COUNT(OD.OrderID)>20

-- Dörtten az sipariş veren müşteriler kimlerdir?

SELECT C.CompanyName,
       COUNT(O.OrderID) AS SiparisSayisi
FROM Orders O
JOIN Customers C
ON O.CustomerID = C.CustomerID
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName
HAVING COUNT(O.OrderID)<4

/* Kargo ücreti içerdiği en pahalı ürünün fiyatından yüksek olan 
siparişleri listeleyin.
*/

SELECT O.OrderID,
O.Freight,
MAX(P.UnitPrice) AS ProductPrice
FROM Orders O
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
JOIN Products P
ON OD.ProductID = P.ProductID
GROUP BY O.OrderID, O.Freight
HAVING O.Freight>MAX(P.UnitPrice)


