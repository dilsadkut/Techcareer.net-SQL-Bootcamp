--DML Komutları
--CRUD -- Create, Update, Delete
-- INSERT

--Kayıt Ekleme
INSERT INTO Categories([Description],Picture,CategoryName)
VALUES('Her türlü süt, peynir vs.',NULL,'Şarküteri')

SELECT *
FROM Categories

INSERT INTO Categories(CategoryName)
VALUES('Teknoloji')

SELECT *
FROM Categories

INSERT INTO Categories(CategoryName)
VALUES('Teknolojisdfjghfjfdhıhdsfjgdsfklhydsf')

--INSERT INTO GrahamBellDB.Kitap()

SET IDENTITY_INSERT Categories ON -- default değeri OFF sonrası kapatmak önemli

INSERT INTO Categories(CategoryID,CategoryName)
VALUES (1000,'Kozmetik')

SET IDENTITY_INSERT Categories OFF

SELECT * FROM Categories

INSERT INTO Categories(CategoryName)
VALUES ('Kozmetik')

SELECT * FROM Categories

INSERT INTO Shippers(CompanyName)
VALUES('Bizim Kargo'),('Sizin Kargo'),('X Kargo')

SELECT *
FROM Shippers

SELECT *
FROM (VALUES('Bizim Kargo'),('Sizin Kargo'),('X Kargo')) DATASOURCE(KargoAdi)

INSERT INTO Shippers(CompanyName,Phone)
SELECT CompanyName,Fax FROM Customers 

SELECT *
FROM Shippers

--BULK COPY

SELECT *
INTO CustomersCopy
FROM Customers

SELECT FirstName,LastName
INTO EmployeesCopy
FROM Employees

--Teknoloji|ndkjsfvn|jvbdkfv|

--UPDATE

UPDATE CustomersCopy
SET CompanyName = 'TechCareer'

SELECT *
FROM CustomersCopy

UPDATE EmployeesCopy
SET FirstName ='Graham'
WHERE FirstName='Nancy'

SELECT *
FROM EmployeesCopy

UPDATE Shippers
     SET CompanyName='Y Kargo',
	     Phone = '21424'
WHERE ShipperID = 5

SELECT *
FROM Shippers

UPDATE Products
       SET UnitPrice += UnitPrice*2

SELECT *
FROM Products

-- DELETE
DELETE EmployeesCopy

SELECT *
FROM EmployeesCopy

DELETE FROM CustomersCopy

SELECT *
FROM CustomersCopy

DELETE FROM Shippers
WHERE ShipperID>3

SELECT *
FROM Shippers

SELECT *
INTO ProductsCopy
FROM Products

SELECT *
FROM ProductsCopy

DELETE FROM ProductsCopy

SELECT *
FROM ProductsCopy

INSERT INTO ProductsCopy(ProductName,Discontinued)
VALUES ('Telefon',0)

SELECT *
FROM ProductsCopy

--TRUNCATE --DDL Komutu

TRUNCATE TABLE ProductsCopy

SELECT *
FROM ProductsCopy

-- Tablonun tamamı truncate edilir.
-- Truncate where şartı ile kullanılmaz.
-- Truncate kullanılan tabloda Foreign Key olmamalı.
-- DELETE işleminde Foreign Key olabilir.

-- IDENTITY FUNCTIONS

SELECT SCOPE_IDENTITY()
-- En son yapılan insert işleminde kalan id

INSERT INTO Shippers(CompanyName)
VALUES ('Bizim Kargo')

SELECT SCOPE_IDENTITY()

SELECT IDENT_CURRENT('Categories')
-- Özellikle bir tablodaki son id

SELECT @@IDENTITY
-- @@ : Global seviyede geçerli olan değişkenler
-- Kendimiz değişken tanımlarsak tek @ kullanılır

-- T-SQL 
DECLARE @sayi AS INT = 5

--SELECT @sayi

--SET @sayi=10
--PRINT @sayi

SELECT @sayi = COUNT(*) 
FROM Products
PRINT @sayi

DECLARE @fullname AS NVARCHAR(30)
SET @fullname = (SELECT FirstName+' '+LastName FROM Employees WHERE EmployeeID=1)
PRINT @fullname

DECLARE @number AS INT =10
IF @number %2 =0
BEGIN
 PRINT 'Sayı Çifttir'
END
ELSE
BEGIN
 PRINT 'Sayi Tektir'
END

IF EXISTS ( SELECT * FROM Products WHERE ProductID=10)
BEGIN
 PRINT 'Kayıt vardır'
 SELECT * FROM Products WHERE ProductID=10
