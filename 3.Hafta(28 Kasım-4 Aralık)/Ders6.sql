-- Ödev tekrar soruları

/*
Bu zamana kadar sattığım en ucuz üründen,
o ucuz fiyata kaç tane satmışım?
*/
/*
SELECT *,UnitPrice * (1-Discount)
FROM [Order Details]
ORDER BY UnitPrice * (1-Discount)
*/

SELECT TOP 1 Quantity, UnitPrice * (1-Discount)
FROM [Order Details]
ORDER BY UnitPrice * (1-Discount)
/*
Son teslim edilen 10 siparişi gösterin.
*/
SELECT TOP 10 OrderId
FROM Orders
WHERE ShippedDate IS NOT NULL
ORDER BY ShippedDate DESC
/*
En genç 3 çalışanı listeleyin.
*/

SELECT TOP 3 *
FROM Employees
ORDER BY BirthDate DESC

------------------------------------

--Join Uygulama

/* Almanya'ya Federal Shipping ile taşınmış
siparişleri onaylayan çalışanlar kimlerdir?
*/

SELECT DISTINCT E.FirstName + ' ' +E.LastName
FROM Orders O
JOIN Employees E ON O.EmployeeID = E.EmployeeID
JOIN Shippers S ON O.ShipVia = S.ShipperID
WHERE O.ShipCountry ='Germany' AND
S.CompanyName ='Federal Shipping'

/*
Nancy Davolio hangi ürünleri satmıştır?
*/

SELECT DISTINCT P.ProductName
FROM Orders O
JOIN Employees E 
ON O.EmployeeID =E.EmployeeID
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
JOIN Products P
ON OD.ProductID = P.ProductID
WHERE E.FirstName ='Nancy' AND E.LastName ='Davolio'

/*
New york şehrinden sorumlu çalışan/çalışanlar kimlerdir?
*/

SELECT DISTINCT E.FirstName + ' ' + E.LastName
FROM Employees E
JOIN EmployeeTerritories ET
ON E.EmployeeID = ET.EmployeeID
JOIN Territories T
ON ET.TerritoryID = T.TerritoryID
WHERE T.TerritoryDescription ='New York'

/*
Mart ayında doğan çalışanların ilgilendiği
müşteriler kimlerdir?
*/

SELECT DISTINCT C.CompanyName
FROM Orders O
JOIN Customers C
ON O.CustomerID =C.CustomerID
JOIN Employees E
ON O.EmployeeID = E.EmployeeID
WHERE MONTH(E.BirthDate) = 3

--------------------------------------

-- GROUP BY 

-- Veriyi gruplamak için kullanılır
-- Grupladığımız verinin sayısı,toplamı vs.

-- Her kategoride kaç tane ürün vardır?

SELECT C.CategoryName, 
       COUNT(P.ProductID) AS ProductCount
FROM Products P
     JOIN Categories C
	 ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryName

-- Ülke bazında müşteri bilgisi

SELECT Country,
       COUNT(CustomerID)
FROM Customers
GROUP BY Country

SELECT TOP 1 Country,
       COUNT(CustomerID) AS MusteriSayisi
FROM Customers
GROUP BY Country
ORDER BY MusteriSayisi DESC

SELECT TOP 1 Country
       FROM Customers
GROUP BY Country
ORDER BY  COUNT(CustomerID) DESC

-- Hangi tedarikçiden kaç çeşit ürün tedarik ediliyor?

SELECT S.CompanyName,
       COUNT(P.ProductID)
FROM Products P
JOIN Suppliers S ON P.SupplierID = S.SupplierID
GROUP BY S.CompanyName

--Her siparişten ne kadar kazanılmış?

SELECT OrderID,
       SUM(UnitPrice*Quantity*(1-Discount))
FROM [Order Details]
GROUP BY OrderID

--Her kategoriye ait min ürün fiyatı
SELECT C.CategoryName,
        MIN(P.UnitPrice)
FROM Categories C
JOIN Products P
ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName

/*
Hangi çalışan kaç tane siparişle ilgilenmiş?
CalisaninTamAdi | SiparisSayisi
*/
SELECT E.FirstName + ' ' + E.LastName AS CalisaninTamAdi,
       COUNT(O.OrderID) AS SiparisSayisi
FROM Orders O
JOIN Employees E 
ON O.EmployeeID = E.EmployeeID
--GROUP BY E.FirstName,E.LastName
GROUP BY E.FirstName + ' ' + E.LastName

