/*	Ders 11	*/

/* Index Yapısı */

--Tabloların üzerinde oluşturduğumuz verilere daha hızlı erişmemizi sağlayan bir veri tabanı nesnesidir.

--Extent =>64 KB
--Page => 8 KB

--B-Tree (Balanced Tree) Algoritması
--Bir veri yapısıdır.
--Bir bütün içerisinde bir parçaya erişmek olarak tanımlanabilir.

--Clustered Index
--Bir değere göre arama
--Bir kere yapılabilir.
--Non-Clustered Index
--Leaf Level Pagelerde bir referans söz konusu ise
--Birden fazla olabilir.

--Çok fazla index kullanımı veri tabanında ciddi performans sorunlarına neden olabilir.
--Unique değerler veya sql where, order by kısımlarında yazılan kolonlar üzerinde index oluşturmak performansı olumlu etkileyebilir.

------------------------------
CREATE CLUSTERED INDEX CI_PersonelNo
ON Personel
(
     PersonelNo
)

DROP INDEX CI_PersonelNo 
ON Personel

CREATE UNIQUE CLUSTERED INDEX CI_PersonelNo
ON Personel
(
     PersonelNo
)

CREATE CLUSTERED INDEX CI_DogumTarihi
ON Personel
(
     DogumTarihi
)

CREATE NONCLUSTERED INDEX NCI_DogumTarihi
ON Personel
(
     DogumTarihi
)

CREATE NONCLUSTERED INDEX NCI_AdSoyad
ON Personel
(
     Ad,
	 Soyad
)

CREATE UNIQUE NONCLUSTERED INDEX NCI_AdSoyad
ON Personel
(
     Ad,
	 Soyad
)

SELECT Mail FROM Personel WHERE Ad='Graham'

--Key Lookup
--Index Covering

CREATE NONCLUSTERED INDEX NCI_AdSoyad
ON Personel
(
     Ad,
	 Soyad
)
INCLUDE (Mail)

CREATE NONCLUSTERED INDEX NCI_Sehir
ON Personel
(
    Sehir
)
WHERE Sehir='Ankara' --Filtered index

---------------------------

-- Transactions
-- İşlemlerin yönetilebilirliği için kullanılır.
-- Birbiri ile ilişkili işlerin bütünüdür.

/*
--ACID Prensipleri

A - Atomicity
C - Consistency
I - Isolation
D - Durability
*/

/*
SQL'de 3 Transaction yapısı vardır.
AutoCommit -- SQL'de Default Transaction
Implicit --İşlemden sonra özellikle tetiklenmesi lazım. Oracle'da Default Transaction budur.
Explicit --SQL'de en çok yapılan Transaction
*/

SET IMPLICIT_TRANSACTIONS ON
SET IMPLICIT_TRANSACTIONS OFF

BEGIN TRANSACTION

DECLARE @ordersCount AS INT = (SELECT COUNT(*) FROM Orders)
DECLARE @newOrdersCount AS INT

INSERT INTO Orders(OrderDate,RequiredDate)
VALUES(GETDATE(), DATEADD(WEEK,2,GETDATE()))

SELECT @newOrdersCount = COUNT(*) FROM Orders

IF @ordersCount = @newOrdersCount 
BEGIN
    --GOTO ErrorHandler
	ROLLBACK TRANSACTION
END
ELSE
BEGIN
   --DECLARE @currentOrderID AS INT = (SELECT TOP 1 OrderID FROM Orders ORDER BY OrderID DESC
   DECLARE @currentOrderID AS INT = (SELECT SCOPE_IDENTITY())

   INSERT INTO [Order Details](OrderID,ProductID,Quantity)
   VALUES(@currentOrderID,1000,5)

   IF @@ERROR <> 0
   BEGIN
      --GOTO ErrorHandler
	  ROLLBACK TRANSACTION
   END
   ELSE
   BEGIN
      COMMIT TRANSACTION
   END
END

--ErrorHandler:
--IF @@ERROR <> 0 ROLLBACK TRANSACTION


--READ UNCOMMITTED 
--READ COMMITTED (DEFAULT)
--REPEATABLE READ
--SERIALIZABLE
--SNAPSHOT

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

SELECT * FROM Categories WITH(NOLOCK)


















