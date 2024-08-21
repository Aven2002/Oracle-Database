-- Create Tables
BEGIN
    EXECUTE IMMEDIATE '
    CREATE TABLE Customer (
        CustomerID VARCHAR2(50) PRIMARY KEY,
        CustomerName VARCHAR2(100),
        Segment VARCHAR2(50),
        City VARCHAR2(100),
        State VARCHAR2(100),
        Country VARCHAR2(100),
        Market VARCHAR2(35),
        Region VARCHAR2(35)
    )';
END;
/

BEGIN
    EXECUTE IMMEDIATE '
    CREATE TABLE Shipping (
        ShippingID NUMBER PRIMARY KEY,
        OrderID VARCHAR2(50),
        OrderDate DATE,
        ShipDate DATE,
        ShipMode VARCHAR2(50),
        CustomerID VARCHAR2(50),
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
    )';
END;
/

BEGIN
    EXECUTE IMMEDIATE '
    CREATE TABLE Product (
        ProductID VARCHAR2(50) PRIMARY KEY,
        Category VARCHAR2(50),
        SubCategory VARCHAR2(50),
        ProductName VARCHAR2(255)
    )';
END;
/

BEGIN
    EXECUTE IMMEDIATE '
    CREATE TABLE OrderItem (
        OrderID VARCHAR2(50),
        ProductID VARCHAR2(50),
        SalesAmount NUMBER(10, 2),
        Quantity NUMBER,
        Discount NUMBER(5, 2),
        Profit NUMBER(10, 2),
        ShippingCost NUMBER(10, 2),
        OrderPriority VARCHAR2(50),
        PRIMARY KEY (OrderID, ProductID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    )';
END;
/

--Create Indexes

-- Index on CustomerID for faster lookups in the Shipping table based on CustomerID
CREATE INDEX idx_shipping_customerid ON Shipping(CustomerID);

-- Index on CustomerName for faster searches based on CustomerName
CREATE INDEX idx_customer_name ON Customer(CustomerName);

-- Index on OrderPriority for faster lookups in the OrderItem table based on OrderPriority
CREATE INDEX idx_orderitem_orderpriority ON OrderItem(OrderPriority);

-- Index on ProductID for faster lookups in the OrderItem table based on ProductID
CREATE INDEX idx_orderitem_productid ON OrderItem(ProductID);

