-- 3. Hafta Ödev Soru Cevapları

SELECT DISTINCT(CompanyName)
FROM Orders O
JOIN Customers C ON O.CustomerID =C.CustomerID
JOIN Employees E ON O.EmployeeID = E.EmployeeID
WHERE E.City ='London' AND C.Country='Germany'
---------------------------------------

SELECT YEAR(ShippedDate) AS [Year],
       ShipCountry AS Country,
	   COUNT(OrderID) AS TotalOrdersCount
FROM Orders
WHERE ShippedDate IS NOT NULL
GROUP BY YEAR(ShippedDate), ShipCountry
-----------------------------------------

SELECT TOP 1 C.CompanyName,
           SUM(OD.Quantity* OD.UnitPrice * (1-OD.Discount)) AS Kazanc
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName
ORDER BY Kazanc DESC

--------------------------------------

SELECT E.FirstName + ' ' + E.LastName,
COUNT( DISTINCT O.CustomerID) AS MusteriSayisi
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
JOIN Employees E 
ON E.EmployeeID = E.EmployeeID
JOIN EmployeeTerritories AS ET
ON E.EmployeeID = ET.EmployeeID
JOIN Territories t 
ON ET.TerritoryID = t.TerritoryID
JOIN Region R 
ON t.RegionID = R.RegionID
WHERE R.RegionDescription = 'Western'
GROUP BY E.FirstName + ' ' + E.LastName

---------------------------------------

SELECT DISTINCT C.CategoryName
FROM Orders O
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
JOIN Products P
ON OD.ProductID = P.ProductID
JOIN Categories C
ON P.CategoryID= C.CategoryID
WHERE O.CustomerID = 'ALFKI'

-------------------------------------

SELECT CompanyName AS Musteri,
       COUNT(O.OrderID) AS SiparisSayisi,
	   CASE
	   WHEN COUNT(O.OrderID)>=1 AND COUNT(O.OrderID)<10 THEN 'Silver'
	   WHEN COUNT(O.OrderID)>=10 AND COUNT(O.OrderID)<20 THEN 'Gold'
	   ELSE 'Platinum'
	   END AS Tip
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
GROUP BY C.CompanyName

-------------------------------------------

SELECT O.ShipCountry AS Ulke,
SUM(OD.UnitPrice * OD.Quantity * (1-OD.Discount)) AS ToplamKazanc
FROM Categories C
JOIN Products P
ON P.CategoryID = C.CategoryID
JOIN [Order Details] OD
ON P.ProductID = OD.ProductID
JOIN Orders O
ON OD.OrderID = O.OrderID
--WHERE C.CategoryName = 'Confections'
GROUP BY C.CategoryName, O.ShipCountry
HAVING C.CategoryName = 'Confections'

-----------------------------------------------

SELECT P.ProductName AS Product,
       O.ShipCountry AS Country,
	   COUNT(O.OrderID) AS OrderCount
FROM Orders O
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
JOIN Products P
ON OD.ProductID = P.ProductID
WHERE P.ProductID IN ( SELECT ProductID                             
                      FROM [Order Details]
					  GROUP BY ProductID
					  HAVING COUNT(*) >20)
GROUP BY P.ProductName,
         O.ShipCountry

----------------------------------------

SELECT CompanyName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID
                      FROM Orders
					  GROUP BY CustomerID
					  HAVING COUNT(OrderID)<4)

------------------------------------------

SELECT O.OrderID, 
       O.Freight,
	   (SELECT MAX(UnitPrice)
       FROM [Order Details]
       WHERE OrderID = O.OrderID
       ) AS MaxUrun
FROM Orders O
WHERE O.Freight > (SELECT MAX(UnitPrice)
                   FROM [Order Details]
				   WHERE OrderID = O.OrderID
                   )
                      
---------------------------------------------

/* FONKSİYONLAR
   FUNCTIONS     */
   
-- USER DEFINIED FUNCTIONS

--İkiye ayrılır.
--Scalar Valued Functions
--View görünüm, sp bir kaç adıma bağlı işlemler yapabildiğimiz yapılar
--Scalar fonksiyonda da yine parametreler ve yapılacak işlemlere bağlı belli bir sonuca erişmemizi sağlar

CREATE FUNCTION Topla(@sayi1 AS INT, @sayi2 AS INT)
RETURNS INT 
AS
BEGIN
   DECLARE @sonuc AS INT
   SET @sonuc= @sayi1+@sayi2
   RETURN @sonuc
