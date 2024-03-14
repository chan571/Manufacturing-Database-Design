---Create customers table
USE Manufacture

CREATE TABLE SUPPLY_CATEGORY (
    SupplyCategoryID INT PRIMARY KEY IDENTITY(1,1),
    SupplyCategoryName NVARCHAR(150) NOT NULL,
)

CREATE TABLE SUPPLIERS (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplyCategoryID INT FOREIGN KEY REFERENCES SUPPLY_CATEGORY(SupplyCategoryID),
    SupplierName NVARCHAR(150) NOT NULL,
    SupplierEmail NVARCHAR(200) NOT NULL,
    SupplierAdd NVARCHAR(200),
    SupplierCity NVARCHAR(75),
    SupplierState NVARCHAR(25),
    SupplierZip NVARCHAR(25),
    SuppleirPhone NVARCHAR(15)
)

CREATE TABLE PARTS (
    PartID INT PRIMARY KEY IDENTITY(1,1),
    PartName NVARCHAR(150) NOT NULL,
    SupplyCategoryID INT FOREIGN KEY REFERENCES SUPPLY_CATEGORY(SupplyCategoryID)
)

CREATE TABLE PRODUCTS (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(200),
    MOQ NUMERIC(8,0),
    UnitPrice DECIMAL(6,2) NOT NULL,
    Description NVARCHAR(255)
)

CREATE TABLE BOM (
    BOM_ID INT PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES PRODUCTS(ProductID),
    PartID INT FOREIGN KEY REFERENCES PARTS(PartID),
    PartUnit NUMERIC(15,0) NOT NULL
)

CREATE TABLE EMPLOYEES (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeFName NVARCHAR(150) NOT NULL,
    EmployeeLName NVARCHAR(150) NOT NULL,
    EmployeeEmail NVARCHAR(200) NOT NULL
)

CREATE TABLE PAYMENT (
    PaymentTermsID INT PRIMARY KEY IDENTITY(1,1),
    PaymentTermsName NVARCHAR(100) NOT NULL
)

CREATE TABLE CUSTOMERS (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Country NVARCHAR(150) NOT NULL,
    CompanyName NVARCHAR(150) NOT NULL,
    ContactFName NVARCHAR(150),
    ContactLName NVARCHAR(150),
    ContactEmail NVARCHAR(200) NOT NULL,
    CustomerAdd NVARCHAR(200),
    CustomerCity NVARCHAR(75),
    CustomerState NVARCHAR(25),
    CustomerZip NVARCHAR(25),
    CustomerPhone NVARCHAR(15),
    EmployeeID INT FOREIGN KEY REFERENCES EMPLOYEES(EmployeeID)
)

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES CUSTOMERS(CustomerID),
    OrderDate  DATE NOT NULL,
    ExpectedDelivery DATE NOT NULL,
    DeliveryDate DATE NOT NULL,
    PaymentTermsID INT FOREIGN KEY REFERENCES PAYMENT(PaymentTermsID)  
)


CREATE TABLE ORDER_DETAILS (
    OrderDetailsID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES ORDERS(OrderID),
    ProductID INT FOREIGN KEY REFERENCES PRODUCTS(ProductID),
    Quantity NUMERIC(15,0) NOT NULL,
)



--Insert Values

INSERT INTO PRODUCTS (ProductName, MOQ, UnitPrice, Description)
VALUES
 ('Brush01',1000,8,'Small brush')
,('Brush02',1500,12,'Medium brush')
,('Handle01',1500,30,'150CM')
,('Handle02',1500,35,'180CM')
,('Microfiber01',3000,0.9,'For Kitchen');

INSERT INTO SUPPLY_CATEGORY (SupplyCategoryName)
VALUES ('Aluminium'), ('Plastic'), ('Metal'), ('Brushes'), ('Microfiber')

SET IDENTITY_INSERT PARTS ON
INSERT INTO PARTS (PartID, PartName, SupplyCategoryID)
VALUES (1, 'Tube', 1), (2, 'Plastic A', 2),(3, 'Plastic B', 2),(4, 'Screw', 3), (5, 'Spring Coil', 3), (6, 'Bristle Head', 4), (7, 'Microfiber', 5)
SET IDENTITY_INSERT PARTS OFF

INSERT INTO SUPPLIERS (SupplyCategoryID, SupplierName, SupplierEmail, SupplierAdd, SupplierCity, SupplierState, SupplierZip, SuppleirPhone)
VALUES (5,'Micro Ease','info@microease.com','370 Ivory Cove','Lake Sylviamouth','AZ',84840,8029528118)
,(2,'Plastic Lux','info@plasticlux.com','958 Clinton Freeway','Morarmouth','IA',38018,3569437619)
,(4,'Brushify','info@brushify.com','52014 Seymour Green','East Tamiefurt','PA',67671,2713365612)
,(1,'AluVista','info@aluvista.com','22254 Labadie Fords','South Francesca','OK',76519,9812051445)
,(3,'SpringV','info@springv.com','46897 Grimes Crest','West Kimberliehaven','NJ',41704,1298627308)
,(2,'Viktor','info@victor.com','46532 Bart Greens','Glyndaside','TN',51867,8976587515)


