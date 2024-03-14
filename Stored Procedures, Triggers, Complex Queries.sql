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

SELECT* FROM CUSTOMERS --Check table
DELETE FROM Customers --Delete the Test record
WHERE CustomerID = 6; 
DBCC CHECKIDENT ('Customers', RESEED, 5); --Reset Identity

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


