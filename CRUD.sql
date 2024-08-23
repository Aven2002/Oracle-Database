-- Enable output for DBMS_OUTPUT
SET SERVEROUTPUT ON;


-- Prompt for Customer Details
ACCEPT p_CustomerFirstName PROMPT 'Enter Customer First Name: ';
ACCEPT p_CustomerLastName PROMPT 'Enter Customer Last Name: ';
ACCEPT p_Segment PROMPT 'Enter Segment (Consumer/Corporate/Home Office): ';
ACCEPT p_City PROMPT 'Enter City: ';
ACCEPT p_State PROMPT 'Enter State: ';
ACCEPT p_Country PROMPT 'Enter Country: ';
ACCEPT p_Market PROMPT 'Enter Market (Africa/APAC/Canada/EMEA/EU/LATAM/US): ';
ACCEPT p_Region PROMPT 'Enter Region: ';

-- Prompt for Shipping Details
ACCEPT p_ShipDate PROMPT 'Enter Ship Date (YYYY-MM-DD): ';
ACCEPT p_ShipMode PROMPT 'Enter Ship Mode (Same Day/Standard Class/First Class/Second Class): ';

-- Prompt for Product Details
ACCEPT p_Category PROMPT 'Enter Product Category: ';
ACCEPT p_SubCategory PROMPT 'Enter Product SubCategory: ';
ACCEPT p_ProductName PROMPT 'Enter Product Name: ';

-- Prompt for OrderItem Details
ACCEPT p_salesAmount PROMPT 'Enter Sales Amount: ';
ACCEPT p_Quantity PROMPT 'Enter Quantity: ';
ACCEPT p_Discount PROMPT 'Enter Discount (e.g., 0.10 = 10%): ';
ACCEPT p_Profit PROMPT 'Enter Profit: ';
ACCEPT p_ShippingCost PROMPT 'Enter Shipping Cost: ';
ACCEPT p_OrderPriority PROMPT 'Enter Order Priority (Low/Medium/High/Critical): ';

-- Declare variables to hold the generated IDs
VARIABLE v_CustomerID VARCHAR2(50);
VARIABLE v_ShippingID NUMBER;
VARIABLE v_ProductID VARCHAR2(50);
VARIABLE v_OrderID VARCHAR2(50);

-- Call the Insert_Records procedure with the collected inputs
BEGIN
    Insert_Records(
        '&p_CustomerFirstName', '&p_CustomerLastName', '&p_Segment', '&p_City', '&p_State', '&p_Country', '&p_Market', '&p_Region',
        TO_DATE('&p_ShipDate', 'YYYY-MM-DD'), '&p_ShipMode',
        '&p_Category', '&p_SubCategory', '&p_ProductName',
        &p_salesAmount, &p_Quantity, &p_Discount, &p_Profit, &p_ShippingCost, '&p_OrderPriority',
        :v_CustomerID, :v_ShippingID, :v_ProductID, :v_OrderID
    );
END;
/

-- Display the generated IDs and entered details
BEGIN
    DBMS_OUTPUT.PUT_LINE('Generated Customer ID: ' || :v_CustomerID);
    DBMS_OUTPUT.PUT_LINE('Customer Details');
    DBMS_OUTPUT.PUT_LINE('First Name: ' || '&p_CustomerFirstName');
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || '&p_CustomerLastName');
    DBMS_OUTPUT.PUT_LINE('Segment: ' || '&p_Segment');
    DBMS_OUTPUT.PUT_LINE('City: ' || '&p_City');
    DBMS_OUTPUT.PUT_LINE('State: ' || '&p_State');
    DBMS_OUTPUT.PUT_LINE('Country: ' || '&p_Country');
    DBMS_OUTPUT.PUT_LINE('Market: ' || '&p_Market');
    DBMS_OUTPUT.PUT_LINE('Region: ' || '&p_Region');
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Generated Shipping ID: ' || :v_ShippingID);
    DBMS_OUTPUT.PUT_LINE('Shipping Details');
    DBMS_OUTPUT.PUT_LINE('Ship Date: ' || '&p_ShipDate');
    DBMS_OUTPUT.PUT_LINE('Ship Mode: ' || '&p_ShipMode');
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Generated Product ID: ' || :v_ProductID);
    DBMS_OUTPUT.PUT_LINE('Product Details');
    DBMS_OUTPUT.PUT_LINE('Category: ' || '&p_Category');
    DBMS_OUTPUT.PUT_LINE('SubCategory: ' || '&p_SubCategory');
    DBMS_OUTPUT.PUT_LINE('Product Name: ' || '&p_ProductName');
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Generated Order ID: ' || :v_OrderID);
    DBMS_OUTPUT.PUT_LINE('OrderItem Details');
    DBMS_OUTPUT.PUT_LINE('Sales Amount: ' || &p_salesAmount);
    DBMS_OUTPUT.PUT_LINE('Quantity: ' || &p_Quantity);
    DBMS_OUTPUT.PUT_LINE('Discount: ' || &p_Discount || '%');
    DBMS_OUTPUT.PUT_LINE('Profit: ' || &p_Profit);
    DBMS_OUTPUT.PUT_LINE('Shipping Cost: ' || &p_ShippingCost);
    DBMS_OUTPUT.PUT_LINE('Order Priority: ' || '&p_OrderPriority');