INSERT INTO BOM (BOM_ID, ProductID, PartID, PartUnit)
VALUES (101, 1, 2, 3), (102, 1, 6, 3), (201, 2, 2, 5), (202, 2, 6, 5),(301, 3, 1, 2),(302, 3, 3, 5), (303, 3, 4, 8), (304, 3, 5, 1), (401, 4, 1, 3), (402, 4, 3, 7), (403, 4, 4, 12), (404, 4, 5, 1), (501, 5, 7, 1)

INSERT INTO EMPLOYEES (EmployeeFName, EmployeeLName, EmployeeEmail)
VALUES
 ('Ikram','Agnès','agnès@xyz.com')
,('Rudi','Dione','dione@xyz.com')
,('Elsy','Luciana','luciana@xyz.com')
,('Hudson','Ilshat','ilshat@xyz.com')
,('Higini','Uni','uni@xyz.com');

INSERT INTO PAYMENT (PaymentTermsName)
VALUES
 ('T/T')
,('LC')
,('COD')
,('Net 10');

INSERT INTO CUSTOMERS (Country, CompanyName, ContactFName, ContactLName, ContactEmail, CustomerAdd, CustomerCity, CustomerState, CustomerZip, CustomerPhone, EmployeeID)
VALUES
 ('United Kingdom','Cleancup','Jani','Vishal','vishal@cleancup.com','702 Suzy Neck','Ankundingbury','WA',35975,196507475,1)
,('Australia','Purify','Pietra','Ndidi','ndidi@purify.com','386 Lesch Roads','East Ambrose','WY',20349,773492731,3)
,('Finland','Cleanessence','Ildar','Nichelle','nichelle@cleanessence.com','66094 Bailey Street','North Mckenzieboroug','AL',49380,542154327,4)
,('Russia','Goodclean','Othmar','Nanda','nanda@goodclean.com','Lielaan 395 II','Gieskeplas','ME',1749,250868993,5)
,('Japan','FarEast','Bertil','Meredith','meredith@fareast.com','453-1239, Akasaka','Tokyo',NULL,1235,935682395,2);

SET IDENTITY_INSERT ORDERS ON
INSERT INTO ORDERS (OrderID, CustomerID, OrderDate, ExpectedDelivery, DeliveryDate,PaymentTermsID)
VALUES
 (1,1,'2024-01-12','2024-02-10','2024-02-05',1)
,(2,3,'2024-01-14','2024-02-15','2024-02-08',2)
,(3,2,'2024-01-30','2024-02-27','2024-03-02',1)
,(4,2,'2024-02-08','2024-03-01','2024-02-29',3)
,(5,5,'2024-02-09','2024-03-01','2024-03-01',4);
SET IDENTITY_INSERT ORDERS OFF


SET IDENTITY_INSERT ORDER_DETAILS ON
INSERT INTO ORDER_DETAILS (OrderDetailsID, OrderID, ProductID, Quantity)
VALUES
 (1,1,1,1000)
,(2,1,2,1500)
,(3,2,3,3000)
,(4,3,1,2000)
,(5,3,2,2000)
,(6,3,3,3000)
,(7,3,4,1500)
,(8,4,3,1500)
,(9,5,5,4000);
SET IDENTITY_INSERT ORDER_DETAILS OFF

--Project Deliverable 4--

EXEC sp_help CUSTOMERS

--STORED PROCEDURE 1-1: LOOK UP WHETHER A CUSTOMER ALREADY EXIST IN OUR DATABASE

CREATE OR ALTER PROCEDURE GetCustomerIDByEmail
 (@ContactEmail nvarchar(200)
 ,@CustomerID int OUTPUT
 )
AS
 BEGIN
  DECLARE @Status int = 0;
  BEGIN TRY
   SELECT @CustomerID = CustomerID 
     FROM CUSTOMERS 
	   WHERE ContactEmail= @ContactEmail;
   SET @Status = +1;
  END TRY
  BEGIN CATCH
   SET @Status = -1;
  END CATCH
  RETURN @Status;
 END
GO

--STORED PROCEDURE 1-2: IF NOT, CREATE A NEW RECORD

/*
--The module 'InsCustomers' depends on the missing object 'GetCustomerIDByEmail'. 
--The module will still be created; however, it cannot run successfully until the object exists.
*/

