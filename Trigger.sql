-- Create Shipping_audit_seq

CREATE TABLE shipping_audit (
    auditID NUMBER PRIMARY KEY,
    shippingID NUMBER,
    shipDate DATE,
    shipMode VARCHAR2(35),
    action VARCHAR2(10),
    actionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customerID VARCHAR2(200),
    orderID VARCHAR2(35),
    orderDate DATE,
);

-- Create Sequence for Shipping Audit
CREATE SEQUENCE shipping_audit_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Trigger for Shipping Audit
CREATE OR REPLACE TRIGGER shipping_audit_id_trigger
BEFORE INSERT ON shipping_audit
FOR EACH ROW
BEGIN
    :NEW.auditID := shipping_audit_seq.NEXTVAL;
END;
/
 

----------------------------------------------------------------------------------------------------------

-- SHIPPING_AFTER_DELETE
create or replace TRIGGER shipping_after_delete
AFTER INSERT OR UPDATE OR DELETE ON shipping
FOR EACH ROW
BEGIN
    
    IF DELETING THEN
        INSERT INTO shipping_audit (auditID, shippingID, orderID, orderDate, shipDate, shipMode, customerID, action)
        VALUES (shipping_audit_seq.NEXTVAL, :OLD.shippingID, :OLD.orderID, :OLD.orderDate, :OLD.shipDate, :OLD.shipMode, :OLD.customerID, 'DELETE');
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHIPPING_AFTER_INSERT_UPDATE
create or replace TRIGGER shipping_after_Insert_Update
AFTER INSERT OR UPDATE on shipping
FOR EACH ROW
BEGIN
    --- Will insert into the audit table
    IF INSERTING THEN
        INSERT INTO shipping_audit (auditID, shippingID, orderID, orderDate, shipDate, shipMode, customerID, action)
        VALUES (shipping_audit_seq.NEXTVAL, :NEW.shippingID, :NEW.orderID, :NEW.orderDate, :NEW.shipDate, :NEW.shipMode, :NEW.customerID, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO shipping_audit (auditID, shippingID, orderID, orderDate, shipDate, shipMode, customerID, action)
        VALUES (shipping_audit_seq.NEXTVAL, :NEW.shippingID, :NEW.orderID, :NEW.orderDate, :NEW.shipDate, :NEW.shipMode, :NEW.customerID, 'UPDATE');
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHIPPING_BEFORE_INPUT_UPDATE
-- For Shipping Table
create or replace TRIGGER shipping_before_Input_Update
BEFORE INSERT OR UPDATE ON shipping
FOR EACH ROW
BEGIN
    -- Validate ShipDate and ShipMode
    IF INSERTING THEN
        IF :NEW.shipDate IS NULL OR :NEW.shipDate < :NEW.orderDate THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid shipping date. Shipping needs to be after order date: ' || TO_CHAR(:NEW.shipDate, 'DD-MON-YYYY HH24:MI:SS') || ' - ' || TO_CHAR(:NEW.orderDate, 'DD-MON-YYYY HH24:MI:SS'));

        ELSIF :NEW.shipDate < TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid shipping date. The date is too far in the past.');
        ELSIF :NEW.shipMode NOT IN ('Same Day', 'Standard Class', 'First Class', 'Second Class') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid shipping mode. Allowed values are Same Day, Standard Class, First Class, Second Class.');
        END IF;
        
        

    ELSIF UPDATING THEN
        IF :NEW.shipDate IS NULL OR :NEW.shipDate < :NEW.orderDate OR :NEW.shipDate < :OLD.orderDate OR :OLD.shipDate < :NEW.orderDate THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid shipping date. Shipping need to be after order date');
        ELSIF :NEW.shipDate < TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid shipping date. The date is too far in the past.');
        END IF;

        IF :NEW.shipMode IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid shipping mode. Shipping mode cannot be NULL.');
        ELSIF :NEW.shipMode NOT IN ('Same Day', 'Standard Class', 'First Class', 'Second Class') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid shipping mode. Allowed values are Same Day, Standard Class, First Class, Second Class.');
        END IF;
    END IF;  -- End of INSERTING/UPDATING block
END;
-- For OrderItem Table
create or replace TRIGGER orderItem_before_Input_Update
BEFORE INSERT OR UPDATE ON orderItem
FOR EACH ROW
BEGIN
    -- Validate Quantity, SalesAmount, and Discount for Inserts
    IF INSERTING THEN
        IF :NEW.quantity < 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Invalid quantity. Quantity cannot be negative.');
        ELSIF :NEW.salesAmount < 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Invalid sales amount. Sales amount cannot be negative.');
        ELSIF :NEW.discount > 1.0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Invalid discount. Discount must be not exceed 100%.');
        END IF;

    -- Validate Quantity, SalesAmount, and Discount for Updates
    ELSIF UPDATING THEN
        IF :NEW.quantity < 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Invalid quantity. Quantity cannot be negative.');
        ELSIF :NEW.salesAmount < 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Invalid sales amount. Sales amount cannot be negative.');
        ELSIF :NEW.discount > 1.0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Invalid discount. Discount must be not exceed 100%.');
        END IF;
    END IF;  -- End of INSERTING/UPDATING block
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHIPPING_BEFORE_DELETE
create or replace TRIGGER shipping_before_delete
BEFORE DELETE ON shipping
FOR EACH ROW

DECLARE
    order_count NUMBER;
BEGIN
    -- change to user admin username
    IF USER != 'wx' THEN
        RAISE_APPLICATION_ERROR(-20006, 'Only admin can delete orders.');
    END IF;
END;