--Built in Functions
--Metinsel

SELECT LOWER('GRAHAM BELL')
SELECT UPPER('techcareer')
SELECT REVERSE('akin')

SELECT '	graham bell'

SELECT LTRIM ('  	graham bell')
SELECT RTRIM ('graham bell		')

SELECT LEN('  graham bell			') -- baştaki boşlukları sayar, sondakileri saymaz
SELECT LEN(RTRIM('graham bell	'))	
SELECT LEN(LTRIM('		graham bell		'))	

SELECT DATALENGTH('graham bell	')
SELECT DATALENGTH(12345) --verinin ne kadar yer kapladığı int için 4 bayt
--SELECT DATALENGTH('Akın') NVARCHAR'lı bakılacak daha sonra

--Karakterlere erişim
SELECT LEFT('bell',1)
SELECT LEFT('bell',2)
SELECT LEFT('bell',10)

SELECT RIGHT('bell',2)

--Ülkesinin son harfi y olan müşteriler

SELECT *
FROM Customers
WHERE RIGHT(Country,1)='y'

--Metinsel ifadelerin parçalanması

SELECT SUBSTRING('graham bell',4,6)

-- Verilen ifadenin sırası
SELECT CHARINDEX('R','GRAHAM BELL')
SELECT CHARINDEX('a','graham bell')
SELECT CHARINDEX('a','graham bell',4)

--Bir metni başka bir metin ile değiştirme
SELECT REPLACE('Ankara', 'A', 'e')
SELECT REPLACE('Ankara', 'An', 'el')

--Verilen metni tekrar etme
SELECT REPLICATE('a',15)

--Metin içerisinde belli bir konuma bağlı karakterleri değiştirme
SELECT STUFF('Ankara',2,2,'aa')
SELECT STUFF('Ankara',2,2,'aaaaaaaaaaaa')
SELECT STUFF('Ankara',2,2,'a')

---------------------------

SELECT FirstName, 
       LastName, 
       ISNULL(Region,'Bölgesi Yok')
FROM Employees

SELECT CompanyName,
       COALESCE(Fax,Region,'Veri Yok')
FROM Customers

------------------------

--Aggregate Functions
SELECT MAX(UnitPrice)
FROM Products

SELECT MIN(UnitPrice)
FROM Products

SELECT SUM(UnitsInStock)
FROM Products

SELECT AVG(UnitPrice)
FROM Products

--Tüm Kayıtlar
SELECT COUNT(*)
FROM Products

-- NULL harici region alanı kayıt sayısı
SELECT COUNT(Region)
FROM Employees

SELECT COUNT(Country)
FROM Customers

SELECT DISTINCT Country
FROM Customers

SELECT COUNT(DISTINCT Country)
FROM Customers

--MATH FUNCTIONS

SELECT ROUND(123.4567,2)
SELECT ROUND(123.4517,2)
SELECT ROUND(123.4567,2,1)

SELECT CEILING(123.15)
SELECT FLOOR(123.87)

SELECT POWER(2,3)
SELECT SQRT(25)

SELECT POWER(0,0)

SELECT PI()

----------------------

--CONVERT FUNCTIONS

SELECT CAST('10' AS TINYINT)
SELECT CAST('xyx' AS BIGINT)

SELECT CONVERT(INTEGER,'10')
SELECT CONVERT(DATETIME,'20221127')
SELECT CONVERT(DATETIME,'20221127 14:21',100)

---------------------------

-- Tarihsel Fonksiyonlar

--Şu anki tarih
SELECT GETDATE()
SELECT GETUTCDATE()
SELECT SYSDATETIME() --hassasiyet farkı var
SELECT CURRENT_TIMESTAMP


SELECT DATEADD(YEAR,10,GETDATE())
SELECT DATEADD(WEEK,3,GETDATE())
SELECT DATEADD(DAY,-3,GETDATE())

SELECT DATENAME(MONTH,GETDATE())
SELECT DATENAME(DAY,GETDATE())
SELECT DATENAME(WEEKDAY,GETDATE())

SELECT DATEPART(QUARTER,GETDATE())
SELECT DATEPART(DAYOFYEAR,GETDATE())

SELECT DATEDIFF(WEEK,GETDATE(),'2025-02-23')
SELECT DATEDIFF(MONTH,GETDATE(),DATEADD(YEAR,-2,GETDATE()))

SELECT DATEPART(YEAR,GETDATE())
SELECT YEAR(GETDATE())
SELECT MONTH(GETDATE())
SELECT DAY(GETDATE())

SELECT DATEPART(MM,'2022-06-26')

-- Çarşamba günü alınan siparişler

SELECT *
FROM Orders
WHERE DATENAME(WEEKDAY,OrderDate)='Wednesday'

--Çalışanlar hangi gün doğmuştur

SELECT FirstName, 
       LastName, 
       DATENAME(WEEKDAY,BirthDate) AS Gun
FROM Employees

--Her ayın 15'inde sevk edilen siparişlerden en yüksek kargo ücreti olan sipariş

SELECT TOP 1 OrderID,
       ShippedDate,
	   Freight
FROM Orders
WHERE DAY(ShippedDate)= 15
ORDER BY Freight DESC

-------------------

--IIF
--CASE WHEN
--Simple Case When

SELECT FirstName,
       LastName,
       Gender=CASE TitleofCourtesy
	   WHEN 'Mr.' THEN 'Erkek'
	   WHEN 'Ms.' THEN 'Kadın'
	   WHEN 'Mrs.' THEN 'Kadın'
	   ELSE 'Bilinmiyor'
	   END 
FROM Employees

SELECT CustomerID,
       CompanyName,
	   Country = CASE Country
	   WHEN 'USA' THEN 'America'
	   WHEN 'UK' THEN 'England'
	   ELSE Country
	   END
FROM Customers

-- Searched Case When

SELECT ProductName,
       UnitPrice,
	   CASE
	   WHEN UnitPrice < 20 THEN 'Ucuz'
	   WHEN UnitPrice < 50 THEN 'Normal'
	   WHEN UnitPrice < 100 THEN 'Pahalı'
	   END AS FiyatBilgisi
FROM Products

-- Çalışanlarımdan 60 yaşından küçüklere 'Genç' 60-75 arası 'Orta yaşlı' diğerlerş de 'Yaşlı'
SELECT FirstName + ' ' + LastName AS Calisan,
       DATEDIFF(YEAR,BirthDate,GETDATE()) AS Yas,
	   CASE 
	   WHEN (YEAR(GETDATE()) - YEAR(BirthDate))<60 THEN 'Genç'
	   WHEN (YEAR(GETDATE()) - YEAR(BirthDate))<75 THEN 'Orta Yaşlı'
	   ELSE 'Yaşlı'
	   END AS Bilgi
FROM Employees