CREATE OR ALTER PROCEDURE InsCustomers
    (@Country NVARCHAR(150)
    ,@CompanyName NVARCHAR(150)
    ,@ContactFName NVARCHAR(150)
    ,@ContactLName NVARCHAR(150)
    ,@ContactEmail NVARCHAR(200)
    ,@CustomerAdd NVARCHAR(200)
    ,@CustomerCity NVARCHAR(75)
    ,@CustomerState NVARCHAR(25)
    ,@CustomerZip NVARCHAR(25)
    ,@CustomerPhone NVARCHAR(15)
    ,@EmployeeID INT 
    ,@NewCustomerID INT OUTPUT)
AS
BEGIN
    DECLARE @Status INT = 0;
    DECLARE @CustomerID INT = NULL; -- Will hold customer ID if it exists
    
    -- Check if the provided EmployeeID exists in the EMPLOYEES table
    IF NOT EXISTS (SELECT 1 FROM EMPLOYEES WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Invalid EmployeeID. Please provide a valid EmployeeID.', 16, 1);
        RETURN -1; 
    END
    
    BEGIN TRY
        -- Check for existing customer email
        EXEC @Status = GetCustomerIDByEmail 
                        @ContactEmail = @ContactEmail
                        ,@CustomerID = @CustomerID OUTPUT;
        
        IF @Status = 1 AND @CustomerID IS NULL -- ran successfully and did NOT find an ID
        BEGIN
            BEGIN TRAN;
                -- Insert data into Customers table
                INSERT INTO Customers (
                    Country,
                    CompanyName,
                    ContactFName,
                    ContactLName,
                    ContactEmail,
                    CustomerAdd,
                    CustomerCity,
                    CustomerState,
                    CustomerZip,
                    CustomerPhone,
                    EmployeeID -- Include the foreign key column
                )
                VALUES (
                    @Country,
                    @CompanyName,
                    @ContactFName,
                    @ContactLName,
                    @ContactEmail,
                    @CustomerAdd,
                    @CustomerCity,
                    @CustomerState,
                    @CustomerZip,
                    @CustomerPhone,
                    @EmployeeID -- Insert the EmployeeID parameter value
                );

                -- Get the ID of the newly inserted customer
                SET @NewCustomerID = @@Identity;
                SET @Status = +1;
            COMMIT TRAN;
        END
        ELSE -- ran successfully, but found an ID
            RAISERROR('Customer Already Exists! See CustomerID ', 15, 1);  
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;  
        SET @Status = -1;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 15, 1);  
    END CATCH
    
    RETURN @Status;
END
GO

--Test
--1-1
DECLARE @Status int;
DECLARE @CustomerID int;
EXEC @Status = GetCustomerIDByEmail
                @ContactEmail = '123@company.com'
               ,@CustomerID = @CustomerID OUTPUT;

SELECT @Status as [Return Code Value], @CustomerID as [CustomerID]

--1-2
DECLARE @Status INT;
DECLARE @NewCustomerID INT;
EXEC InsCustomers
@Country = 'United States',
@CompanyName = '123 Compnay',
@ContactFName = 'Ben',
@ContactLName = 'Johnson',
@ContactEmail = '123@company.com',
@CustomerAdd = '500 Main Street',
@CustomerCity = 'New York City',
@CustomerState = 'New York',
@CustomerZip = '10001',
@CustomerPhone = '3571603782',
@EmployeeID = '2',
@NewCustomerID = @NewCustomerID OUTPUT;


-- STORED PROCEDURE 2: INSERT NEW ORDER 
-- Disregard table alterations they are for the other exercise.

