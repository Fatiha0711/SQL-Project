use E_commerceDB
GO

-----SELECT------
Select * from Products_Information
Select * from Suppliers_Information
Select * from Employees_Information
Select * from Customers_Information
Select * from Order_Information
Select * from Sales_Record
GO

------INSERT VALUES----
insert into Products_Information
values  (1,'Sharee',50,15,'2023/09/20'),
		(2,'Kurti',60,20,'2023/09/20'),
		(3,'Hijab',90,45,'2023/09/20'),
		(4,'Shirt',45,15,'2023/09/20'),
		(5,'Pant',50,15,'2023/09/20');
GO

insert into Suppliers_Information
values  (1, 'Jamdani Hat', '01725896324',30,1500,45000,'2023/09/01'),
		(2, 'Phathan Market', '01925683145',50,1200,60000,'2023/09/05'),
		(3, 'Hijab Ghhar', '01715444466',300,250,75000,'2023/09/10'),
		(4, 'Islampur Bajar', '01815369874',50,500,25000,'2023/09/15'),
		(5, 'Paikari Point', '01624569658',50,800,40000,'2023/09/20');

GO

insert into Employees_Information
values  (1,'Shourav', '01789654123',30,'Male','2020/03/01'),
		(2,'Kanij', '01963258741',25,'Female','2020/09/01'),
		(3,'Shauli', '01715936874',26,'Female','2021/05/01'),
		(4,'Yasin', '01852369741',28,'Male','2022/08/01');

GO

insert into Customers_Information
values  (1,'Tamanna','01789632145','kishorganj'),
		(2,'Afia','01632145789','Pabnna'),
		(3,'Aisha','01712365478','Jashore'),
		(4,'Tuhin','01896325412','Shoriyotpur'),
		(5,'Lokman','01963258741','Satkhira');
GO

insert into Order_Information
values  (1,1,1,5,7500,'2023/09/10','2023/09/12','kishorganj','delivered'),
		(2,2,2,2,2400,'2023/09/13','2023/09/15','Pabnna','delivered'),
		(3,3,3,3,750,'2023/09/17','2023/09/19','Jashore','delivered'),
		(4,4,4,2,1000,'2023/09/20','2023/09/22','kishorganj','Processing'),
		(5,5,5,3,2400,'2023/09/20','2023/09/22','Satkhira','Processing');
GO

insert into Sales_Record
values  (1,1,1,1,7500,150,3),
		(2,2,2,2,2400,150,1),
		(3,3,3,3,750,150,2),
		(4,4,4,4,1000,150,1),
		(5,5,5,5,2400,150,4);
GO

------UPDATE----
UPDATE Products_Information 
SET ProductName ='Borkha'
WHERE ProductID = 6;
GO

------DELETE-----
DELETE From Products_Information 
WHERE ProductID = 6;
GO

-----SELECT/DISTINCT/ORDER BY----
SELECT CustomerID,CustomersName 
FROM Customers_Information;

SELECT DISTINCT CustomersAddress 
FROM Customers_Information;

SELECT * 
FROM Products_Information 
ORDER BY ProductName DESC;
GO

----TOP---
SELECT TOP 5 *
FROM Products_Information
WHERE StockOut >=3
ORDER BY ProductID DESC
GO

----Offset fitch----

select* from Customers_Information
order by CustomerID
OFFSET 0 rows
fetch first 3 rows ONLY;

-----BETWEEN/AND-----
SELECT *
FROM Order_Information
WHERE OrderDate BETWEEN '2023-08-10' AND '2023-09-15';
GO

-----OR-----
SELECT *
FROM Order_Information
WHERE OrderDate > '2023-08-10' OR Order_Amount > 2000;
GO

-----NOT-----
SELECT *
FROM Order_Information
WHERE NOT Order_Amount > 2000;
GO

-----IN-----
SELECT CustomersName
FROM Customers_Information
WHERE CustomerID IN (SELECT CustomerID FROM Sales_Record);
GO

-----LIKE-----
SELECT * 
FROM Customers_Information
WHERE CustomersAddress LIKE 'Jash%';
GO

--Query:
select Products_Information.ProductID,Order_Information.OrderID,Products_Information.stockout,Order_Information.CustomerID
From Sales_Record join Products_Information
on Products_Information.ProductID=Sales_Record.ProductID
join Order_Information
on Order_Information.OrderID=Sales_Record.OrderID
join Customers_Information
on Customers_Information.CustomerID=Sales_Record.CustomerID
where stockout= 50
order by Sales_Record.ProductID

GO

--Sub-query
select Products_Information.ProductID,OrderID,Sales_Price,Products_Information.stockout,(Sales_Price * Products_Information.stockout) 
AS TotalPrice,DeliveryCharge,
sum((Sales_Price * Products_Information.stockout)+DeliveryCharge) AS TotalVAT
From Sales_Record
join Products_Information
on Sales_Record.ProductID = Products_Information.ProductID
where OrderID in(select OrderID from Order_Information)
group by Products_Information.ProductID,OrderID,Sales_Price,DeliveryCharge,Products_Information.stockout
having sum(Sales_Price*Products_Information.stockout)+DeliveryCharge<>0