END

SELECT dbo.Topla(2,5)
SELECT dbo.Topla(7,10)

ALTER  FUNCTION Topla(@sayi1 AS INT, @sayi2 AS INT = 20)
RETURNS INT 
AS
BEGIN
   DECLARE @sonuc AS INT
   SET @sonuc= @sayi1+@sayi2
   RETURN @sonuc
END

SELECT dbo.Topla(5, DEFAULT)
SELECT dbo.Topla(5, 15)

CREATE FUNCTION FiyatHesapla(@quantity AS INT, @price AS DECIMAL, @discount AS FLOAT)
RETURNS DECIMAL
AS
BEGIN
  RETURN @quantity* @price* (1-@discount)
END

SELECT O.ShipCountry,
       SUM(dbo.FiyatHesapla(OD.Quantity, OD.UnitPrice, OD.Discount))
FROM Orders O
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY O.ShipCountry

-- Table Valued Functions
-- Birden fazla değer dönmemiz gereken durumlarda kullanılır.
-- Bir tablo döndürür.
-- Yazımı scalarden farklıdır.
-- Daha çok view'e benzer ama bunlar fonksiyon olduğundan parametre alıp değerleri kullanabilirler

CREATE FUNCTION SehreGoreMusteriGetir(@sehir AS NVARCHAR(20))
RETURNS TABLE
AS
RETURN (SELECT * FROM Customers WHERE City = @sehir)

SELECT *
FROM dbo.SehreGoreMusteriGetir('London')

SELECT *
FROM dbo.SehreGoreMusteriGetir('London') C
--JOIN Orders O
--ON C.CustomerID = O.CustomerID

SELECT *
FROM dbo.SehreGoreMusteriGetir('London') C
CROSS APPLY Orders O 
WHERE C.CustomerID = O.CustomerID

SELECT *
FROM dbo.SehreGoreMusteriGetir('London') C
OUTER APPLY Orders O 
WHERE C.CustomerID = O.CustomerID

--Multi-Statement Table Valued Functions

ALTER FUNCTION GetOrderInfoByCategory(@CategoryName AS NVARCHAR(15))
RETURNS @orderInfo TABLE
(
    CompanyName NVARCHAR(40) NOT NULL,
	Contact NVARCHAR(30) NULL,
	Employee NVARCHAR(50) NOT NULL

)
AS
BEGIN
    INSERT @orderInfo
    SELECT C.CompanyName,
	C.ContactName AS Contact,
	E.FirstName + ' ' + E.LastName AS Employee
	FROM Customers C
	JOIN Orders O
	ON C.CustomerID = O.CustomerID
	JOIN [Order Details] OD
	ON OD.OrderID = O.OrderID
	JOIN Products P
	ON OD.ProductID = P.ProductID
	JOIN Categories CAT
	ON P.CategoryID = CAT.CategoryID
	JOIN Employees E 
	ON O.EmployeeID =E.EmployeeID
	WHERE CAT.CategoryName=@CategoryName

	RETURN
END

SELECT *
FROM dbo.GetOrderInfoByCategory('Seafood')

SELECT *
FROM dbo.GetOrderInfoByCategory('Beverages')

-----------------------------------------------

-- CURSOR
-- Belirli bir veri seti içerisinde gezmeyi sağlıyor
-- Gezilen veriler arasında verilere bağlı işlem yapmayı sağlar

DECLARE @name AS NVARCHAR(40)
DECLARE @price AS DECIMAL

DECLARE ProductCursor CURSOR FOR
   SELECT ProductName, UnitPrice FROM Products

OPEN ProductCursor

FETCH NEXT FROM ProductCursor INTO @name, @price

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @price >50
	BEGIN
		PRINT @name + ' adlı ürün pahalıdır'
	END
	ELSE
	BEGIN
		PRINT @name + ' adlı ürün ucuzdur'
	END
	FETCH NEXT FROM ProductCursor INTO @name, @price
END

CLOSE ProductCursor
DEALLOCATE ProductCursor


------------------------------------------------------


--Execution Plan

SELECT *
FROM Customers

SELECT C.CompanyName,
      O.OrderID
FROM Customers C
JOIN Orders O 
ON C.CustomerID = O.CustomerID
WHERE C.Country='USA'




