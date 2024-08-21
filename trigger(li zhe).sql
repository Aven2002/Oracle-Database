 -- SHIPPING_AFTER_DELETE

create or replace TRIGGER Asm.shipping_after_delete
AFTER INSERT OR UPDATE OR DELETE ON Asm.shipping
FOR EACH ROW
BEGIN
    
    IF DELETING THEN
        INSERT INTO Asm.shipping_audit (auditID, shippingID, shippingDate, shippingMode, shippingCost, action)
        VALUES (Asm.shipping_audit_seq.NEXTVAL, :OLD.shippingID, :OLD.shippingDate, :OLD.shippingMode, :OLD.shippingCost, 'DELETE');
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHIPPING_AFTER_INSERT_UPDATE

create or replace TRIGGER Asm.shipping_after_Insert_Update
AFTER INSERT OR UPDATE on Asm.shipping
FOR EACH ROW
BEGIN
    --- Will insert into the audit table
    IF INSERTING THEN
        INSERT INTO Asm.shipping_audit (auditID, shippingID, shippingDate, shippingMode, shippingCost, action)
        VALUES (Asm.shipping_audit_seq.NEXTVAL, :NEW.shippingID, :NEW.shippingDate, :NEW.shippingMode, :NEW.shippingCost, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO Asm.shipping_audit (auditID, shippingID, shippingDate, shippingMode, shippingCost, action)
        VALUES (Asm.shipping_audit_seq.NEXTVAL, :NEW.shippingID, :NEW.shippingDate, :NEW.shippingMode, :NEW.shippingCost, 'UPDATE');
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHIPPING_BEFORE_INPUT_UPDATE

create or replace TRIGGER Asm.shipping_before__Input_Update
BEFORE INSERT OR UPDATE ON Asm.shipping
FOR EACH ROW
BEGIN
    -- Validate ShippingCost
    IF INSERTING THEN
        IF :NEW.shippingcost IS NULL OR :NEW.shippingcost < 0 OR :NEW.shippingcost > 10000 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid shipping cost. The value must be between 0 and 10,000.');
        END IF;

    ELSIF UPDATING THEN
        IF UPDATING AND :OLD.shippingID != :NEW.shippingID THEN
            RAISE_APPLICATION_ERROR(-20005, 'Updating shippingID is not allowed.');
        END IF;

        IF :NEW.shippingcost IS NULL OR :NEW.shippingcost < 0 OR :NEW.shippingcost > 10000 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid shipping cost. The value must be between 0 and 10,000.');
        END IF;

        IF :NEW.shippingdate IS NULL OR :NEW.shippingdate > SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid shipping date. The date cannot be in the future.');
        ELSIF :NEW.shippingdate < TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN

            RAISE_APPLICATION_ERROR(-20004, 'Invalid shipping date. The date is too far in the past.');
        END IF;

        IF :NEW.shippingmode IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid shipping mode. Shipping mode cannot be NULL.');
        ELSIF :NEW.shippingmode NOT IN ('Same Day', 'Standard Class', 'First Class', 'Second Class') THEN

            RAISE_APPLICATION_ERROR(-20003, 'Invalid shipping mode. Allowed values are Same Day, Standard Class, First Class, Second Class.');
        END IF;
    END IF;  -- End of INSERTING/UPDATING block
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- SHIPPING_BEFORE_DELETE

create or replace TRIGGER shipping_before_delete
BEFORE DELETE ON Asm.shipping
FOR EACH ROW

DECLARE
    order_count NUMBER;

BEGIN

    IF USER != 'ASM' THEN
        RAISE_APPLICATION_ERROR(-20006, 'Only admin can delete orders.');
    END IF;

END;