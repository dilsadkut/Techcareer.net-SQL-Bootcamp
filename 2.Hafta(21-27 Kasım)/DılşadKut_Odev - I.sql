/*
  Dılşad Kut                                      
  Techcareer.net MS SQL Bootcamp 2.hafta Ödevi
  26.11.2022 Cumartesi
*/

-- Ülkesi A harfi ile bitmeyen müşterileri listeleyin.

SELECT *
FROM Customers 
WHERE Country NOT LIKE '%A'

/* Ürün adlarını ve fiyatlarını, 
her birine %18 olarak uygulanmak üzere 
KDV bilgisiyle beraber listeleyin. 
KDV bilgisi ayrı bir sütun olarak gelmeli. 
UrunAdi | UrunFiyati | KDVliFiyat | KDV */

SELECT ProductName AS UrunAdi, 
       UnitPrice AS UrunFiyati,
	   UnitPrice+UnitPrice*18/100 AS KDVliFiyat,
	   (UnitPrice*18/100)/UnitPrice AS KDV   
FROM Products

/* Yaşadığı şehir London ve Seattle olmayan çalışanlarımız kimlerdir?
FullName | City */ 

SELECT FirstName + ' ' + LastName AS FullName,
       City
FROM Employees
WHERE City != 'London' AND City != 'Seattle'

/* Stok miktarı kritik seviyeye veya altına düşmesine rağmen 
hala siparişini vermediğim ürünler hangileridir? ProductName */

SELECT ProductName
FROM Products
WHERE UnitsInStock<=10 AND Discontinued=1

-- Fiyatı küsüratlı ürünleri listeleyin.

SELECT *
FROM Products
WHERE UnitPrice LIKE '%.%'

-- Amerika'ya teslimatı geciken siparişler hangileridir?

SELECT *
FROM Orders
WHERE RequiredDate>ShippedDate AND ShipCountry='USA'

-- Son gününde teslim edilen siparişler hangileridir?

SELECT *
FROM Orders
WHERE RequiredDate = ShippedDate

-- En yüksek kargo ücreti ödenmiş 5 sipariş hangi ülkelere gönderilmiş?

SELECT TOP 5 *
FROM Orders
ORDER BY Freight DESC

-- Bu zamana kadar sattığım en ucuz üründen, o ucuz fiyata kaç tane satmışım?

SELECT TOP 1 QuantityPerUnit 
FROM Products
ORDER BY UnitPrice ASC   
        
-- Artık satışta olmayan en pahalı ürünüm hangisidir?

SELECT TOP 1 *
FROM Products
WHERE Discontinued=1
ORDER BY UnitPrice DESC

-- Japonya ve İtalya'daki tedarikcileri listeleyin. TedarikciAdi | Ulke

SELECT ContactName AS TedarikciAdi,
       Country AS Ulke
FROM Suppliers
WHERE Country IN ('Japan','Italy')

-- Son teslim edilen 10 siparişi gösterin.

SELECT TOP 10 *
FROM Orders
ORDER BY ShippedDate DESC

-- En genç 3 çalışanı listeleyin.

SELECT TOP 3*
FROM Employees
ORDER BY BirthDate DESC