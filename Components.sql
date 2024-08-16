-- Mock Data
INSERT INTO orders (orderID, orderDate, orderPriority)
VALUES ('ORD001', TO_DATE('2024-08-01', 'YYYY-MM-DD'), 'High');

INSERT INTO orders (orderID, orderDate, orderPriority)
VALUES ('ORD002', TO_DATE('2024-08-02', 'YYYY-MM-DD'), 'Medium');

INSERT INTO orders (orderID, orderDate, orderPriority)
VALUES ('ORD003', TO_DATE('2024-08-03', 'YYYY-MM-DD'), 'Low');

INSERT INTO sales (salesID, orderID, salesAmount, quantity, discount, profit)
VALUES (1, 'ORD001', 1500.00, 3, 0.10, 500.00);

INSERT INTO sales (salesID, orderID, salesAmount, quantity, discount, profit)
VALUES (2, 'ORD002', 2500.00, 5, 0.15, 800.00);

INSERT INTO sales (salesID, orderID, salesAmount, quantity, discount, profit)
VALUES (3, 'ORD003', 1000.00, 2, 0.05, 300.00);

INSERT INTO shipping (shippingID, salesID, shippingDate, shippingMode, shippingCost)
VALUES (101, 1, TO_DATE('2024-08-04', 'YYYY-MM-DD'), 'Air', 50.00);

INSERT INTO shipping (shippingID, salesID, shippingDate, shippingMode, shippingCost)
VALUES (102, 2, TO_DATE('2024-08-05', 'YYYY-MM-DD'), 'Ground', 30.00);

INSERT INTO shipping (shippingID, salesID, shippingDate, shippingMode, shippingCost)
VALUES (103, 3, TO_DATE('2024-08-06', 'YYYY-MM-DD'), 'Sea', 70.00);

INSERT INTO customer (customerID, salesID, cusName, cusSegment, cusCity, cusState, cusCountry)
VALUES ('CUST001', 1, 'John Doe', 'Consumer', 'New York', 'NY', 'USA');

INSERT INTO customer (customerID, salesID, cusName, cusSegment, cusCity, cusState, cusCountry)
VALUES ('CUST002', 2, 'Jane Smith', 'Corporate', 'Los Angeles', 'CA', 'USA');

INSERT INTO customer (customerID, salesID, cusName, cusSegment, cusCity, cusState, cusCountry)
VALUES ('CUST003', 3, 'Bob Johnson', 'Small Business', 'Chicago', 'IL', 'USA');


INSERT INTO market (marketID, customerID, marketRegion)
VALUES ('MARK001', 'CUST001', 'North America');

INSERT INTO market (marketID, customerID, marketRegion)
VALUES ('MARK002', 'CUST002', 'West Coast');

INSERT INTO market (marketID, customerID, marketRegion)
VALUES ('MARK003', 'CUST003', 'Midwest');

INSERT INTO product (productID, salesID, productName, productCategory, subCategory)
VALUES ('PROD001', 1, 'Laptop', 'Electronics', 'Computers');

INSERT INTO product (productID, salesID, productName, productCategory, subCategory)
VALUES ('PROD002', 2, 'Smartphone', 'Electronics', 'Mobile Devices');

INSERT INTO product (productID, salesID, productName, productCategory, subCategory)
VALUES ('PROD003', 3, 'Office Chair', 'Furniture', 'Office Supplies');



-- Select all tables
SELECT * FROM orders;
SELECT * FROM sales;
SELECT * FROM customer;
SELECT * FROM product;
SELECT * FROM shipping;
SELECT * FROM market;


-- Drop all tables
DROP TABLE shipping CASCADE CONSTRAINTS;
DROP TABLE sales CASCADE CONSTRAINTS;
DROP TABLE product CASCADE CONSTRAINTS;
DROP TABLE market CASCADE CONSTRAINTS;
DROP TABLE customer CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;


-- Display data in a row 
SELECT 
    o.orderID,
    o.orderDate,
    o.orderPriority,
    s.salesID,
    s.salesAmount,
    s.quantity,
    s.discount,
    s.profit,
    c.customerID,
    c.cusName,
    c.cusSegment,
    c.cusCity,
    c.cusState,
    c.cusCountry,
    m.marketID,
    m.marketRegion,
    p.productID,
    p.productName,
    p.productCategory,
    p.subCategory,
    sh.shippingID,
    sh.shippingDate,
    sh.shippingMode,
    sh.shippingCost
FROM 
    orders o
JOIN 
    sales s ON o.orderID = s.orderID
JOIN 
    customer c ON s.salesID = c.salesID
JOIN 
    market m ON c.customerID = m.customerID
JOIN 
    product p ON s.salesID = p.salesID
JOIN 
    shipping sh ON o.shippingID = sh.shippingID;
