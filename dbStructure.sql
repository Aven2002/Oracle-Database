-- Create Tables
-- Orders Table
CREATE TABLE orders (
    orderID VARCHAR2(10) NOT NULL,
    orderDate DATE NOT NULL,
    orderPriority VARCHAR2(50) NOT NULL,
    PRIMARY KEY (orderID)
);

-- Sales Table
CREATE TABLE sales (
    salesID VARCHAR2(10) NOT NULL,
    orderID VARCHAR2(10) NOT NULL,
    salesAmount NUMBER(10,2) NOT NULL,
    quantity NUMBER NOT NULL,
    discount NUMBER(3,2) NOT NULL,
    profit NUMBER(10,2) NOT NULL,
    PRIMARY KEY (salesID),
    FOREIGN KEY (orderID) REFERENCES orders(orderID) ON DELETE CASCADE
);

-- Shipping Table
CREATE TABLE shipping (
    shippingID VARCHAR2(10) NOT NULL,
    salesID VARCHAR2(10) NOT NULL,
    shippingDate DATE NOT NULL,
    shippingMode VARCHAR2(50) NOT NULL,
    shippingCost NUMBER(10,2) NOT NULL,
    PRIMARY KEY (shippingID),
    FOREIGN KEY (salesID) REFERENCES sales(salesID) ON DELETE CASCADE
);

-- Customer Table
CREATE TABLE customer (
    customerID VARCHAR2(10) NOT NULL,
    salesID VARCHAR2(10) NOT NULL,
    cusName VARCHAR2(50) NOT NULL,
    cusSegment VARCHAR2(50) NOT NULL,
    cusCity VARCHAR2(50) NOT NULL,
    cusState VARCHAR2(50) NOT NULL,
    cusCountry VARCHAR2(50) NOT NULL,
    PRIMARY KEY (customerID),
    FOREIGN KEY (salesID) REFERENCES sales(salesID) ON DELETE CASCADE
);

-- Market Table
CREATE TABLE market (
    marketID VARCHAR2(10) NOT NULL,
    customerID VARCHAR2(10) NOT NULL,
    marketRegion VARCHAR2(50) NOT NULL,
    PRIMARY KEY (marketID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE
);

-- Product Table
CREATE TABLE product (
    productID VARCHAR2(10) NOT NULL,
    salesID VARCHAR2(10) NOT NULL,
    productName VARCHAR2(50) NOT NULL,
    productCategory VARCHAR2(50) NOT NULL,
    subCategory VARCHAR2(50) NOT NULL,
    PRIMARY KEY (productID)
);

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

-- Create Triggers for auto-increment functionality
-- Trigger for Sales Table with custom ID format
CREATE OR REPLACE TRIGGER sales_before_insert
BEFORE INSERT ON sales
FOR EACH ROW
BEGIN
    IF :NEW.salesID IS NULL THEN
        SELECT 'sal_' || TO_CHAR(sales_seq.NEXTVAL, 'FM00000') 
        INTO :NEW.salesID 
        FROM dual;
    END IF;
END;
/

-- Trigger for Shipping Table with custom ID format
CREATE OR REPLACE TRIGGER shipping_before_insert
BEFORE INSERT ON shipping
FOR EACH ROW
BEGIN
    IF :NEW.shippingID IS NULL THEN
        SELECT 'ship_' || TO_CHAR(shipping_seq.NEXTVAL, 'FM00000') 
        INTO :NEW.shippingID 
        FROM dual;
    END IF;
END;
/