--ülke ve şehir bilgisine bağlı müşteriler
SELECT Country, City, COUNT(CustomerID)
FROM Customers
GROUP BY Country, City

--En çok hangi kargo şirketi ile gönderilen siparişlerde gecikme olmuştur? Kargocu | Gecikme

SELECT TOP 1 S.CompanyName AS Kargocu,
       COUNT(O.OrderID) AS GecikmeSayisi
FROM Orders O
JOIN Shippers S
ON O.ShipVia =S.ShipperID
WHERE O.ShippedDate > O.RequiredDate
GROUP BY S.CompanyName
ORDER BY GecikmeSayisi DESC

--10'dan fazla gecikme yaşadığım kargo firmaları

SELECT *
FROM Orders O
JOIN Shippers S 
ON O.ShipVia =S.ShipperID
WHERE O.ShippedDate > O.RequiredDate
GROUP BY S.CompanyName
HAVING COUNT(O.OrderID)>10

-- Condiments kategorisindeki ürünlerden kaç kez sipariş verilmiştir?

SELECT C.CategoryName,
       P.ProductName,
       COUNT(OD.OrderID)
FROM Categories C
JOIN Products P ON C.CategoryID = P.CategoryID
JOIN [Order Details] OD ON P.ProductID = OD.ProductID
WHERE C.CategoryName='Condiments'
GROUP BY C.CategoryName,
         P.ProductName
--HAVING C.CategoryName='Condiments'

-- 10'dan fazla ürüne sahip kategoriler

SELECT C.CategoryName
FROM Categories C
JOIN Products P ON C.CategoryID= P.CategoryID
GROUP BY C.CategoryName
HAVING COUNT(P.ProductID)>10

--50'den fazla sipariş alınan ülkelere göre ciro nedir? Ulke | Ciro
SELECT O.ShipCountry AS Ulke,
       SUM(OD.UnitPrice * OD.Quantity * (1-Discount)) AS Ciro,
       COUNT(DISTINCT O.OrderID) AS SiparisSayisi
FROM Orders O
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.ShipCountry
HAVING COUNT(DISTINCT O.OrderID) > 50

--------------------------------------

-- SUBQUERY

-- SELECT CLAUSE (Correlated Subquery)
-- WHERE CLAUSE (Basic Query)
-- FROM CLAUSE

--SELECT CLAUSE
-- 1997 yılında sipariş veren müşteriler. SiparisNo | Musteri

SELECT OrderID,
       (SELECT CompanyName
	   FROM Customers C
	   WHERE C.CustomerID = O.CustomerID
	   ) AS Musteri
FROM Orders O
WHERE YEAR(OrderDate) = 1997

-- 1997 yılında sipariş veren müşteriler ve ilgilenen çalışanlar. SiparisNo | Musteri | Calisan

SELECT OrderID,
       (SELECT CompanyName
	   FROM Customers C
	   WHERE C.CustomerID = O.CustomerID
	   ) AS Musteri,
	   (SELECT FirstName + ' ' + LastName
	   FROM Employees
	   WHERE EmployeeID = O.EmployeeID) AS Calisan
FROM Orders O
WHERE YEAR(OrderDate) = 1997

-- Her müşteriyi ve verdiği ilk siparişin tarihi

SELECT CompanyName,
       (SELECT MIN(OrderDate) 
	   FROM Orders
	   WHERE CustomerID = C.CustomerID)
FROM Customers C

-- WHERE CLAUSE

-- Ortalama ürün fiyatından yüksek fiyatı olan ürünler

SELECT *
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice)
                   FROM Products)

-- Janet adlı çalışanın şehrinde bulunan müşteriler

SELECT *
FROM Customers
WHERE City = (SELECT City
              FROM Employees
			  WHERE FirstName='Janet')

-- FROM CLAUSE

--İlk 10 ürün içerisinde kritik stok seviyesi 0 olanlar

SELECT TOP 10*
FROM Products
WHERE ReorderLevel = 0

SELECT UrunAdi
FROM
   (
   SELECT TOP 10 ProductName AS UrunAdi,
                 ReorderLevel AS KritikSeviye
   FROM Products
   ) AS Ilk10Urun
WHERE KritikSeviye = 0

-----------------------------------

-- Amerika'da yaşayan çalışanların aldığı siparişler

SELECT *
FROM Orders
WHERE EmployeeID IN ( SELECT EmployeeID
                     FROM Employees
					 WHERE Country='USA'
					 )









