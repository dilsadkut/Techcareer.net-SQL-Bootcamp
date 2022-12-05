-- SubQuery Örnek Uygulamalar

-- Amerika'da yaşayan çalışanların ilgilendiği siparişler
SELECT *
FROM Orders
WHERE EmployeeID IN(SELECT EmployeeID
                    FROM Employees
					WHERE Country = 'USA')

-- Siparişlerin nosu, ilgilenen çalışan ve sipariş tutarı
SELECT OrderID,
       (SELECT FirstName + ' ' + LastName
	    FROM Employees
	    WHERE EmployeeID = o.EmployeeID) AS Calisan,
	   (SELECT SUM(UnitPrice * Quantity * (1 - Discount))
	    FROM [Order Details]
		WHERE OrderID = o.OrderID) AS Tutar
FROM Orders o

SELECT od.OrderID,
       UnitPrice * Quantity * (1 - Discount) AS Tutar,
	   (SELECT FirstName + ' ' + LastName
	    FROM Employees
		WHERE EmployeeID IN(SELECT EmployeeID
		                    FROM Orders
							WHERE OrderID = od.OrderID)
	   ) AS Calisan
FROM [Order Details] od

SELECT od.OrderID,
       SUM(UnitPrice * Quantity * (1 - Discount)) AS Tutar,
	   (SELECT FirstName + ' ' + LastName
	    FROM Employees
		WHERE EmployeeID IN(SELECT EmployeeID
		                    FROM Orders
							WHERE OrderID = od.OrderID)
	   ) AS Calisan
FROM [Order Details] od
GROUP BY od.OrderID

-- 'Romero y Tomillo' müşteriye gönderilen ürünler?
SELECT ProductName
FROM Products
WHERE ProductID IN(SELECT ProductID
                   FROM [Order Details]
				   WHERE OrderID IN(SELECT OrderID
				                    FROM Orders
									WHERE CustomerID IN(SELECT CustomerID
									                    FROM Customers
														WHERE CompanyName ='Romero y Tomillo'
									                    )
								   )
				   )

-- Brezilya ülkesindeki müşterilerden gelen siparişler içerisinde en yüksek tutarlı siparişin tutarı
SELECT MAX(UnitPrice * Quantity * (1 - Discount))
FROM [Order Details]
WHERE OrderID IN(SELECT OrderID
                 FROM Orders
				 WHERE CustomerID IN(SELECT CustomerID
				                     FROM Customers
									 WHERE Country = 'Brazil'
									 )
				 )

-- Hangi ülkelere hangi siparişler en geç teslim edilmiştir?
SELECT ShipCountry,
       OrderID
FROM Orders o
WHERE DATEDIFF(DAY,RequiredDate,ShippedDate) = (SELECT MAX(DATEDIFF(DAY,RequiredDate,ShippedDate))
												FROM Orders
												WHERE RequiredDate < ShippedDate
												GROUP BY ShipCountry
												HAVING ShipCountry = o.ShipCountry)


--Hangi müşterilerden 20000'den fazla kazanılmıştır?
SELECT --SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Kazanc,
       c.CompanyName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
HAVING SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) > 20000


SELECT Musteri,
       c.City
FROM (SELECT SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Kazanc,
			 c.CompanyName AS Musteri,
			 c.CustomerID AS MusteriKodu
	  FROM Customers c
	  JOIN Orders o ON c.CustomerID = o.CustomerID
	  JOIN [Order Details] od ON o.OrderID = od.OrderID
	  GROUP BY c.CompanyName, c.CustomerID) AS MusteriKazanc
JOIN Customers c ON c.CustomerID = MusteriKazanc.MusteriKodu
WHERE MusteriKazanc.Kazanc > 20000

-- Her yılın en çok sipariş veren müşterisi kimdir?
SELECT *
FROM (SELECT YEAR(o.OrderDate) AS Yil,
			 c.CompanyName AS Musteri,
			 COUNT(o.OrderID) AS SiparisSayisi
	  FROM Customers c
	  JOIN Orders o ON c.CustomerID = o.CustomerID
	  GROUP BY YEAR(o.OrderDate),
			   c.CompanyName) AS MusteriSiparisMain