END;
/


SET SERVEROUTPUT ON;

create or replace PROCEDURE Insert_Records (
   -- Customer Table Inputs
    p_CustomerFirstName IN VARCHAR2,
    p_CustomerLastName IN VARCHAR2,
    p_Segment IN VARCHAR2,
    p_City IN VARCHAR2,
    p_State IN VARCHAR2,
    p_Country IN VARCHAR2,
    p_Market IN VARCHAR2,
    p_Region IN VARCHAR2,

    -- Shipping Table Inputs
    p_ShipDate IN DATE,
    p_ShipMode IN VARCHAR2,

    -- Product Table Inputs
    p_Category IN VARCHAR2,
    p_SubCategory IN VARCHAR2,
    p_ProductName IN VARCHAR2,

    -- OrderItem Table Inputs
    p_salesAmount IN NUMBER,
    p_Quantity IN NUMBER,
    p_Discount IN NUMBER,
    p_Profit IN NUMBER,
    p_ShippingCost IN NUMBER,
    p_OrderPriority IN VARCHAR2,

    -- OUT Parameters for Generated IDs
    o_CustomerID OUT VARCHAR2,
    o_ShippingID OUT NUMBER,
    o_ProductID OUT VARCHAR2,
    o_OrderID OUT VARCHAR2
) AS
BEGIN
    -- Start a transaction
    SAVEPOINT Before_Insert;



    BEGIN
        -- Auto-generate CustomerID
        SELECT UPPER(SUBSTR(p_CustomerFirstName, 1, 1)) || 
               UPPER(SUBSTR(p_CustomerLastName, 1, 1)) || 
               '-' || 
               LPAD(NVL(MAX(TO_NUMBER(SUBSTR(CustomerID, 4))), 0) + 1, 5, '0')
        INTO o_CustomerID
        FROM Customer
        WHERE CustomerID LIKE UPPER(SUBSTR(p_CustomerFirstName, 1, 1)) || 
                         UPPER(SUBSTR(p_CustomerLastName, 1, 1)) || '-%';

        -- Insert into Customer table
        BEGIN
            INSERT INTO Customer (
                CustomerID, CustomerName, Segment, City, State, Country, Market, Region
            ) VALUES (
                o_CustomerID, p_CustomerFirstName || ' ' || p_CustomerLastName, p_Segment, p_City, p_State, p_Country, p_Market, p_Region
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Insert;
                DBMS_OUTPUT.PUT_LINE('Customer Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Auto-generate ShippingID
        SELECT NVL(MAX(ShippingID), 0) + 1 INTO o_ShippingID FROM Shipping;

        -- Auto-generate ProductID using a sequence for the last 8 digits
        o_ProductID := UPPER(SUBSTR(p_Category, 1, 3)) || '-' || 
                      UPPER(SUBSTR(p_ProductName, 1, 3)) || '-' || 
                      LPAD(ProductID_Seq.NEXTVAL, 8, '0');

        -- Insert into Product table
        BEGIN
            INSERT INTO Product (
                ProductID, Category, SubCategory, ProductName
            ) VALUES (
                o_ProductID, p_Category, p_SubCategory, p_ProductName
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Insert;
                DBMS_OUTPUT.PUT_LINE('Product Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Auto-generate OrderID
        SELECT UPPER(SUBSTR(p_Country, 1, 2)) || '-' || 
               TO_CHAR(SYSDATE, 'YYYY') || '-' || 
               LPAD(NVL(MAX(TO_NUMBER(SUBSTR(OrderID, 9))), 0) + 1, 4, '0')
        INTO o_OrderID
        FROM OrderItem
        WHERE OrderID LIKE UPPER(SUBSTR(p_Country, 1, 2)) || 
                      '-' || TO_CHAR(SYSDATE, 'YYYY') || '-%';

        -- Insert into OrderItem table
        BEGIN
            INSERT INTO OrderItem (
                OrderID, ProductID, SalesAmount, Quantity, Discount, Profit, ShippingCost, OrderPriority
            ) VALUES (
                o_OrderID, o_ProductID, p_salesAmount, p_Quantity, p_Discount, p_Profit, p_ShippingCost, p_OrderPriority
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Insert;
                DBMS_OUTPUT.PUT_LINE('OrderItem Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Insert into Shipping table
        BEGIN
            INSERT INTO Shipping (
                ShippingID, OrderID, OrderDate, ShipDate, ShipMode, CustomerID
            ) VALUES (
                o_ShippingID, o_OrderID, TRUNC(SYSDATE), p_ShipDate, p_ShipMode, o_CustomerID
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Insert;
                DBMS_OUTPUT.PUT_LINE('Shipping Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Commit the transaction
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Records inserted successfully.');

    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback to the initial savepoint if an error occurs in any part of the transaction
            ROLLBACK TO Before_Insert;
            DBMS_OUTPUT.PUT_LINE('Transaction Error: ' || SQLERRM);
    END;
END;




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
