-- Create Tables

-- Shipping Table
CREATE TABLE shipping (
    shippingID NUMBER NOT NULL,
    shippingDate DATE NOT NULL,
    shippingMode VARCHAR2(50) NOT NULL,
    shippingCost NUMBER(10,2) NOT NULL,
    PRIMARY KEY (shippingID)
);

-- Market Table
CREATE TABLE market (
    marketID VARCHAR2(35) NOT NULL,
    marketRegion VARCHAR2(50) NOT NULL,
    PRIMARY KEY (marketID)
);

-- Customer Table
CREATE TABLE customer (
    customerID VARCHAR2(35) NOT NULL,
    marketID VARCHAR2(35) NOT NULL,
    cusName VARCHAR2(50) NOT NULL,
    cusSegment VARCHAR2(50) NOT NULL,
    cusCity VARCHAR2(50) NOT NULL,
    cusState VARCHAR2(50) NOT NULL,
    cusCountry VARCHAR2(50) NOT NULL,
    PRIMARY KEY (customerID),
    FOREIGN KEY (marketID) REFERENCES market(marketID) ON DELETE CASCADE
);

-- Sales Table
CREATE TABLE sales (
    salesID VARCHAR2(35) NOT NULL,
    customerID VARCHAR2(35) NOT NULL,
    shippingID NUMBER NOT NULL,
    salesAmount NUMBER(10,2) NOT NULL,
    quantity NUMBER NOT NULL,
    discount NUMBER(3,2) NOT NULL,
    profit NUMBER(10,2) NOT NULL,
    PRIMARY KEY (salesID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID),
    FOREIGN KEY (shippingID) REFERENCES shipping(shippingID) ON DELETE CASCADE
);

-- Product Table
CREATE TABLE product (
    productID VARCHAR2(35) NOT NULL,
    productName VARCHAR2(155) NOT NULL,
    productCategory VARCHAR2(50) NOT NULL,
    subCategory VARCHAR2(50) NOT NULL,
    PRIMARY KEY (productID)
);

-- Orders Table
CREATE TABLE orders (
    orderID VARCHAR2(35) NOT NULL,
    salesID VARCHAR2(35) NOT NULL,
    productID VARCHAR2(35) NOT NULL,
    orderDate DATE DEFAULT SYSDATE NOT NULL,
    orderPriority VARCHAR2(50) NOT NULL,
    PRIMARY KEY (orderID),
    FOREIGN KEY (salesID) REFERENCES sales(salesID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES product(productID)
);


-- Index on CustomerID for faster lookups in the Shipping table based on CustomerID
CREATE INDEX idx_shipping_customerid ON Shipping(CustomerID);

-- Index on CustomerName for faster searches based on CustomerName
CREATE INDEX idx_customer_name ON Customer(CustomerName);

-- Index on OrderPriority for faster lookups in the OrderItem table based on OrderPriority
CREATE INDEX idx_orderitem_orderpriority ON OrderItem(OrderPriority);

-- Index on ProductID for faster lookups in the OrderItem table based on ProductID
CREATE INDEX idx_orderitem_productid ON OrderItem(ProductID);