-----UNION-----
SELECT ProductID AS SaledProduct FROM Products_Information
UNION
SELECT ProductID AS SaledProduct FROM Sales_Record;
GO

-----AGGREGRATE FUNCTIONS-----

----COUNT FUNCTION
SELECT COUNT(CustomerID),CustomersName 
FROM Customers_Information
GROUP BY CustomersName;
GO

----AVERAGE OF QUANTITY
SELECT AVG(ProductID) AS AvgOfProducts
FROM Products_Information
GROUP BY ProductID;
GO

----SUM OF QUANTITY
SELECT OrderID, SUM(Order_Quantity) AS AveOfOrder
FROM Order_Information 
GROUP BY OrderID;
GO

-----GROUP BY & HAVING-----
SELECT Products_Information.ProductID,Order_Information.Order_Quantity,Order_Amount,
(Order_Amount * Order_Information.Order_Quantity) AS TotalPrice,
SUM(Order_Amount *Order_Information.Order_Quantity) AS TotalCharge
FROM Order_Information
JOIN Products_Information
ON Products_Information.ProductID = Order_Information.ProductID
GROUP BY Products_Information.ProductID,Order_Amount,Order_Information.Order_Quantity
HAVING SUM(Order_Amount * Order_Information.Order_Quantity) <> 0;
GO

-----ROLLUP-----
SELECT CustomersName, CustomersAddress
FROM Customers_Information
WHERE CustomersAddress IN ('Jashore')
GROUP BY CustomersName, CustomersAddress WITH ROLLUP;
GO

-----CUBE-----

SELECT CustomersName, CustomersAddress
FROM Customers_Information
WHERE CustomersAddress IN ('Jashore')
GROUP BY CustomersName, CustomersAddress WITH CUBE;
GO

-----GROUPING SETS-----

SELECT CustomersName, CustomersAddress
FROM Customers_Information
WHERE CustomersAddress IN ('Jashore')
GROUP BY GROUPING SETS (CustomersName, CustomersAddress);
GO

------OVER-----
SELECT ProductId,Order_Quantity,OrderDate, 
COUNT(*) OVER(PARTITION BY Order_Quantity) AS OverColumn
FROM Order_Information;

------ALL-----
SELECT CustomerID, OrderID, Sales_price
FROM Sales_Record JOIN Products_Information 
ON Products_Information.ProductID=Products_Information.ProductID
WHERE Sales_price > ALL
                     (SELECT Sales_price
					 FROM Sales_Record
					 WHERE ProductID=9)
ORDER BY CustomerID;

--- Any--

SELECT CustomerID, OrderID, Sales_price
FROM Sales_Record JOIN Products_Information 
ON Products_Information.ProductID=Products_Information.ProductID
WHERE Sales_price < Any
                     (SELECT Sales_price
					 FROM Sales_Record
					 WHERE ProductID=9)
ORDER BY CustomerID;

--Some--

SELECT CustomerID, OrderID, Sales_price
FROM Sales_Record JOIN Products_Information 
ON Products_Information.ProductID=Products_Information.ProductID
WHERE Sales_price < Some
                     (SELECT Sales_price
					 FROM Sales_Record
					 WHERE ProductID=9)
ORDER BY CustomerID;

--CTE--

With CTE_Order AS
(Select DeliveryAddress , Order_Quantity,Sum(Order_Amount) As SumOfAmount
From Order_Information join Sales_Record on Order_Information.OrderID=Sales_Record.OrderID
Group By DeliveryAddress , Order_Quantity
)
Select * From CTE_Order;
go

--Case Function--

Select SuppliersName, PurchasePrice, PurchaseDate,
case PurchaseDate
when '2023/09/01' Then 'Delivered'
When '2023/09/20' Then 'Cancel'
Else 'Processing'
End As NewStatus
From Suppliers_Information;

-----Ranking Function----

select EmployeeID, EmployeesName,
ROW_NUMBER() Over(Order By EmployeeID) As RowNumber,  
 RANK() Over(Order By EmployeesName) As RankNo,
 DENSE_RANk () Over(Order By EmployeesName) As Denserank,
 NTILE(2)Over (order By EmployeesName) As EmployeesGroup
 From Employees_Information;

 ---exists---

 select EmployeeID, EmployeesName, Age
 from Employees_Information
 where exists
 (select * from Sales_Record
 where Employees_Information.EmployeeID=Sales_Record.EmployeeID);

 --Insert--
Insert Into Customers_Information(CustomerID, CustomersName, CustomersAddress, CustomersContact)
Values(6,'Masum','Gajipur','01512365478');

--Delete--
Delete from Customers_Information
where CustomerID = 6;

--IIf--
Select CustomerID, CustomersName, iif(CustomersAddress ='Dhaka','Best','Delivered') as NewColumn 
From Customers_Information;

--Choose--
Select CustomerID, CustomersName, Choose(CustomerID,'Dhaka','Best','Delivered') as NewColumn 
From Customers_Information

--Lag--
Select CustomerID, lag(CustomerID) over(partition by CustomerID order by CustomersAddress) as NewColumn 
From Customers_Information;

--Lead--
Select CustomerID, lead(CustomerID) over(partition by CustomerID order by CustomersAddress) as NewColumn 
From Customers_Information;
