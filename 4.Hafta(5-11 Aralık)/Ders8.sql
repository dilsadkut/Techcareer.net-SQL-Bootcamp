-- View 

--Sorgu yazarken işimizi kolaylaştıran bir database objesidir.
--Sadece görünüm olarak görünür, herhangi bir şekilde datayı saklamaz.
--View'ler tablolar gibi sorgulanabilir, join-group by gibi komutlarla da kullanılabilir.

--View üzerinde CUD işlemleri

CREATE VIEW vw_Products
AS
SELECT 
ProductName,
UnitPrice,
UnitsInStock
FROM Products

SELECT *
FROM vw_Products

INSERT INTO vw_Products
VALUES ('Laptop',234,12)

SELECT *
FROM vw_Products

DELETE FROM vw_Products 
WHERE ProductName='Laptop' --View içerisinde ProductID alanı olmadığı için hata verir. ProductName olarak silme işlemi yaptık.

SELECT *
FROM vw_Products

----------------------

SELECT *
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('vw_Products')

SELECT OBJECT_ID('vw_Products')

SELECT OBJECT_DEFINITION(OBJECT_ID('Invoices'))


SELECT * FROM sys.tables
WHERE object_id = OBJECT_ID('Customers')

--View şifreleme

CREATE VIEW vw_LondradaYasayanlar
WITH ENCRYPTION
AS
SELECT *
FROM Employees
WHERE City = 'London'

SELECT *
FROM vw_LondradaYasayanlar

SELECT *
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('vw_LondradaYasayanlar')

ALTER VIEW vw_LondradaYasayanlar
AS
SELECT *
FROM Employees
WHERE City='London'

---------------------------------------

/* VIEW SCHEMA BINDING */

CREATE VIEW vw_Kategoriler
WITH SCHEMABINDING 
AS
SELECT CategoryID,CategoryName
FROM dbo.Categories


CREATE VIEW vw_Kargocular
WITH SCHEMABINDING
AS
SELECT ShipperID,CompanyName
FROM dbo.Shippers

/* 
DCL
ALTER LOGIN sa
DENY Suppliers
GRANT vw_Kargocular */

----------------------------------

/* Stored Procedure 
   (Saklı Yordamlar)
*/

-- Yazdığımız sorgular belirli aşamalardan geçer.
-- View oluştururken sadece select için kullanılır.
-- Stored procedure içinde insert update delete gibi sorgular da yazılabilir.
-- AD-HOC Query : Her defasında aynı adımlardan geçen sorgu

-- AD-HOC SQL Sorguların Aşamaları:

-- 1. PARSE: Yazdığımız sorguların syntax'a uygulaması
-- 2. RESOLVE: Yazılan sorgudaki tablo isimleri vs. gerçekten veri tabanında var mı?
-- 3. OPTIMIZE: Sorguların çalışabilmesi için optimize yollar bulunur.
-- 4. COMPILE: SQL sorgusunun derlenmesi (SQL yorumlanan bir script dili)
     --Execution Plan
-- 5. EXECUTE Sorgunun execute edilmesi
-- 6. RESULT Sonuç

--------------------------------------

CREATE PROC sp_GetProducts
AS
BEGIN
   SELECT *
   FROM Products
END

--EXECUTE sp_GetProducts
EXEC sp_GetProducts
--sp_GetProducts

-- ALTER Procedure Güncelleme
-- DROP Procedure Silme

ALTER PROC sp_GetProducts
AS
SET NOCOUNT ON
BEGIN
   SELECT *
   FROM Products
END

EXEC sp_GetProducts

DROP PROC sp_GetProducts

----------------------------------------

/* Parametre Kullanımı */

-- Şehir bilgisini parametre olarak alıp o şehirdeki müşteri listeleyen sp

CREATE PROC sp_GetCustomersByCity
(
	@city AS NVARCHAR(50)
)
AS
BEGIN
	SELECT * FROM Customers WHERE City = @city
END

EXEC sp_GetCustomersByCity @city='México D.F.'
EXEC sp_GetCustomersByCity 'Berlin'

-- Employee tablosuna kayıt atan sp

