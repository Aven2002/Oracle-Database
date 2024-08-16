-- Create Sequences for auto-increment functionality
CREATE SEQUENCE sales_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE shipping_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Tables

-- Market Table
CREATE TABLE market (
    marketID VARCHAR2(10) NOT NULL,
    marketRegion VARCHAR2(35) NOT NULL,
    PRIMARY KEY (marketID)
);

-- Shipping Table
CREATE TABLE shipping (
    shippingID NUMBER NOT NULL,
    shippingDate DATE NOT NULL,
    shippingMode VARCHAR2(35) NOT NULL,
    shippingCost NUMBER(10,2) NOT NULL,
    PRIMARY KEY (shippingID)
);

-- Customer Table
CREATE TABLE customer (
    customerID VARCHAR2(10) NOT NULL,
    marketID VARCHAR2(10) NOT NULL,
    cusName VARCHAR2(50) NOT NULL,
    cusSegment VARCHAR2(50) NOT NULL,
    cusCity VARCHAR2(30) NOT NULL,
    cusState VARCHAR2(30) NOT NULL,
    cusCountry VARCHAR2(30) NOT NULL,
    PRIMARY KEY (customerID),
    FOREIGN KEY (marketID) REFERENCES market(marketID) ON DELETE CASCADE
);

-- Product Table
CREATE TABLE product (
    productID VARCHAR2(10) NOT NULL,
    productName VARCHAR2(50) NOT NULL,
    productCategory VARCHAR2(50) NOT NULL,
    subCategory VARCHAR2(50) NOT NULL,
    PRIMARY KEY (productID)
);
-- Sales Table
CREATE TABLE sales (
    salesID NUMBER NOT NULL,
    customerID VARCHAR2(10) NOT NULL,
    productID VARCHAR2(10) NOT NULL,
    salesAmount NUMBER(10,2) NOT NULL,
    quantity NUMBER NOT NULL,
    discount NUMBER(3,2) NOT NULL,
    profit NUMBER(10,2) NOT NULL,
    PRIMARY KEY (salesID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE
);

-- Orders Table
CREATE TABLE orders (
    orderID VARCHAR2(10) NOT NULL,
    salesID NUMBER NOT NULL,
    shippingID NUMBER NOT NULL,
    orderDate DATE NOT NULL,
    orderPriority VARCHAR2(35) NOT NULL,
    PRIMARY KEY (orderID),
    FOREIGN KEY (salesID) REFERENCES sales(salesID) ON DELETE CASCADE,
    FOREIGN KEY (shippingID) REFERENCES shipping(shippingID) ON DELETE CASCADE
);



-- Create Triggers for auto-increment functionality

-- Trigger for Sales Table
CREATE OR REPLACE TRIGGER sales_before_insert
BEFORE INSERT ON sales
FOR EACH ROW
BEGIN
    IF :NEW.salesID IS NULL THEN
        SELECT sales_seq.NEXTVAL INTO :NEW.salesID FROM dual;
    END IF;
END;
/

-- Trigger for Shipping Table
CREATE OR REPLACE TRIGGER shipping_before_insert
BEFORE INSERT ON shipping
FOR EACH ROW
BEGIN
    IF :NEW.shippingID IS NULL THEN
        SELECT shipping_seq.NEXTVAL INTO :NEW.shippingID FROM dual;
    END IF;
END;
/


-- Drop tables
DROP TABLE shipping CASCADE CONSTRAINTS;
DROP TABLE sales CASCADE CONSTRAINTS;
DROP TABLE product CASCADE CONSTRAINTS;
DROP TABLE market CASCADE CONSTRAINTS;
DROP TABLE customer CASCADE CONSTRAINTS;
DROP TABLE orders;


-- Display data in a row 
SELECT 
    o.orderID,
    o.orderDate,
    o.orderPriority,
    s.salesID,
    s.salesAmount,
    s.quantity,
    s.discount,
    s.profit,
    c.customerID,
    c.cusName,
    c.cusSegment,
    c.cusCity,
    c.cusState,
    c.cusCountry,
    p.productID,
    p.productName,
    p.productCategory,
    p.subCategory,
    sh.shippingID,
    sh.shippingDate,
    sh.shippingMode,
    sh.shippingCost
FROM 
    orders o
JOIN 
    sales s ON o.salesID = s.salesID
JOIN 
    customer c ON s.customerID = c.customerID
JOIN 
    product p ON s.productID = p.productID
JOIN 
    shipping sh ON o.shippingID = sh.shippingID;
