*********************

remember to change the testing to your user name
part 1 is create table for audit
part 2 is to add the after triggers
part 3 is to add the before triggers for deleting

*********************

------------------------------------create the audit table with seq and before row insert------------------------------------------------
-- Create Sales Audit Table
CREATE TABLE testing.sales_audit (
    auditID NUMBER PRIMARY KEY,
    salesID NUMBER NOT NULL,
    marketID VARCHAR2(10),
    salesAmount NUMBER(10,2),
    quantity NUMBER,
    discount NUMBER(3,2),
    profit NUMBER(10,2),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE SEQUENCE testing.sales_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Auto-Incrementing auditID
CREATE OR REPLACE TRIGGER testing.sales_audit_id_trigger
BEFORE INSERT ON testing.sales_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := testing.sales_audit_seq.NEXTVAL;
END;
/
-- Create Market Audit Table
CREATE TABLE testing.market_audit (
    auditID NUMBER PRIMARY KEY,
    marketID VARCHAR2(10),
    marketRegion VARCHAR2(35),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sequence for Market Audit
CREATE SEQUENCE testing.market_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Market Audit
CREATE OR REPLACE TRIGGER testing.market_audit_id_trigger
BEFORE INSERT ON testing.market_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := testing.market_audit_seq.NEXTVAL;
END;
/
-- Create Customer Audit Table
CREATE TABLE testing.customer_audit (
    auditID NUMBER PRIMARY KEY,
    customerID VARCHAR2(30),
    marketID VARCHAR2(10),
    cusName VARCHAR2(45),
    cusSegment VARCHAR2(45),
    city VARCHAR2(30),
    state VARCHAR2(30),
    country VARCHAR2(30),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sequence for Customer Audit
CREATE SEQUENCE testing.customer_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Customer Audit
CREATE OR REPLACE TRIGGER testing.customer_audit_id_trigger
BEFORE INSERT ON testing.customer_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := testing.customer_audit_seq.NEXTVAL;
END;
/
-- Create Product Audit Table
CREATE TABLE testing.product_audit (
    auditID NUMBER PRIMARY KEY,
    productID VARCHAR2(30),
    productName VARCHAR2(50),
    productCategory VARCHAR2(50),
    subCategory VARCHAR2(50),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sequence for Product Audit
CREATE SEQUENCE testing.product_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Product Audit
CREATE OR REPLACE TRIGGER testing.product_audit_id_trigger
BEFORE INSERT ON testing.product_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := testing.product_audit_seq.NEXTVAL;
END;
/
-- Create Shipping Audit Table
CREATE TABLE testing.shipping_audit (
    auditID NUMBER PRIMARY KEY,
    shippingID NUMBER,
    salesID NUMBER,
    shippingDate DATE,
    shippingMode VARCHAR2(35),
    shippingCost NUMBER(10,2),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sequence for Shipping Audit
CREATE SEQUENCE testing.shipping_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Shipping Audit
CREATE OR REPLACE TRIGGER testing.shipping_audit_id_trigger
BEFORE INSERT ON testing.shipping_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := testing.shipping_audit_seq.NEXTVAL;
END;
/
-- Create Orders Audit Table
CREATE TABLE testing.orders_audit (
    auditID NUMBER PRIMARY KEY,
    orderID VARCHAR2(35),
    shippingID NUMBER,
    orderDate DATE,
    orderPriority VARCHAR2(35),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sequence for Orders Audit
CREATE SEQUENCE testing.orders_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Orders Audit
CREATE OR REPLACE TRIGGER testing.orders_audit_id_trigger
BEFORE INSERT ON testing.orders_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := testing.orders_audit_seq.NEXTVAL;
END;
/
------------------------------------end part1------------------------------------------------

------------------------------------Create After Row-Level Trigger for all table update, insert, delete into audit table ------------------------------------------------

CREATE OR REPLACE TRIGGER testing.sales_audit_trigger
AFTER INSERT OR DELETE OR UPDATE ON testing.sales
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO testing.sales_audit (salesID, marketID, salesAmount, quantity, discount, profit, action)
        VALUES (:NEW.salesID, :NEW.marketID, :NEW.salesAmount, :NEW.quantity, :NEW.discount, :NEW.profit, 'INSERT');
    ELSIF DELETING THEN
        INSERT INTO testing.sales_audit (salesID, marketID, salesAmount, quantity, discount, profit, action)
        VALUES (:OLD.salesID, :OLD.marketID, :OLD.salesAmount, :OLD.quantity, :OLD.discount, :OLD.profit, 'DELETE');
    ELSIF UPDATING THEN
        INSERT INTO testing.sales_audit (salesID, marketID, salesAmount, quantity, discount, profit, action)
        VALUES (:NEW.salesID, :NEW.marketID, :NEW.salesAmount, :NEW.quantity, :NEW.discount, :NEW.profit, 'UPDATE');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER testing.market_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON testing.market
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO testing.market_audit (auditID, marketID, marketRegion, action)
        VALUES (testing.market_audit_seq.NEXTVAL, :NEW.marketID, :NEW.marketRegion, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO testing.market_audit (auditID, marketID, marketRegion, action)
        VALUES (testing.market_audit_seq.NEXTVAL, :NEW.marketID, :NEW.marketRegion, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO testing.market_audit (auditID, marketID, marketRegion, action)
        VALUES (testing.market_audit_seq.NEXTVAL, :OLD.marketID, :OLD.marketRegion, 'DELETE');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER testing.customer_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON testing.customer
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO testing.customer_audit (auditID, customerID, marketID, cusName, cusSegment, city, state, country, action)
        VALUES (testing.customer_audit_seq.NEXTVAL, :NEW.customerID, :NEW.marketID, :NEW.cusName, :NEW.cusSegment, :NEW.city, :NEW.state, :NEW.country, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO testing.customer_audit (auditID, customerID, marketID, cusName, cusSegment, city, state, country, action)
        VALUES (testing.customer_audit_seq.NEXTVAL, :NEW.customerID, :NEW.marketID, :NEW.cusName, :NEW.cusSegment, :NEW.city, :NEW.state, :NEW.country, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO testing.customer_audit (auditID, customerID, marketID, cusName, cusSegment, city, state, country, action)
        VALUES (testing.customer_audit_seq.NEXTVAL, :OLD.customerID, :OLD.marketID, :OLD.cusName, :OLD.cusSegment, :OLD.city, :OLD.state, :OLD.country, 'DELETE');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER testing.product_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON testing.product
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO testing.product_audit (auditID, productID, productName, productCategory, subCategory, action)
        VALUES (testing.product_audit_seq.NEXTVAL, :NEW.productID, :NEW.productName, :NEW.productCategory, :NEW.subCategory, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO testing.product_audit (auditID, productID, productName, productCategory, subCategory, action)
        VALUES (testing.product_audit_seq.NEXTVAL, :NEW.productID, :NEW.productName, :NEW.productCategory, :NEW.subCategory, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO testing.product_audit (auditID, productID, productName, productCategory, subCategory, action)
        VALUES (testing.product_audit_seq.NEXTVAL, :OLD.productID, :OLD.productName, :OLD.productCategory, :OLD.subCategory, 'DELETE');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER testing.shipping_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON testing.shipping
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO testing.shipping_audit (auditID, shippingID, salesID, shippingDate, shippingMode, shippingCost, action)
        VALUES (testing.shipping_audit_seq.NEXTVAL, :NEW.shippingID, :NEW.salesID, :NEW.shippingDate, :NEW.shippingMode, :NEW.shippingCost, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO testing.shipping_audit (auditID, shippingID, salesID, shippingDate, shippingMode, shippingCost, action)
        VALUES (testing.shipping_audit_seq.NEXTVAL, :NEW.shippingID, :NEW.salesID, :NEW.shippingDate, :NEW.shippingMode, :NEW.shippingCost, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO testing.shipping_audit (auditID, shippingID, salesID, shippingDate, shippingMode, shippingCost, action)
        VALUES (testing.shipping_audit_seq.NEXTVAL, :OLD.shippingID, :OLD.salesID, :OLD.shippingDate, :OLD.shippingMode, :OLD.shippingCost, 'DELETE');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER testing.orders_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON testing.orders
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO testing.orders_audit (auditID, orderID, shippingID, orderDate, orderPriority, action)
        VALUES (testing.orders_audit_seq.NEXTVAL, :NEW.orderID, :NEW.shippingID, :NEW.orderDate, :NEW.orderPriority, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO testing.orders_audit (auditID, orderID, shippingID, orderDate, orderPriority, action)
        VALUES (testing.orders_audit_seq.NEXTVAL, :NEW.orderID, :NEW.shippingID, :NEW.orderDate, :NEW.orderPriority, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO testing.orders_audit (auditID, orderID, shippingID, orderDate, orderPriority, action)
        VALUES (testing.orders_audit_seq.NEXTVAL, :OLD.orderID, :OLD.shippingID, :OLD.orderDate, :OLD.orderPriority, 'DELETE');
    END IF;
END;
/

------------------------------------END part2------------------------------------------------

------------------------------------Create Before Row-Level Trigger for all table delete action ------------------------------------------------
-- Trigger for Market Table
create or replace TRIGGER validate_market_delete
BEFORE DELETE ON testing.market
FOR EACH ROW
DECLARE
    customer_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO customer_count FROM testing.customer WHERE marketID = :OLD.marketID;
    IF customer_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot delete market with existing customers.');
    END IF;
END;
/

-- Trigger for Shipping Table
create or replace TRIGGER validate_shipping_delete
BEFORE DELETE ON testing.shipping
FOR EACH ROW
DECLARE
    order_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO order_count FROM testing.orders WHERE shippingID = :OLD.shippingID;
    IF order_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Cannot delete shipping record that has associated orders.');
    END IF;
END;
/

-- Trigger for Orders Table
create or replace TRIGGER validate_orders_delete
BEFORE DELETE ON testing.orders
FOR EACH ROW
BEGIN
    IF USER != 'admin' THEN
        RAISE_APPLICATION_ERROR(-20006, 'Only admin can delete orders.');
    END IF;
END;
/


------------------------------------END part3------------------------------------------------