WHERE SiparisSayisi = (SELECT MAX(MusteriSiparisSub.SiparisSayisi)
					   FROM (SELECT YEAR(o.OrderDate) AS Yil,
									c.CompanyName AS Musteri,
									COUNT(o.OrderID) AS SiparisSayisi
							 FROM Customers c
							 JOIN Orders o ON c.CustomerID = o.CustomerID
							 GROUP BY YEAR(o.OrderDate),
									  c.CompanyName) AS MusteriSiparisSub
					   WHERE Yil = MusteriSiparisMain.Yil
					   GROUP BY MusteriSiparisSub.Yil
					   --HAVING MusteriSiparisSub.Yil = MusteriSiparisMain.Yil
					   )


-------------------------------------

--Hangi kargo firması hangi ürünü en çok taşımıştır?
--Çalışanlar yaptıkları en yüksek satışları hangi tarihte yapmışlardır?


------------------

-- UNION / UNION ALL

SELECT ProductName
FROM Products
UNION
SELECT CategoryName
FROM Categories


--Kolon sayılarının eşleşmesi lazım
SELECT *
FROM Customers
UNION
SELECT *
FROM Employees


SELECT City
FROM Customers
UNION
SELECT City
FROM Employees

SELECT City
FROM Customers
UNION ALL
SELECT City
FROM Employees

-------------------------------------------

-- VIEWS

--Tablo oluşturuyoruz, sorguladıkça data alabiliyoruz.
--Fakat ya sürekli aynı sorguları tekrar ediyorsak?
--View'ler data saklamaz. Sadece data gösterir.

SELECT ProductName, UnitPrice, UnitsInStock
FROM Products

--SELECT *
--FROM ViewName

SELECT *
FROM INFORMATION_SCHEMA.TABLES

SELECT *
FROM Invoices

SELECT *
FROM [Quarterly Orders]

SELECT *
FROM [Summary of Sales by Quarter]

---------------------------------------

-- 1997 yılında çalışanların müşteri bazında sipariş sayıları

SELECT E.FirstName + ' ' + E.LastName AS Calisan,
       C.CompanyName AS Musteri,
	   COUNT(O.OrderID) AS MusteriSayisi
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
JOIN Employees E
ON O.EmployeeID = E.EmployeeID
WHERE YEAR(O.OrderDate) =1997
GROUP BY C.CompanyName, E.FirstName,E.LastName


--Yeni View Oluşturma
CREATE VIEW vw_1997Siparisleri
AS
SELECT E.FirstName + ' ' + E.LastName AS Calisan,
       C.CompanyName AS Musteri,
	   COUNT(O.OrderID) AS MusteriSayisi
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
JOIN Employees E
ON O.EmployeeID = E.EmployeeID
WHERE YEAR(O.OrderDate) =1997
GROUP BY C.CompanyName, E.FirstName,E.LastName

SELECT *
FROM vw_1997Siparisleri
WHERE Calisan = 'Nancy Davolio'

SELECT Calisan, SUM(MusteriSayisi)
FROM vw_1997Siparisleri
GROUP BY Calisan

--View güncelleme

ALTER VIEW vw_1997Siparisleri
AS
SELECT E.FirstName + ' ' + E.LastName AS Calisan,
       C.CompanyName AS Musteri,
	   COUNT(O.OrderID) AS MusteriSayisi
FROM Customers C
JOIN Orders O
ON C.CustomerID = O.CustomerID
JOIN Employees E
ON O.EmployeeID = E.EmployeeID
GROUP BY C.CompanyName, E.FirstName,E.LastName

SELECT *
FROM vw_1997Siparisleri

SELECT Calisan, SUM(MusteriSayisi)
FROM vw_1997Siparisleri
GROUP BY Calisan

--View silme

DROP VIEW vw_1997Siparisleri

SELECT *
FROM vw_1997Siparisleri










