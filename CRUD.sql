--Read Operation
SET SERVEROUTPUT ON;

DECLARE
    v_ShippingID Shipping.ShippingID%TYPE;
    v_ColumnName VARCHAR2(50);
    v_ColumnValue VARCHAR2(4000);
    v_Count NUMBER;

    -- Variables to hold row data if entire row is requested
    v_OrderID Shipping.OrderID%TYPE;
    v_OrderDate Shipping.OrderDate%TYPE;
    v_ShipDate Shipping.ShipDate%TYPE;
    v_ShipMode Shipping.ShipMode%TYPE;
    v_CustomerID Shipping.CustomerID%TYPE;

BEGIN
    -- Prompt the user to enter the ShippingID
    v_ShippingID := '&ShippingID';

    -- Validate if ShippingID exists in the Shipping table
    SELECT COUNT(*)
    INTO v_Count
    FROM Shipping
    WHERE ShippingID = v_ShippingID;

    IF v_Count = 0 THEN
        -- ShippingID not found, terminate the block
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' is not found.');
    END IF;

    -- Prompt the user to enter the column name
  v_ColumnName := UPPER('&Column_Name_or_ALL');

    -- Check if the user requested the entire row or a specific column
    IF v_ColumnName = 'ALL' THEN
        -- Retrieve the entire row related to the ShippingID
        SELECT OrderID, OrderDate, ShipDate, ShipMode, CustomerID
        INTO v_OrderID, v_OrderDate, v_ShipDate, v_ShipMode, v_CustomerID
        FROM Shipping
        WHERE ShippingID = v_ShippingID;

        -- Output the entire row
        DBMS_OUTPUT.PUT_LINE('OrderID: ' || v_OrderID);
        DBMS_OUTPUT.PUT_LINE('OrderDate: ' || v_OrderDate);
        DBMS_OUTPUT.PUT_LINE('ShipDate: ' || v_ShipDate);
        DBMS_OUTPUT.PUT_LINE('ShipMode: ' || v_ShipMode);
        DBMS_OUTPUT.PUT_LINE('CustomerID: ' || v_CustomerID);
    ELSE
        BEGIN
            -- Attempt to retrieve the specific column related to the ShippingID
            EXECUTE IMMEDIATE 'SELECT ' || v_ColumnName || ' FROM Shipping WHERE ShippingID = :1'
            INTO v_ColumnValue
            USING v_ShippingID;

            -- Output the specific column value
            DBMS_OUTPUT.PUT_LINE(v_ColumnName || ': ' || v_ColumnValue);
        EXCEPTION
            WHEN OTHERS THEN
                -- Handle the case where the column does not exist
                DBMS_OUTPUT.PUT_LINE('Column: ' || v_ColumnName || ' is not found.');
        END;
    END IF;

END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Operation
DECLARE
    v_ShippingID Shipping.ShippingID%TYPE;
    v_ColumnName VARCHAR2(30);
    v_NewValue VARCHAR2(100); -- Adjust size as needed
    v_Count NUMBER;
    v_ColumnExists NUMBER;
BEGIN
    -- Prompt the user to enter the ShippingID
    v_ShippingID := &Shipping_ID;

    -- Validate if ShippingID exists in the Shipping table
    SELECT COUNT(*)
    INTO v_Count
    FROM Shipping
    WHERE ShippingID = v_ShippingID;

    -- Set a savepoint before performing any operations
    SAVEPOINT before_update;

    IF v_Count = 0 THEN
        -- ShippingID not found, rollback to the savepoint and terminate the block
        ROLLBACK TO before_update;
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' is not found.');
        RETURN;
    END IF;

    -- Prompt the user to enter the column name to update
    v_ColumnName := UPPER('&Column_Name');

    -- Validate if the specified column exists in the Shipping table
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = ''SHIPPING'' AND COLUMN_NAME = ''' || v_ColumnName || ''''
        INTO v_ColumnExists;

        IF v_ColumnExists = 0 THEN
            -- Column not found, rollback to the savepoint and terminate the block
            ROLLBACK TO before_update;
            DBMS_OUTPUT.PUT_LINE('Column: ' || v_ColumnName || ' does not exist in the Shipping table.');
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any unexpected errors
            ROLLBACK TO before_update;
            DBMS_OUTPUT.PUT_LINE('An error occurred while validating the column: ' || SQLERRM);
            RETURN;
    END;

    -- Prompt the user to enter the new value
    v_NewValue := '&New_Value';
    -- Update the row with the given ShippingID
    BEGIN
        IF v_ColumnName = 'ORDERDATE' OR v_ColumnName = 'SHIPDATE' THEN
            v_NewValue := TO_DATE(v_NewValue, 'YYYY-MM-DD');
        END IF;
        EXECUTE IMMEDIATE 'UPDATE Shipping SET ' || v_ColumnName || ' = :1 WHERE ShippingID = :2'
        USING v_NewValue, v_ShippingID;

        -- Commit the transaction to save changes
        COMMIT;

        -- Confirm the update
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' has been successfully updated. Column: ' || v_ColumnName || ' set to: ' || v_NewValue);
    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any unexpected errors and rollback to the savepoint
            ROLLBACK TO before_update;
            DBMS_OUTPUT.PUT_LINE('An error occurred during the update: ' || SQLERRM);
    END;

END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Operation
DECLARE
    v_ShippingID Shipping.ShippingID%TYPE;
    v_Count NUMBER;
BEGIN
    -- Prompt the user to enter the ShippingID
    v_ShippingID := &Shipping_ID;

    -- Validate if ShippingID exists in the Shipping table
    SELECT COUNT(*)
    INTO v_Count
    FROM Shipping
    WHERE ShippingID = v_ShippingID;

    -- Set a savepoint before performing the delete operation
    SAVEPOINT before_delete;

    IF v_Count = 0 THEN
        -- ShippingID not found, rollback to the savepoint and terminate the block
        ROLLBACK TO before_delete;
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' is not found.');
        RETURN;
    ELSE
        -- Deliberate error for testing rollback (e.g., divide by zero)
        DECLARE
            v_Test NUMBER;
        BEGIN
            v_Test := 1 / 0; -- This will cause an exception
        EXCEPTION
            WHEN OTHERS THEN
                -- Handle the error and rollback to the savepoint
                ROLLBACK TO before_delete;
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        END;

        -- Delete the row with the given ShippingID (should not reach here due to error above)
        DELETE FROM Shipping
        WHERE ShippingID = v_ShippingID;

        -- Commit the transaction to save changes
        COMMIT;

        -- Confirm the deletion
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' has been successfully deleted.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Handle any unexpected errors
        ROLLBACK TO before_delete;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
