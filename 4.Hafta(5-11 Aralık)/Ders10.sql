/*	Ders 10	*/

--Sorgulama Teknikleri
--Pivot Tablo Oluşturma
--Raporlamada sık kullanılır

SELECT E.FirstName + ' '+ E.LastName AS Calisan,
       COUNT(O.OrderID)
FROM Employees E
JOIN Orders O 
ON E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName + ' '+ E.LastName

--------------------------------------------

SELECT *
FROM (SELECT E.FirstName + ' '+ E.LastName AS Calisan
      FROM Employees E
      JOIN Orders O
      ON E.EmployeeID = O.EmployeeID
	  --WHERE E.Firstname='Nancy'
	  ) G
PIVOT
(
  COUNT(Calisan)
  FOR Calisan IN([Nancy Davolio],[Andrew Fuller])
) AS pvt

-----------------------------------------------------

SELECT *
FROM Categories C
JOIN Products P
ON C.CategoryID = P.CategoryID
JOIN [Order Details] OD 
ON P.ProductID =OD.ProductID

-------------------------------------------------------

SELECT *
FROM (SELECT C.CategoryName,
            --OD.UnitPrice * OD.Quantity * (1-OD.Discount) AS SiparisTutari
			 dbo.FiyatHesapla(OD.Quantity,OD.UnitPrice,OD.Discount) AS SiparisTutari
     FROM Categories C
     JOIN Products P
     ON C.CategoryID = P.CategoryID
     JOIN [Order Details] OD 
     ON P.ProductID =OD.ProductID) CategorySales
PIVOT
(
  SUM(SiparisTutari)
  FOR CategoryName IN([Beverages],[Seafood])
) AS pvt

--DECLARE @pvtTable AS TABLE

-------------------------------------------------------------

/* GROUP BY CUBE İLE TOPLAM HESAPLAMA */

SELECT ISNULL(Country,'Toplam'),
       COUNT(CustomerID)
FROM Customers 
GROUP BY CUBE (Country)

/* GROUP BY ROLLUP İLE ARA TOPLAM HESAPLAMA */

SELECT ISNULL(Country,'Toplam'),
       ISNULL(City,'Ara Toplam'),
	   COUNT(*)
FROM Customers
GROUP BY ROLLUP (Country,City)

/*GROUPING SETS
Birden fazla alana göre gruplayarak union yapmaya gerek duyulmaz.
*/

-------------------------------------------------------

-- SIRALAMA FONKSİYONLARI (RANKING FUNCTIONS)

SELECT CustomerID,
       CompanyName,
	   Country,
	   ROW_NUMBER() OVER(PARTITION BY Country ORDER BY Country) AS SatirNo
FROM Customers

SELECT O.ShipCountry,
       O.OrderID,
	   ROW_NUMBER() OVER(PARTITION BY O.ShipCountry ORDER BY dbo.FiyatHesapla(OD.Quantity,OD.UnitPrice,OD.Discount) DESC) AS SatirNo
FROM Orders O
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID


SELECT *
FROM(SELECT O.ShipCountry,
       O.OrderID,
	   ROW_NUMBER() OVER(PARTITION BY O.ShipCountry ORDER BY dbo.FiyatHesapla(OD.Quantity,OD.UnitPrice,OD.Discount) DESC) AS SatirNo
    FROM Orders O
    JOIN [Order Details] OD
    ON O.OrderID = OD.OrderID) S
WHERE SatirNo=1

SELECT ShipCountry, OrderID
FROM
(SELECT *, ROW_NUMBER() OVER (PARTITION BY ShipCountry ORDER BY SiparisToplami DESC) AS SatirNo
FROM
(
 SELECT O.ShipCountry,
 O.OrderID,
      (SELECT SUM(dbo.FiyatHesapla(Quantity,UnitPrice,Discount))
      FROM [Order Details]
      WHERE OrderID = O.OrderID) AS SiparisToplami
      FROM Orders O) SiparisUlke ) B
WHERE B.SatirNo=1

----------------------------------------------------
SELECT RANK() OVER(PARTITION BY ProductID ORDER BY UnitPrice) AS SatirNo,
       UnitPrice,
	   ProductID
FROM [Order Details]

SELECT DENSE_RANK() OVER(PARTITION BY ProductID ORDER BY UnitPrice) AS SatirNo,
       UnitPrice,
	   ProductID
FROM [Order Details]

--------------------------------------------------------------

--TRIGGER

/* Bir olay gerçekleştiğinde onun yerine veya ondan sonra 
herhangi bir olayı tanımlamak için kullanılır.
*/

/* DDL TRIGGER
İkiye ayrılır.
Veri tabanı üzerinde çalışan DDL triggerlar
SQL Server üzerinde çalışan DDL triggerlar
*/

