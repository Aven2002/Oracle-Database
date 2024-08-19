CREATE OR REPLACE PROCEDURE Insert_Records (
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
    p_Quantity IN NUMBER,
    p_Discount IN NUMBER,
    p_Profit IN NUMBER,
    p_ShippingCost IN NUMBER,
    p_OrderPriority IN VARCHAR2
) AS
    -- Variables for auto-generated IDs
    v_CustomerID VARCHAR2(50);
    v_ShippingID NUMBER;
    v_ProductID VARCHAR2(50);
    v_OrderID VARCHAR2(50);
BEGIN
    -- Start a transaction
    SAVEPOINT Before_Insert;

    BEGIN
        -- Auto-generate CustomerID
        SELECT UPPER(SUBSTR(p_CustomerFirstName, 1, 1)) || 
               UPPER(SUBSTR(p_CustomerLastName, 1, 1)) || 
               '-' || 
               LPAD(NVL(MAX(TO_NUMBER(SUBSTR(CustomerID, 4))), 0) + 1, 5, '0')
        INTO v_CustomerID
        FROM Customer
        WHERE CustomerID LIKE UPPER(SUBSTR(p_CustomerFirstName, 1, 1)) || 
                         UPPER(SUBSTR(p_CustomerLastName, 1, 1)) || '-%';

        -- Insert into Customer table
        SAVEPOINT Before_Customer_Insert;
        BEGIN
            INSERT INTO Customer (
                CustomerID, CustomerName, Segment, City, State, Country, Market, Region
            ) VALUES (
                v_CustomerID, p_CustomerFirstName || ' ' || p_CustomerLastName, p_Segment, p_City, p_State, p_Country, p_Market, p_Region
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Customer_Insert;
                DBMS_OUTPUT.PUT_LINE('Customer Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Auto-generate ShippingID
        SELECT NVL(MAX(ShippingID), 0) + 1 INTO v_ShippingID FROM Shipping;

        -- Insert into Shipping table
        SAVEPOINT Before_Shipping_Insert;
        BEGIN
            INSERT INTO Shipping (
                ShippingID, OrderID, OrderDate, ShipDate, ShipMode, CustomerID
            ) VALUES (
                v_ShippingID, v_OrderID, SYSDATE, p_ShipDate, p_ShipMode, v_CustomerID
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Shipping_Insert;
                DBMS_OUTPUT.PUT_LINE('Shipping Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Auto-generate ProductID
        SELECT UPPER(SUBSTR(p_Category, 1, 3)) || '-' || 
               UPPER(SUBSTR(p_ProductName, 1, 3)) || '-' || 
               LPAD(NVL(MAX(TO_NUMBER(SUBSTR(ProductID, 8))), 0) + 1, 8, '0')
        INTO v_ProductID
        FROM Product
        WHERE ProductID LIKE UPPER(SUBSTR(p_Category, 1, 3)) || '-' || 
                        UPPER(SUBSTR(p_ProductName, 1, 3)) || '-%';

        -- Insert into Product table
        SAVEPOINT Before_Product_Insert;
        BEGIN
            INSERT INTO Product (
                ProductID, Category, SubCategory, ProductName
            ) VALUES (
                v_ProductID, p_Category, p_SubCategory, p_ProductName
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_Product_Insert;
                DBMS_OUTPUT.PUT_LINE('Product Insert Error: ' || SQLERRM);
                RAISE;
        END;

        -- Auto-generate OrderID
        SELECT UPPER(SUBSTR(p_Country, 1, 2)) || '-' || 
               TO_CHAR(SYSDATE, 'YYYY') || '-' || 
               LPAD(NVL(MAX(TO_NUMBER(SUBSTR(OrderID, 9))), 0) + 1, 4, '0')
        INTO v_OrderID
        FROM OrderItem
        WHERE OrderID LIKE UPPER(SUBSTR(p_Country, 1, 2)) || 
                      '-' || TO_CHAR(SYSDATE, 'YYYY') || '-%';

        -- Insert into OrderItem table
        SAVEPOINT Before_OrderItem_Insert;
        BEGIN
            INSERT INTO OrderItem (
                OrderID, ProductID, SalesAmount, Quantity, Discount, Profit, ShippingCost, OrderPriority
            ) VALUES (
                v_OrderID, v_ProductID, NULL, p_Quantity, p_Discount, p_Profit, p_ShippingCost, p_OrderPriority
            );
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Before_OrderItem_Insert;
                DBMS_OUTPUT.PUT_LINE('OrderItem Insert Error: ' || SQLERRM);
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
/
