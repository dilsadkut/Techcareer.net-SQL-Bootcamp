

SELECT *
FROM Products
WHERE ProductName LIKE 'Chai'

SELECT *
FROM Products
WHERE ProductName LIKE '%g%' OR
      ProductName LIKE '%f%'

--WILDCARDS

--6 karakter br ile başlayan
SELECT *
FROM Customers 
WHERE Country LIKE 'BR____'

SELECT *
FROM Customers 
WHERE Country LIKE 'B_____' 

--B ile başlayan en az 6 karakter devamı ne olursa

SELECT *
FROM Customers
WHERE Country LIKE 'B_____%'

--2.harfi A olan ürünler
SELECT *
FROM Products
WHERE ProductName LIKE '_a%'

--Müşteri adı a veya f ile başlayanlar
SELECT *
FROM Customers
WHERE CompanyName LIKE '[AF]%'

--A ile F arasındaki harfler ile başlayanlar A ile F dahil
SELECT *
FROM Customers
WHERE CompanyName LIKE '[A-F]%'

-- 3.harfi a veya c olan ve en az 5 harfli ürünler
SELECT *
FROM Products
WHERE ProductName LIKE '__[AC]__%'

------

-- A ile başlamayanlar
SELECT *
FROM Products
WHERE ProductName LIKE '[^a]%'

--A ile başlamayanlar
SELECT *
FROM Products
WHERE ProductName NOT LIKE 'A%'

SELECT *
FROM Customers
WHERE Country ='GERMANY'

--SELECT *
--FROM Customers
--WHERE Country IS 'GERMANY'

SELECT *
FROM Employees
WHERE Region is null

SELECT *
FROM Employees
WHERE Region is not null

-- 3.harfi a ile d arasındaki harfli olmayan en az 4 harfli müşteriler
SELECT *
FROM Customers
WHERE CompanyName LIKE '__[^A-D]_%'

-- Sayısal değerlerle kullanımı

SELECT *
FROM Products
WHERE UnitsInStock LIKE '%_0'

------------------------

SELECT *
FROM Customers
WHERE Country='Brazil' OR Country='Germany' OR Country ='Italy'


SELECT *
FROM Customers
WHERE Country IN ('Brazil','Germany','Italy')

-- Birden fazla kelimeden oluşan ismi olan ürünleri listeleyin.

SELECT *
FROM Products
WHERE ProductName LIKE '% %'

-- Şişede sattığım ürünleri listeleyin
SELECT *
FROM Products
WHERE QuantityPerUnit LIKE '%bottles%'

-- Hangi çalışanlar almanca biliyorlar?
SELECT *
FROM Employees
WHERE Notes lIKE '%German%'
-- Birebir firma sahibi ile iletişime geçtiğimiz tedarikçileri listeleyin.
SELECT *
FROM Suppliers
WHERE ContactTitle='Owner'

-- Patron kim?
SELECT *
FROM Employees
WHERE ReportsTo IS NULL
