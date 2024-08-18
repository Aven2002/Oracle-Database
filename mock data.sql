-- Insert into Market Table
INSERT INTO market (marketID, marketRegion) VALUES ('MK001', 'East');
INSERT INTO market (marketID, marketRegion) VALUES ('MK002', 'West');
INSERT INTO market (marketID, marketRegion) VALUES ('MK003', 'North');
INSERT INTO market (marketID, marketRegion) VALUES ('MK004', 'South');

-- Insert into Customer Table
INSERT INTO customer (customerID, marketID, cusName, cusSegment, cusCity, cusState, cusCountry) 
VALUES ('CU001', 'MK001', 'John Doe', 'Consumer', 'New York', 'NY', 'USA');

INSERT INTO customer (customerID, marketID, cusName, cusSegment, cusCity, cusState, cusCountry) 
VALUES ('CU002', 'MK002', 'Jane Smith', 'Corporate', 'Los Angeles', 'CA', 'USA');

INSERT INTO customer (customerID, marketID, cusName, cusSegment, cusCity, cusState, cusCountry) 
VALUES ('CU003', 'MK003', 'Michael Johnson', 'Consumer', 'Chicago', 'IL', 'USA');

INSERT INTO customer (customerID, marketID, cusName, cusSegment, cusCity, cusState, cusCountry) 
VALUES ('CU004', 'MK004', 'Emily Davis', 'Corporate', 'Houston', 'TX', 'USA');

-- Insert into Shipping Table
INSERT INTO shipping (shippingID, shippingDate, shippingMode, shippingCost) 
VALUES (1, TO_DATE('2024-08-14', 'YYYY-MM-DD'), 'Air', 50.00);

INSERT INTO shipping (shippingID, shippingDate, shippingMode, shippingCost) 
VALUES (2, TO_DATE('2024-08-15', 'YYYY-MM-DD'), 'Ship', 100.00);

INSERT INTO shipping (shippingID, shippingDate, shippingMode, shippingCost) 
VALUES (3, TO_DATE('2024-08-16', 'YYYY-MM-DD'), 'Rail', 75.00);

-- Insert into Product Table
INSERT INTO product (productID, productName, productCategory, subCategory) 
VALUES ('PR001', 'Laptop', 'Electronics', 'Computers');

INSERT INTO product (productID, productName, productCategory, subCategory) 
VALUES ('PR002', 'Tablet', 'Electronics', 'Computers');

INSERT INTO product (productID, productName, productCategory, subCategory) 
VALUES ('PR003', 'Desk Chair', 'Furniture', 'Office Furniture');

INSERT INTO product (productID, productName, productCategory, subCategory) 
VALUES ('PR004', 'Monitor', 'Electronics', 'Computers');

-- Insert into Sales Table (using the trigger for salesID)
INSERT INTO sales (customerID, shippingID, salesAmount, quantity, discount, profit) 
VALUES ('CU001', 1, 1000.00, 5, 0.10, 200.00);

INSERT INTO sales (customerID, shippingID, salesAmount, quantity, discount, profit) 
VALUES ('CU002', 2, 2000.00, 10, 0.15, 500.00);

INSERT INTO sales (customerID, shippingID, salesAmount, quantity, discount, profit) 
VALUES ('CU003', 3, 1500.00, 7, 0.05, 300.00);

-- Insert into Orders Table
INSERT INTO orders (orderID, salesID, customerID, productID, orderDate, orderPriority) 
VALUES ('OR001', 'sal_00001', 'CU001', 'PR001', TO_DATE('2024-08-14', 'YYYY-MM-DD'), 'High');

INSERT INTO orders (orderID, salesID, customerID, productID, orderDate, orderPriority) 
VALUES ('OR002', 'sal_00002', 'CU002', 'PR002', TO_DATE('2024-08-15', 'YYYY-MM-DD'), 'Low');

INSERT INTO orders (orderID, salesID, customerID, productID, orderDate, orderPriority) 
VALUES ('OR003', 'sal_00003', 'CU003', 'PR003', TO_DATE('2024-08-16', 'YYYY-MM-DD'), 'Medium');

-- Commit the transactions
COMMIT;
