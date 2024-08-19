-- Prompt for Customer Details
ACCEPT p_CustomerFirstName PROMPT 'Enter Customer First Name: ';
ACCEPT p_CustomerLastName PROMPT 'Enter Customer Last Name: ';
ACCEPT p_Segment PROMPT 'Enter Segment: ';
ACCEPT p_City PROMPT 'Enter City: ';
ACCEPT p_State PROMPT 'Enter State: ';
ACCEPT p_Country PROMPT 'Enter Country: ';
ACCEPT p_Market PROMPT 'Enter Market: ';
ACCEPT p_Region PROMPT 'Enter Region: ';

-- Prompt for Shipping Details
ACCEPT p_OrderDate PROMPT 'Enter Order Date (YYYY-MM-DD): ';
ACCEPT p_ShipDate PROMPT 'Enter Ship Date (YYYY-MM-DD): ';
ACCEPT p_ShipMode PROMPT 'Enter Ship Mode: ';

-- Prompt for Product Details
ACCEPT p_Category PROMPT 'Enter Product Category: ';
ACCEPT p_SubCategory PROMPT 'Enter Product SubCategory: ';
ACCEPT p_ProductName PROMPT 'Enter Product Name: ';

-- Prompt for OrderItem Details
ACCEPT p_Quantity PROMPT 'Enter Quantity: ';
ACCEPT p_Discount PROMPT 'Enter Discount: ';
ACCEPT p_Profit PROMPT 'Enter Profit: ';
ACCEPT p_ShippingCost PROMPT 'Enter Shipping Cost: ';
ACCEPT p_OrderPriority PROMPT 'Enter Order Priority: ';

-- Call the Insert_Records procedure with the collected inputs
BEGIN
    Insert_Records(
        '&p_CustomerFirstName', '&p_CustomerLastName', '&p_Segment', '&p_City', '&p_State', '&p_Country', '&p_Market', '&p_Region',
        TO_DATE('&p_OrderDate', 'YYYY-MM-DD'), TO_DATE('&p_ShipDate', 'YYYY-MM-DD'), '&p_ShipMode',
        '&p_Category', '&p_SubCategory', '&p_ProductName',
        &p_Quantity, &p_Discount, &p_Profit, &p_ShippingCost, '&p_OrderPriority'
    );
END;
/