END
ELSE
BEGIN
 PRINT 'Kayıt Yoktur'
END

IF NOT EXISTS ( SELECT * FROM Products WHERE ProductID=10)
BEGIN
 PRINT 'Kayıt yoktur'
END
ELSE
BEGIN
 PRINT 'Kayıt vardır'
 SELECT * FROM Products WHERE ProductID=10
END

DECLARE @sayac AS INT =1
WHILE @sayac<=10
BEGIN
  PRINT @sayac
  SET @sayac+=1
END

-- ID'si tek olan çalışanlar
DECLARE @counter AS INT = 1
DECLARE @employeeCount AS INT
DECLARE @employeeID AS INT
DECLARE @name AS VARCHAR(50)

SELECT @employeeCount = COUNT(*) FROM Employees

WHILE @counter <= @employeeCount
BEGIN
	IF EXISTS(SELECT *
			  FROM Employees
			  WHERE EmployeeID = @counter)
	BEGIN
		SELECT @name = FirstName + ' ' + LastName
			  FROM Employees
			  WHERE EmployeeID = @counter

		IF @counter % 2 = 1
		BEGIN
			PRINT @name
		END
	END
	ELSE
	BEGIN
		PRINT ''
	END

	SET @counter += 1
END

 ----------------------
 --İlişkisel verileri sorgulama
 --SQL JOIN Yapıları

 -- join yazmadan join
 SELECT P.ProductName,C.CategoryName
 FROM Products P, Categories C
 WHERE P.CategoryID = C.CategoryID

 -- inner join
-- her iki tabloda sadece eşleşenler yani kesişim

SELECT P.ProductName,C.CategoryName
FROM Products P
INNER JOIN Categories C
ON P.CategoryID = C.CategoryID

-- inner join için sadece join kelimesi de kullanılabilir

SELECT P.ProductName,C.CategoryName
FROM Products P
JOIN Categories C
ON P.CategoryID = C.CategoryID

-- OUTER JOIN
-- Eşleşmeyenler dahil tüm kayıtlar gelsin
-- LEFT RIGHT FULL OUTER diye 3 e ayrılır.

SELECT P.ProductName,C.CategoryName
FROM Products P
LEFT OUTER JOIN Categories C
ON P.CategoryID = C.CategoryID

SELECT P.ProductName,ISNULL(C.CategoryName,'Yok')
FROM Products P
LEFT JOIN Categories C
ON P.CategoryID = C.CategoryID

SELECT ISNULL(P.ProductName,'Yok'),C.CategoryName
FROM Products P
RIGHT JOIN Categories C
ON P.CategoryID = C.CategoryID

--Burda aslında right join yapıyoruz
SELECT P.ProductName,
       C.CategoryName
FROM Categories C
LEFT JOIN Products P
ON P.CategoryID = C.CategoryID

SELECT P.ProductName,
       C.CategoryName
FROM Products P
FULL JOIN Categories C
ON P.CategoryID = C.CategoryID

-- CROSS JOIN
SELECT P.ProductName, C.CategoryName
FROM Products P
CROSS JOIN Categories C

--------------------------

-- Her çalışanın amirini listeleyin.
-- Calisan | Amir

--Self Join Örneği
-- Tablonun kendisi ile joini
SELECT Calisan.FirstName + ' ' + Calisan.LastName AS Calisan,
       Amir.FirstName + ' ' + Amir.LastName AS Amir
FROM Employees Calisan
LEFT JOIN Employees Amir
 ON Calisan.ReportsTo = Amir.EmployeeID


 -- Beverages kategorisinden sipariş vermiş müşteriler kimler?

 SELECT DISTINCT C.CompanyName
 FROM Customers C
 JOIN Orders O ON C.CustomerID= O.CustomerID
 JOIN [Order Details] OD ON O.OrderID=OD.OrderID
 JOIN Products P ON OD.ProductID=P.ProductID
 JOIN Categories CAT ON P.CategoryID=CAT.CategoryID
 WHERE CAT.CategoryName='Beverages'

 --Hangi sipariş hangi müşteri tarafından verilmiş ve hangi çalışan ilgilenmiş?

 SELECT O.OrderID,
        C.CompanyName,
		E.FirstName + ' ' + E.LastName AS Employee
 FROM Orders O 
 JOIN Customers C ON O.CustomerID=C.CustomerID
 JOIN Employees E ON O.EmployeeID =E.EmployeeID