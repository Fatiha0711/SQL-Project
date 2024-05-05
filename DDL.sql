--CREATE DATABASE--
Drop Database E_commerceDB
GO

Create Database E_commerceDB
On primary  
(NAME ='E_commerceDB_DATA_1',  
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\E_commerceDB_DATA_1.mdf',
Size=25MB, 
Maxsize=100MB, 
Filegrowth=5%)
LOG ON 
(NAME ='E_commerceDB_Log_1', 
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\E_commerceDB_LOG_1.ldf',
Size=2MB, 
Maxsize=50MB, 
Filegrowth=1%);
GO

--USE DATABASE--
Use E_commerceDB
GO

--CREATE TABLES--

create table Products_Information
(ProductID int primary key,
ProductName varchar(30),
StockIn int,
StockOut int,
EntryDate datetime);


create table Suppliers_Information
(SupplierID int primary key,
SuppliersName varchar(30),
SuppliersContact int,
Purchase_Quantity int,
PurchasePrice money,
Purchase_Amount money,
PurchaseDate datetime);

create table Employees_Information
(EmployeeID int primary key,
EmployeesName varchar(30),
EmployeesContact int,
Age int,
Gender varchar(30),
JoiningDate datetime);

create table Customers_Information
(CustomerID int primary key,
CustomersName varchar(30),
CustomersContact varchar (100),
CustomersAddress varchar (100));

create table Order_Information
(OrderID int primary key,
CustomerID int references Customers_Information(CustomerID),
ProductID int references Products_Information(ProductID),
Order_Quantity int,
Order_Amount int,
OrderDate datetime,
DeliveryDate datetime,
DeliveryAddress varchar (100),
Order_Status varchar(20));

create table Sales_Record
(SalesID int primary key,
CustomerID int references Customers_Information(CustomerID),
OrderID int references Order_Information(OrderID),
ProductID int references Products_Information(ProductID),
Sales_Price money,
DeliveryCharge money,
EmployeeID int references Employees_Information(EmployeeID));
GO

----Clustered index

create clustered index IndexSalesRecord
on Sales_Record(SalesID);

--nonClustered index

create nonclustered index IndexProductsInformation
on Products_Information(ProductName);
GO

-----ALTER,MODIFY AND DROP-----

Alter table Sales_Record add CategoryID int;

Alter table Sales_Record drop column CategoryID;

Alter table Order_Information drop column Available;

Alter table Order_Information add Status varchar(10);

Alter table Supliers_Information 
Add Constraint SuplierAddress
Default 'Dhaka' for SuplierAddress;

Drop Database E_commerceDB
Drop table Sales_Record;
Drop index IndexSalesRecord;
GO

 --trigger
Select * into Product_InformationCopy from Product_Information
select * from Product_InformationCopy
insert into Product_InformationCopy values(6,'Borkha')

drop table Product_InformationLog
create table Product_InformationLog (
LogId int identity(1,1) not null,
ProductNo int null,
ActionLog varchar(50) null 
);

create trigger Tr_Instead
       ON Product_InformationCopy
INSTEAD OF DELETE
AS
BEGIN
       DECLARE @ProductID int
       SELECT ProductID = DELETED.ProductID      
       FROM DELETED
       IF @ProductID = 2
       BEGIN
              RAISERROR('ID 2 record cannot be deleted',16 ,1)
              ROLLBACK
              INSERT INTO Product_InformationLog
              VALUES(@ProductID, 'Record cannot be deleted.')
       END
       ELSE
       BEGIN
              DELETE FROM Product_InformationCopy
              WHERE ProductID = @ProductID
              INSERT INTO Product_InformationLog
              VALUES(@ProductID, 'Instead Of Delete')
       END
END
GO

--trigger test
DELETE Product_InformationCopy
WHERE ProductID=6
select*from Product_InformationLog
select*from Product_InformationCopy

-----AFTER TRIGGER------

CREATE TABLE BackTblProductCategory
(
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50)
)
GO

