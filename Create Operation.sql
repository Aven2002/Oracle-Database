-- Create sequences for auto-generating IDs
CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE order_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE product_seq START WITH 1 INCREMENT BY 1;

-- Insert data procedure
CREATE OR REPLACE PROCEDURE InsertData IS
    v_CustomerID VARCHAR2(20);
    v_FirstName VARCHAR2(50);
    v_LastName VARCHAR2(50);
    v_Segment VARCHAR2(20);
    v_City VARCHAR2(50);
    v_State VARCHAR2(50);
    v_Country VARCHAR2(50);
    v_MarketID VARCHAR2(10);
    
    v_ProductID VARCHAR2(20);
    v_ProductName VARCHAR2(50);
    v_ProductCategory VARCHAR2(50);
    v_SubCategory VARCHAR2(50);

    v_ShippingID NUMBER;
    v_ShippingDate DATE;
    v_ShippingMode VARCHAR2(35);
    v_ShippingCost NUMBER(10,2);

    v_SalesID NUMBER;
    v_SalesAmount NUMBER(10,2);
    v_Quantity NUMBER;
    v_Discount NUMBER(3,2);
    v_Profit NUMBER(10,2);

    v_OrderID VARCHAR2(20);
    v_OrderPriority VARCHAR2(35);
    v_RegionCode VARCHAR2(10);
    
BEGIN
    -- Prompt user for customer input
    DBMS_OUTPUT.PUT_LINE('Enter First Name:');
    v_FirstName := '&v_FirstName';
    DBMS_OUTPUT.PUT_LINE('Enter Last Name:');
    v_LastName := '&v_LastName';
    DBMS_OUTPUT.PUT_LINE('Enter Segment:');
    v_Segment := '&v_Segment';
    DBMS_OUTPUT.PUT_LINE('Enter City:');
    v_City := '&v_City';
    DBMS_OUTPUT.PUT_LINE('Enter State:');
    v_State := '&v_State';
    DBMS_OUTPUT.PUT_LINE('Enter Country:');
    v_Country := '&v_Country';
    DBMS_OUTPUT.PUT_LINE('Enter Market ID:');
    v_MarketID := '&v_MarketID';

    -- Generate CustomerID
    v_CustomerID := SUBSTR(v_FirstName, 1, 1) || SUBSTR(v_LastName, 1, 1) || '-' || TO_CHAR(customer_seq.NEXTVAL);

    -- Insert into customer table
    INSERT INTO customer (customerID, marketID, cusName, cusSegment, cusCity, cusState, cusCountry)
    VALUES (v_CustomerID, v_MarketID, v_FirstName || ' ' || v_LastName, v_Segment, v_City, v_State, v_Country);

    DBMS_OUTPUT.PUT_LINE('Customer inserted successfully. Generated Customer ID: ' || v_CustomerID);

    -- Prompt user for product input
    DBMS_OUTPUT.PUT_LINE('Enter Product Name:');
    v_ProductName := '&v_ProductName';
    DBMS_OUTPUT.PUT_LINE('Enter Product Category:');
    v_ProductCategory := '&v_ProductCategory';
    DBMS_OUTPUT.PUT_LINE('Enter Sub Category:');
    v_SubCategory := '&v_SubCategory';

    -- Generate ProductID
    v_ProductID := SUBSTR(v_ProductCategory, 1, 3) || '-' || SUBSTR(v_SubCategory, 1, 3) || '-' || TO_CHAR(product_seq.NEXTVAL);

    -- Insert into product table
    INSERT INTO product (productID, productName, productCategory, subCategory)
    VALUES (v_ProductID, v_ProductName, v_ProductCategory, v_SubCategory);

    DBMS_OUTPUT.PUT_LINE('Product inserted successfully. Generated Product ID: ' || v_ProductID);

    -- Prompt user for shipping input
    DBMS_OUTPUT.PUT_LINE('Enter Shipping Date (YYYY-MM-DD):');
    v_ShippingDate := TO_DATE('&v_ShippingDate', 'YYYY-MM-DD');
    DBMS_OUTPUT.PUT_LINE('Enter Shipping Mode:');
    v_ShippingMode := '&v_ShippingMode';
    DBMS_OUTPUT.PUT_LINE('Enter Shipping Cost:');
    v_ShippingCost := TO_NUMBER('&v_ShippingCost');

    -- Generate ShippingID
    v_ShippingID := order_seq.NEXTVAL;

    -- Insert into shipping table
    INSERT INTO shipping (shippingID, shippingDate, shippingMode, shippingCost)
    VALUES (v_ShippingID, v_ShippingDate, v_ShippingMode, v_ShippingCost);

    DBMS_OUTPUT.PUT_LINE('Shipping inserted successfully. Generated Shipping ID: ' || v_ShippingID);

    -- Prompt user for sales input
    DBMS_OUTPUT.PUT_LINE('Enter Sales Amount:');
    v_SalesAmount := TO_NUMBER('&v_SalesAmount');
    DBMS_OUTPUT.PUT_LINE('Enter Quantity:');
    v_Quantity := TO_NUMBER('&v_Quantity');
    DBMS_OUTPUT.PUT_LINE('Enter Discount:');
    v_Discount := TO_NUMBER('&v_Discount');
    DBMS_OUTPUT.PUT_LINE('Enter Profit:');
    v_Profit := TO_NUMBER('&v_Profit');
    DBMS_OUTPUT.PUT_LINE('Enter Customer ID:');
    v_CustomerID := '&v_CustomerID'; -- Assuming user will provide existing customerID
    DBMS_OUTPUT.PUT_LINE('Enter Product ID:');
    v_ProductID := '&v_ProductID'; -- Assuming user will provide existing productID

    -- Generate SalesID
    v_SalesID := order_seq.NEXTVAL;

    -- Insert into sales table
    INSERT INTO sales (salesID, customerID, productID, salesAmount, quantity, discount, profit)
    VALUES (v_SalesID, v_CustomerID, v_ProductID, v_SalesAmount, v_Quantity, v_Discount, v_Profit);

    DBMS_OUTPUT.PUT_LINE('Sales inserted successfully. Generated Sales ID: ' || v_SalesID);

    -- Prompt user for order input
    DBMS_OUTPUT.PUT_LINE('Enter Region Code:');
    v_RegionCode := '&v_RegionCode';
    DBMS_OUTPUT.PUT_LINE('Enter Order Priority:');
    v_OrderPriority := '&v_OrderPriority';

    -- Generate OrderID
    v_OrderID := v_RegionCode || '-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || TO_CHAR(order_seq.NEXTVAL);

    -- Insert into orders table
    INSERT INTO orders (orderID, salesID, shippingID, orderDate, orderPriority)
    VALUES (v_OrderID, v_SalesID, v_ShippingID, SYSDATE, v_OrderPriority);

    DBMS_OUTPUT.PUT_LINE('Order inserted successfully. Generated Order ID: ' || v_OrderID);

END InsertData;
/