/* DML TRIGGER
Bir tablo üzerinde çalışabilecek triggerlardır.
INSERT, UPDATE, DELETE için geçerli olan triggerlar yazabiliyoruz.
En çok karşımızda DML triggerlar çıkıyor.
İkiye ayrılır.
İşlem gerçekleştikten sonra:
AFTER(FOR) - INSTEAD OF

Performans ile ilgili konularda sistemdeki trigger yapılarını incelemek gerekebilir.
*/

CREATE TRIGGER DeleteCustomers
ON Customers
AFTER DELETE
AS
BEGIN
   INSERT INTO CustomerLog
   VALUES('XXXXX', GETDATE())
END

DELETE FROM Customers
WHERE CustomerID='TECHC'

TRUNCATE TABLE CustomerLog


ALTER TRIGGER DeleteCustomers
ON Customers
AFTER DELETE
AS
BEGIN
   --DECLARE @custID AS NCHAR(5)
   --DECLARE @name AS VARCHAR(50)

   --SELECT @custID = CustomerID,
   --       @name = CompanyName
   --FROM deleted

   SELECT CustomerID,
          CompanyName
   FROM deleted

   --INSERT INTO CustomerLog
   --VALUES (@custID,@name,GETDATE(),SUSER_NAME())

END

SELECT SUSER_ID()
SELECT SUSER_SID()
SELECT SUSER_NAME()
SELECT SUSER_SNAME()

DELETE FROM Customers
WHERE CustomerID='TECHC'

DISABLE TRIGGER DeleteCustomers 
ON Customers
DELETE FROM Customers WHERE CustomerID ='ABCDE'
ENABLE TRIGGER DeleteCustomers
ON Customers

----------------------------------------------

CREATE TRIGGER StokGuncelle
ON [Order Details]
AFTER INSERT
AS
BEGIN
    DECLARE @productID AS INT
	DECLARE @quantity AS SMALLINT

	SELECT @productID = ProductID,
	       @quantity = Quantity
	FROM inserted

	UPDATE Products
	SET UnitsInStock -= @quantity
	WHERE ProductID = @productID
END

INSERT INTO [Order Details]
VALUES (10248,1,20,4,0)


-------------------------------

-- INSTEAD OF

-- O anki işlemin yerine yapılırlar.

CREATE TRIGGER Guncelle
ON Shippers
INSTEAD OF UPDATE
AS
BEGIN
    IF SUSER_NAME() != 'LAPTOP-O704J5QN\lenovo'
	BEGIN
       DECLARE @oldName AS NVARCHAR(40)
	   DECLARE @newName AS NVARCHAR(40)

	   SELECT @newName = CompanyName 
	   FROM inserted

	   SELECT @oldName = CompanyName 
	   FROM deleted

	   IF @newName != @oldName
	   BEGIN
	     PRINT 'Şirket adını güncelleme yetkiniz yok'
	   END
	   ELSE
	   BEGIN
	     DECLARE @phone AS NVARCHAR(24)
		 DECLARE @shipperID AS INT

		 SET @shipperID = (SELECT ShipperID FROM deleted)
		 SET @phone = (SELECT Phone FROM inserted)

		 UPDATE Shippers
		 SET Phone = @phone
		 WHERE ShipperID = @shipperID
	   END
	END
END

ALTER TRIGGER Guncelle
ON Shippers
INSTEAD OF UPDATE
AS
BEGIN
    IF SUSER_NAME() != 'XXXX'
	BEGIN
       DECLARE @oldName AS NVARCHAR(40)
	   DECLARE @newName AS NVARCHAR(40)

	   SELECT @newName = CompanyName 
	   FROM inserted

	   SELECT @oldName = CompanyName 
	   FROM deleted

	   IF @newName != @oldName
	   BEGIN
	     PRINT 'Şirket adını güncelleme yetkiniz yok'
	   END
	   ELSE
	   BEGIN
	     DECLARE @phone AS NVARCHAR(24)
		 DECLARE @shipperID AS INT

		 SET @shipperID = (SELECT ShipperID FROM deleted)
		 SET @phone = (SELECT Phone FROM inserted)

		 UPDATE Shippers
		 SET Phone = @phone
		 WHERE ShipperID = @shipperID
	   END
	END
END

UPDATE Shippers
SET CompanyName = 'Techcareer'
WHERE ShipperID = 1

UPDATE Shippers
SET Phone = '123456'
WHERE ShipperID = 1

CREATE TRIGGER UrunPasiflestir
ON Products
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @productID AS INT = (SELECT ProductID FROM deleted)

	UPDATE Products
	SET Discontinued=1
	WHERE ProductID = @productID
END

DELETE FROM Products
WHERE ProductID = 77

