CREATE TRIGGER TR_AfterProductCategory
ON Product_Information
AFTER UPDATE, INSERT
AS
BEGIN
INSERT INTO BackTblProductCategory
SELECT i.CategoryID,i.CategoryName,SUSER_NAME(),GETDATE()
FROM inserted i 
END
GO
SELECT * FROM BackTblProductCategory
GO

-- create View:

create view VwProduct_Information
  as 
select * from Product_InformationCopy
  go
select * from VwProduct_Information

--create view with only encryption--
go
Create view vw_enccryption
With encryption
AS
Select ProductID
From dbo.Product_InformationCopy;
Go

select * from vw_enccryption

--create view with only Schemabinding--

Create view vw_sche
with schemabinding
as
select ProductID
from dbo.Product_InformationCopy
GO

select * from vw_sche

--Create view with Encryption and schemabinding togather --

Create view vw_togather
with encryption,schemabinding
AS
SELECT ProductID FROM dbo.Product_InformationCopy
GO
---
SELECT * FROM vw_togather

--function
  
--Table Value Function--

create function fn_Product_InformationCopy
()
returns table
return
(
select * from Product_Information
)
--
select * from dbo.fn_Product_InformationCopy();

--Scalar value function --

create function fn_Sales_count
()
returns int
begin
declare @c int;
select @c = count(*) from Sales_Record;
return @c;
end;
---
select dbo.fn_Sales_count();

--multi statement function

create function fn_Product_Sales_Record_temp()
returns @outtable table(productID int,
DeliveryCharge decimal(18,2), DeliveryCharge_extent 
decimal(18,2))
begin
insert into @outTable(productID,DeliveryCharge,DeliveryCharge_extent)
select productID, DeliveryCharge, DeliveryCharge = DeliveryCharge + 10
from Sales_Record;
return;
end;
---
select * from dbo.fn_Product_Sales_Record_temp();

----STORED PROCEDURE SELECT-INSERT-UPDATE-DELETE
SELECT * FROM Product_InformationCopy
GO
CREATE PROCEDURE SP_SelectInsertUpdateDeleteProduct
(
@productID INT,
@productName VARCHAR(100),    
@StatementType NVARCHAR(20) = '')
AS
IF @StatementType = 'SELECT'
BEGIN
SELECT * FROM Product_InformationCopy
END

IF @StatementType = 'INSERT'
BEGIN
INSERT INTO Product_InformationCopy(ProductID, ProductName)
VALUES (@ProductID, @ProductName)
END

IF @StatementType = 'UPDATE'
BEGIN
UPDATE Product_InformationCopy
SET ProductName=@ProductName
WHERE ProductID = @ProductID
END

IF @StatementType = 'DELETE'
BEGIN
DELETE Product_InformationCopy
WHERE ProductID = @ProductID
END
----TEST PROCEDURE
EXECUTE SP_SelectInsertUpdateDeleteProduct 6,'Borkha','INSERT'
EXECUTE SP_SelectInsertUpdateDeleteProduct 7, 'Lehenga','UPDATE'
EXECUTE SP_SelectInsertUpdateDeleteProduct 7,'Lehenga','DELETE'
--
SELECT * FROM Product_InformationCopy

-- PROCEDURE IN PARAMETER
Go
Create proc sp_isn
@productID int,
@productName varchar(100)
As
Insert into Product_InformationCopy Values(@productID,@productName)
GO
Exec sp_isn 6,'Borkha'
---OutPut
Go
Create proc sp_inP
@productID int OUTPUT
AS
Select Count(*) From Product_InformationCopy
 
Exec sp_inp 4

GO
CREATE PROCEDURE SP_In
(@productID INT OUTPUT)
AS
SELECT COUNT(@productID)
FROM Product_InformationCopy
EXECUTE SP_In 144

-- PROCEDURE WITH RETURN STATEMENT
GO
drop proc SP_Return
go
CREATE PROCEDURE SP_Return
(@productID INT)
AS
    SELECT productID,productName
FROM Product_InformationCopy
    WHERE productID = @productID
GO
DECLARE @return_value INT
EXECUTE @return_value = SP_Return @productID = 6
SELECT  'Return Value' = @return_value;
