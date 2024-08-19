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