CREATE PROC sp_AddEmployee
(
	@firstName AS NVARCHAR(10),
	@lastName AS NVARCHAR(20)
)
AS
BEGIN
	INSERT INTO Employees(FirstName,LastName)
	VALUES(@firstName,@lastName)
END

EXEC sp_AddEmployee 'Marty','McFly'
EXEC sp_AddEmployee @lastName='Ipkiss', @firstName='Stanley'

------------------------------------------------------------
-- Kategori adını parametre olarak alıp ona göre ürünleri filtreleyip getiren sp
CREATE PROC sp_GetProductsByCategory
(
	@catName AS NVARCHAR(15) = NULL
)
AS
BEGIN
	--IF @catName IS NULL
	--BEGIN
	--	SELECT p.ProductName
	--	FROM Products p
	--	JOIN Categories c ON p.CategoryID = c.CategoryID
	--END
	--ELSE
	--BEGIN
	--	SELECT p.ProductName
	--	FROM Products p
	--	JOIN Categories c ON p.CategoryID = c.CategoryID
	--	WHERE c.CategoryName = @catName
	--END

		SELECT p.ProductName
		FROM Products p
		JOIN Categories c ON p.CategoryID = c.CategoryID
		WHERE c.CategoryName = ISNULL(@catName,c.CategoryName)
END

EXEC sp_GetProductsByCategory
EXEC sp_GetProductsByCategory 'Seafood'


---------------------------------------------------------------------
-- OUTPUT PARAMETER

-- Kategori adını alıp ürün sayısını ve o kategorinin ürünlerini dönen sp
CREATE PROC sp_Urunler
(
	@kategori AS NVARCHAR(15),
	@adet AS INT OUT
)
AS
BEGIN
	SELECT p.ProductName
	FROM Products p
	JOIN Categories c ON p.CategoryID = c.CategoryID
	WHERE c.CategoryName LIKE (@kategori + '%')

	SET @adet = @@ROWCOUNT
END

DECLARE @urunSayisi AS INT
EXEC sp_Urunler 'C', @urunSayisi OUT
PRINT 'Ürün Sayısı : ' + CAST(@urunSayisi AS VARCHAR(3))

-- Ürün nosunu, zam mı indirim mi bilgisini ve oranı parametre alan ve buna göre ürün fiyatını güncelleyen sp.

CREATE PROC sp_UrunFiyatGuncelle
(
	@urunID AS INT,
	@oran AS INT,
	@zamMi AS BIT
)
AS
BEGIN
	DECLARE @guncellemeMiktari AS DECIMAL
	DECLARE @fiyat AS DECIMAL

	SET @fiyat = (SELECT UnitPrice FROM Products WHERE ProductID = @urunID)
	
	IF @zamMi = 0 -- false yani zam değil
	BEGIN
		SET @guncellemeMiktari = @fiyat * @oran / 100 * -1
	END
	ELSE
	BEGIN
		SET @guncellemeMiktari = @fiyat * @oran / 100
	END


	UPDATE Products SET UnitPrice += @guncellemeMiktari WHERE ProductID = @urunID
END

EXEC sp_UrunFiyatGuncelle @urunID=1, @oran=50, @zamMi=1
EXEC sp_UrunFiyatGuncelle @urunID=1, @oran=25, @zamMi=0

-- Dynamic SQL
EXEC('SELECT * FROM Products')

DECLARE @table AS NVARCHAR(50)
SET @table='Categories'

EXEC('SELECT * FROM ' + @table)

CREATE PROC sp_VeriGetir
(
	@tableName AS NVARCHAR(50)
)
AS
BEGIN
	EXEC('SELECT * FROM ' + @tableName)
END

EXEC sp_VeriGetir 'Products'
EXEC sp_VeriGetir 'Customers'

ALTER PROC sp_UrunleriGetir
(
	@kategoriID AS INT = NULL
)
AS
BEGIN
	DECLARE @query AS NVARCHAR(100)
	SET @query = 'SELECT * FROM Products'

	IF @kategoriID IS NOT NULL
	BEGIN
		SET @query += ' WHERE CategoryID =' + CAST(@kategoriID AS NVARCHAR(2))
	END

	EXEC(@query)
END

EXEC sp_UrunleriGetir 2