CREATE PROCEDURE InsOrders
( @CustomerID INT,
  @OrderDate DATE,
  @ExpectedDelivery DATE,
  @DeliveryDate DATE,
  @PaymentTermsID INT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;        
              INSERT INTO ORDERS
              (CustomerID, OrderDate, ExpectedDelivery, DeliveryDate, PaymentTermsID)
              VALUES
              (@CustomerID, @OrderDate, @ExpectedDelivery, @DeliveryDate, @PaymentTermsID);
           COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
            PRINT ERROR_MESSAGE()
        PRINT 'Invalid Value(s). Check again!';
    END CATCH
END
GO

--Test
EXEC InsOrders 
@CustomerID = 1, 
@OrderDate = '2024-03-29', 
@ExpectedDelivery = '2024-05-01', 
@DeliveryDate = '2024-04-30', 
@PaymentTermsID = 2; 
SELECT* FROM ORDERS

DELETE FROM ORDERS
WHERE CustomerID = 1
AND OrderDate = '2024-03-29'
AND ExpectedDelivery = '2024-05-01'
AND DeliveryDate = '2024-04-30'
AND PaymentTermsID = 2;

-- COMPUTED COLUMNS 1 : DELIVERY PERFORMANCE
ALTER TABLE ORDERS ADD DeliveryPerformance AS (DATEDIFF(day, ExpectedDelivery, DeliveryDate))
-- COMPUTED COLUMNS 2 : LEAD TIME
ALTER TABLE ORDERS ADD LeadTime AS (DATEDIFF(day, OrderDate, DeliveryDate))
-- Check ORDERS table
SELECT * FROM ORDERS
ALTER TABLE ORDERS DROP COLUMN DeliveryPerformance; 
ALTER TABLE ORDERS DROP COLUMN LeadTime;

-- QUERIES
-- QUERIES 1: FIND TOTAL QUANTITY & TOTAL AMOUNT PER ORDER 
SELECT c.CompanyName, o.OrderID, SUM(od.Quantity) AS TotalQuantity, SUM(p.UnitPrice * od.Quantity) AS TotalAmount
FROM ORDER_DETAILS od
JOIN ORDERS o ON od.OrderID = o.OrderID
JOIN CUSTOMERS c ON o.CustomerID = c.CustomerID
JOIN PRODUCTS p ON od.ProductID = p.ProductID
GROUP BY c.CompanyName, o.OrderID

-- QUERIES 2: WHAT ARE THE TOP THREE PARTS SUGGESTED TO PURCHASE MORE STOCK OF, AS THEY ARE THE MOST CONSUMED, WITHIN TIME RANGE JANUARY TO FEBRUARY
SELECT TOP 3 WITH TIES b.PartID, p.PartName, SUM(b.Total_Quantity_Per_Part) AS Total_PartsQ_Used
FROM (
SELECT bom.PartID, bom.PartUnit, a.Total_Quantity_Per_Product, (bom.PartUnit * a.Total_Quantity_Per_Product)AS Total_Quantity_Per_Part
FROM BOM bom
JOIN (SELECT od.ProductID, SUM(od.Quantity) AS Total_Quantity_Per_Product
FROM ORDER_DETAILS od
JOIN ORDERS o ON od.OrderID = o.OrderID
WHERE o.OrderDate BETWEEN '2024-01-01' AND '2024-02-29'
GROUP BY ProductID) a ON bom.ProductID = a.ProductID 
) b
JOIN PARTS p ON p.PartID = b.PartID
GROUP BY b.PartID, p.PartName
ORDER BY Total_PartsQ_Used DESC

-- TRIGGERS 
-- TRIGGERS 1: PAYMENT REMINDER
CREATE TABLE PAYMENT_REMINDERS(
    OrderID INT,
    CustomerID INT,
    OrderDate DATE,
    ExpectedDeliveryDate DATE,
    PaymentMessage NVARCHAR(200)
)
GO

CREATE OR ALTER TRIGGER trgAFTERInsertOrders
ON ORDERS
AFTER INSERT, UPDATE
AS 
BEGIN
    DECLARE @orderID INT,
            @customerID INT,
            @orderDate DATE,
            @expectedDeliveryDate DATE,
            @paymentMessage NVARCHAR(200);

    SELECT @orderID = OrderID,
           @customerID = CustomerID,
           @orderDate = OrderDate,
           @expectedDeliveryDate = ExpectedDelivery,
           @paymentMessage = 
               CASE i.PaymentTermsID
                   WHEN 1 THEN 'Need an upfront payment before order processing'
                   WHEN 2 THEN 'Need a documentary credit before order processing'
                   WHEN 3 THEN 'Full payment against Bill of Lading'
                   WHEN 4 THEN 'Full payment expected to be due on ' + CONVERT(NVARCHAR(15), DATEADD(DAY, 10, ExpectedDelivery))
               END
    FROM Inserted i;

    INSERT INTO PAYMENT_REMINDERS (OrderID, CustomerID, OrderDate, ExpectedDeliveryDate, PaymentMessage)
    VALUES (@orderID, @customerID, @orderDate, @expectedDeliveryDate, @paymentMessage);
    PRINT 'After Insert/Update trigger fired successfully'
END;
GO

-- TEST

INSERT INTO ORDERS (CustomerID,OrderDate,ExpectedDelivery, DeliveryDate, PaymentTermsID)
VALUES
 (3,'2024-03-03','2024-03-29','2024-03-29',4)

SELECT * FROM ORDERS

-- TRIGGERS 2: DELETE RECORD FROM PAYMENT REMINDERS IF ORDERS ARE DELETED

CREATE OR ALTER TRIGGER trgAfterDeleteOrders
ON ORDERS
FOR DELETE
AS 
BEGIN
    DELETE FROM PAYMENT_REMINDERS
    WHERE OrderID IN (SELECT OrderID FROM Deleted);
    PRINT 'After Delete trigger fired successfully';
END;
GO

-- TEST
DELETE FROM ORDERS
WHERE OrderID = 14;

SELECT * FROM PAYMENT_REMINDERS

Reference: https://stackoverflow.com/questions/9996643/sql-server-on-delete-trigger


