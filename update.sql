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
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' is not found. Operation cancelled.');
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
