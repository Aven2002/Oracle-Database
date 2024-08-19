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
    p_OrderDate IN DATE,
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

    -- Auto-generate CustomerID
    SELECT UPPER(SUBSTR(p_CustomerFirstName, 1, 1)) || 
           UPPER(SUBSTR(p_CustomerLastName, 1, 1)) || 
           '-' || 
           LPAD(NVL(MAX(TO_NUMBER(SUBSTR(CustomerID, 4))), 0) + 1, 5, '0')
    INTO v_CustomerID
    FROM Customer
    WHERE CustomerID LIKE UPPER(SUBSTR(p_CustomerFirstName, 1, 1)) || 
                         UPPER(SUBSTR(p_CustomerLastName, 1, 1)) || '-%';

    -- Auto-generate ShippingID
    SELECT NVL(MAX(ShippingID), 0) + 1 INTO v_ShippingID FROM Shipping;

    -- Auto-generate ProductID
    SELECT UPPER(SUBSTR(p_Category, 1, 3)) || '-' || 
           UPPER(SUBSTR(p_ProductName, 1, 3)) || '-' || 
           LPAD(NVL(MAX(TO_NUMBER(SUBSTR(ProductID, 8))), 0) + 1, 8, '0')
    INTO v_ProductID
    FROM Product
    WHERE ProductID LIKE UPPER(SUBSTR(p_Category, 1, 3)) || '-' || 
                        UPPER(SUBSTR(p_ProductName, 1, 3)) || '-%';

    -- Auto-generate OrderID
    SELECT UPPER(SUBSTR(p_Country, 1, 2)) || '-' || 
           TO_CHAR(p_OrderDate, 'YYYY') || '-' || 
           LPAD(NVL(MAX(TO_NUMBER(SUBSTR(OrderID, 9))), 0) + 1, 4, '0')
    INTO v_OrderID
    FROM OrderItem
    WHERE OrderID LIKE UPPER(SUBSTR(p_Country, 1, 2)) || 
                      '-' || TO_CHAR(p_OrderDate, 'YYYY') || '-%';

    BEGIN
        -- Insert into Customer table
        INSERT INTO Customer (
            CustomerID, CustomerName, Segment, City, State, Country, Market, Region
        ) VALUES (
            v_CustomerID, p_CustomerFirstName || ' ' || p_CustomerLastName, p_Segment, p_City, p_State, p_Country, p_Market, p_Region
        );

        -- Insert into Shipping table
        INSERT INTO Shipping (
            ShippingID, OrderID, OrderDate, ShipDate, ShipMode, CustomerID
        ) VALUES (
            v_ShippingID, v_OrderID, p_OrderDate, p_ShipDate, p_ShipMode, v_CustomerID
        );

        -- Insert into Product table
        INSERT INTO Product (
            ProductID, Category, SubCategory, ProductName
        ) VALUES (
            v_ProductID, p_Category, p_SubCategory, p_ProductName
        );

        -- Insert into OrderItem table
        INSERT INTO OrderItem (
            OrderID, ProductID, SalesAmount, Quantity, Discount, Profit, ShippingCost, OrderPriority
        ) VALUES (
            v_OrderID, v_ProductID, NULL, p_Quantity, p_Discount, p_Profit, p_ShippingCost, p_OrderPriority
        );

        -- Commit the transaction
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Records inserted successfully.');

    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback to the savepoint if an error occurs
            ROLLBACK TO Before_Insert;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;
END;
/
