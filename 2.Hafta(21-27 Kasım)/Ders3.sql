-----------------

-- CategoryID'si 1 veya 2 olup da 10'dan küçük stoğu olan

SELECT ProductName,
       CategoryID,
	   UnitsInStock
FROM Products
WHERE (CategoryID=1 OR CategoryID=2)
      AND UnitsInStock<10

------------------------

--Alias (Takma Ad) kullanımı

SELECT CompanyName 
AS MusteriAdi
FROM Customers

SELECT Customers.CompanyName,
       Customers.Address
FROM Customers

SELECT C.Country,
       C.City
FROM Customers C

---------------------

SELECT *
FROM Orders
WHERE OrderDate < '1997-01-01'

SELECT ShipCity + ' / ' +ShipCountry
FROM Orders

-----------------------

SELECT *
FROM Products

-- İlk 5 kaydın tüm bilgileri gelsin
SELECT TOP 5 *
FROM Products

--Satışı devam eden ilk 10 ürün'ün tüm bilgileri gelsin
SELECT TOP 10 *
FROM Products
WHERE Discontinued = 0

--Fransa'da yaşayan ilk 3 müşterimizin firma adı ve ülke bilgisi gelsin
SELECT TOP 3 CompanyName,Country
FROM Customers
WHERE Country ='France'

--Müşterilerimizin yüzde 50'si gelsin
SELECT TOP 50 PERCENT*
FROM Customers

-- Order By
-- Sıralama için kullanılır
-- Artan Sıralama
-- Azalan Sıralama


--Artan (Default değeri)
SELECT *
FROM Products
ORDER BY UnitPrice ASC 

--Azalan
SELECT *
FROM Products
ORDER BY UnitPrice DESC 

--Birden fazla kolona göre
SELECT *
FROM Customers
ORDER BY Country DESC,City DESC

--ContactName kolonuna göre sıralama
SELECT *
FROM Customers
ORDER BY 3 DESC 

-- Address kolonuna göre sıralama
SELECT Country,
       CompanyName,
	   Address
FROM Customers
ORDER BY 3 DESC 

-- ORDER BY WHERE komutundan sonra çalıştırılır
SELECT *
FROM Customers
WHERE Country ='Brazil'
ORDER BY City DESC

--Karışık Sıralama
SELECT *,
    City + ' / ' + Country 
FROM Customers

SELECT *
FROM Products
ORDER BY NEWID()

--En çok stoğu olan ürün
SELECT TOP 1 * 
FROM Products
ORDER BY UnitsInStock DESC

-- Çalışanlarım içerisinden en son işe giren kimdir
SELECT TOP 1 FirstName + ' ' + LastName AS Calisan
FROM Employees
ORDER BY HireDate DESC

--Geciken siparişleri günümüzden geçmişe doğru sıralayın
SELECT *
FROM Orders
WHERE ShippedDate > RequiredDate
ORDER BY OrderDate DESC

--Alias'a bağlı Order By ile sıralama
SELECT BirthDate,
       Title,
	   FirstName + ' ' + LastName AS Calisan
FROM Employees
ORDER BY Calisan DESC












