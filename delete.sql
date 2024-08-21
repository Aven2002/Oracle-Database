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
        DBMS_OUTPUT.PUT_LINE('Shipping ID: ' || v_ShippingID || ' is not found. Operation cancelled.');
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