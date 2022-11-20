-- Yorum satırı ctrl + k + c

-- SQL (Structured Query Language)

-- DDL Data Definition Language
-- DDL Data Manipulation Language (CRUD - Create, Read, Update, Delete)
-- DCL Data Control Language

-- ctrl + r

SELECT 5
SELECT 'Akın' AS 'Egitmen'
SELECT 'Akın' AS Egitmen
--SELECT 'Akın' Egitmen

SELECT 'Akın' AS [Egitmen Adı]

SELECT 10+10

SELECT 'Akın' + ' ' + 'Karabulut'

SELECT 'Akın' AS Ad, 'Karabulut' AS Soyad

PRINT 'Sorgu Tamamlandı'

---------------------------------------------

SELECT CategoryName
FROM Categories

SELECT CategoryID, CategoryName 
FROM Categories

SELECT *
FROM Categories

--Çalışanlarıma hitaben mektup yazacağım. Sayın Marty McFly şeklinde sonuç.

SELECT 'Sayın' + ' ' + FirstName + ' ' + LastName AS MektupBasligi
FROM Employees 

SELECT *
FROM Employees

-- WHERE
-- =, !=, <>,
SELECT *
FROM Products
WHERE ProductName ='Chai'

SELECT *
FROM Products
WHERE ProductName != 'Chai' 

SELECT *
FROM Products
WHERE ProductName <> 'Chai' 

SELECT ProductName
FROM Products
WHERE UnitPrice != 10

-- <=, <, >=, >, !<, !>

SELECT *
FROM Products
WHERE UnitsInStock > 50

-- Kanada'da yaşayan müşterileri listeleyin. CompanyName | Country

SELECT CompanyName, Country
FROM Customers
WHERE Country='Canada'

-- Bugün verilen siparişleri listeleyin.

SELECT *
FROM Orders
WHERE OrderDate=GETDATE()   --'2022-11-16'

-------------------------------------------------

-- AND - OR
-- Fiyatı 20 ile 50 arasında olan ürünler
SELECT *
FROM Products
WHERE UnitPrice>=20 AND
      UnitPrice<=50

-- Adı Chai veya Chang olanlar
SELECT *
FROM Products
WHERE ProductName ='Chai' OR
      ProductName ='Chang'

SELECT *
FROM Products
WHERE UnitPrice BETWEEN 50 AND 100

-- LIKE

SELECT *
FROM Products
WHERE ProductName LIKE 'A%'

SELECT *
FROM Products
WHERE ProductName LIKE '%A'

SELECT *
FROM Products
WHERE ProductName LIKE '%A%'

