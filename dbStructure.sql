-- Test creating the Customer table
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

-- Test creating the Shipping table
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

-- Test creating the Product table
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

-- Test creating the OrderItem table
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