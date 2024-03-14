Total of 2 for each: _COMPUTED COLUMNS_, _STORED PROCEDURES_, _TRIGGERS_, and _COMPLEX QUERIES_ are demonstrated on the manufacturing database.

## COMPUTED COLUMNS

#### 1: DELIVERY PERFORMANCE
<sub> Timely delivery is critical for manufacturers to meet customer expectations, maintain a competitive edge, minimize costs, and build a strong reputation in the marketplace. .</sub>
```
ALTER TABLE ORDERS ADD DeliveryPerformance AS (DATEDIFF(day, ExpectedDelivery, DeliveryDate))
```
#### 2 : LEAD TIME
<sub> It is a critical indicator of operational efficiency, customer satisfaction, and overall business success for manufacturers.</sub>
```
ALTER TABLE ORDERS ADD LeadTime AS (DATEDIFF(day, OrderDate, DeliveryDate))
```
###### Check ORDERS table
```
SELECT * FROM ORDERS
````
<img width="1085" alt="Screen Shot 2024-03-14 at 4 12 24 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/ca041e6b-9a38-4ded-b010-2cdd998565fc">


## STORED PROCEDURES

#### 1-1: LOOK UP WHETHER A CUSTOMER ALREADY EXIST IN OUR DATABASE

```
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
```

#### NESTING 1-2: IF NOT, THEN CREATE A NEW CUSTOMER RECORD 
+ <sub>The module 'InsCustomers' depends on the result of 'GetCustomerIDByEmail'.</sub>
+ <sub>The module runs successfully if the customer is new and assigned to an existing employee.</sub>

```
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
```
###### Code Testing
```
--1-1
DECLARE @Status int;
DECLARE @CustomerID int;
EXEC @Status = GetCustomerIDByEmail
                @ContactEmail = '123@company.com'
               ,@CustomerID = @CustomerID OUTPUT;

SELECT @Status as [Return Code Value], @CustomerID as [CustomerID]
```
<img width="342" alt="Screen Shot 2024-03-14 at 3 42 07 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/eb34e573-5c8d-46ce-b076-60526e448e90">



```
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
```
<img width="220" alt="Screen Shot 2024-03-14 at 3 42 22 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/974463d7-67c4-4f0e-81f5-988d13a43661">
<img width="1244" alt="Screen Shot 2024-03-14 at 3 42 41 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/6252c42e-8e4e-4f36-b1af-357e9898f144">

#### 2: INSERT NEW ORDER 
```
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
```

###### Code Testing
```
EXEC InsOrders 
@CustomerID = 1, 
@OrderDate = '2024-03-29', 
@ExpectedDelivery = '2024-05-01', 
@DeliveryDate = '2024-04-30', 
@PaymentTermsID = 2; 

SELECT* FROM ORDERS
```
<img width="1083" alt="Screen Shot 2024-03-14 at 4 07 23 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/a4cc1bcf-71e2-4fae-ad78-14e34dd7a798">

## QUERIES

#### 1: FIND TOTAL QUANTITY & TOTAL AMOUNT PER ORDER
<sub> Manual input is time-consuming and prone to errors. As a result, we avoid manually inserting information into the table. 
Instead, we utilize SQL functions to retrieve the required data.</sub>

```
SELECT c.CompanyName, o.OrderID, SUM(od.Quantity) AS TotalQuantity, SUM(p.UnitPrice * od.Quantity) AS TotalAmount
FROM ORDER_DETAILS od
JOIN ORDERS o ON od.OrderID = o.OrderID
JOIN CUSTOMERS c ON o.CustomerID = c.CustomerID
JOIN PRODUCTS p ON od.ProductID = p.ProductID
GROUP BY c.CompanyName, o.OrderID
```
<img width="526" alt="Screen Shot 2024-03-14 at 4 31 45 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/1f5772ff-3904-40b1-adcb-7579da4d760c">

#### 2: WHAT ARE THE TOP THREE PARTS SUGGESTED TO PURCHASE MORE STOCK OF, AS THEY ARE THE MOST CONSUMED, WITHIN TIME RANGE JANUARY TO FEBRUARY
<sub>It is critical to have transparency regarding the consumption of each part over a period of time. This helps in better planning of restock schedules and prevents supply shortages.</sub>

```
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
```
<img width="410" alt="Screen Shot 2024-03-14 at 4 32 07 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/9d9938ea-305b-41bf-ab11-5d58a3cae318">

## TRIGGERS

#### 1: PAYMENT REMINDER
<sub>PAYMENT_REMINDERS table serves as a reminder for employees of their responsibility to ensure timely payments for orders and prompts them to remind customers accordingly.</sub>
```
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
```

###### Code Testing

```
INSERT INTO ORDERS (CustomerID,OrderDate,ExpectedDelivery, DeliveryDate, PaymentTermsID)
VALUES
 (3,'2024-03-03','2024-03-29','2024-03-29',4)

SELECT * FROM ORDERS
SELECT * FROM PAYMENT_REMINDERS
```
<img width="1083" alt="Screen Shot 2024-03-14 at 4 07 23 PM 2" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/26699a23-67ae-46a5-bf13-b53b133896f3">
<img width="900" alt="Screen Shot 2024-03-14 at 4 33 23 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/9f7d667b-3e31-4e22-a6c9-0e118e46c636">


#### 2: DELETE RECORD FROM PAYMENT REMINDERS IF ORDERS ARE DELETED
<sub> Ensure data consistency in case of modification to the ORDERS table. </sub>
```
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
```
###### Code Testing

```
DELETE FROM ORDERS
WHERE OrderID = 14;
```
<img width="251" alt="Screen Shot 2024-03-14 at 4 35 51 PM" src="https://github.com/chan571/Manufacturing-Database-Design/assets/157858508/b6dac944-7f55-4798-b27b-a513201eb2aa">



