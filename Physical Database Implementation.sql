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

