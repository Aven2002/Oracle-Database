--Range_Sales_Report
create or replace PROCEDURE range_sales_report (
    range_type IN VARCHAR2
) IS

    CURSOR monthly_cursor IS
    SELECT
        TO_CHAR(s.ORDERDATE, 'YYYY-MM') AS month,
        SUM(oi.SALESAMOUNT) AS totalsales
    FROM
        SHIPPING s
        JOIN (SELECT o.ORDERID, o.SALESAMOUNT FROM ORDERITEM o) oi ON s.ORDERID = oi.ORDERID
    GROUP BY
        TO_CHAR(s.ORDERDATE, 'YYYY-MM')
    ORDER BY
        month DESC;

    CURSOR yearly_cursor IS
    SELECT
        TO_CHAR(s.ORDERDATE, 'YYYY') AS year,
        SUM(oi.SALESAMOUNT) AS totalsales
    FROM
        SHIPPING s
        JOIN (SELECT o.ORDERID, o.SALESAMOUNT FROM ORDERITEM o) oi ON s.ORDERID = oi.ORDERID
    GROUP BY
        TO_CHAR(s.ORDERDATE, 'YYYY')
    ORDER BY
        year DESC;

    monthly_record monthly_cursor%ROWTYPE;
    yearly_record yearly_cursor%ROWTYPE;
BEGIN
    IF range_type = 'MONTHLY' OR range_type = 'A' THEN
        OPEN monthly_cursor;
        DBMS_OUTPUT.PUT_LINE('Month' || CHR(9) || 'Total Sales');
        DBMS_OUTPUT.PUT_LINE('--------------------------');
        LOOP
            FETCH monthly_cursor INTO monthly_record;
            EXIT WHEN monthly_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(monthly_record.month || CHR(9) || 'RM ' || monthly_record.totalsales);
        END LOOP;
        CLOSE monthly_cursor;

    ELSIF range_type = 'YEARLY' OR range_type = 'B' THEN
        OPEN yearly_cursor;
        DBMS_OUTPUT.PUT_LINE('Year' || CHR(9) || 'Total Sales');
        DBMS_OUTPUT.PUT_LINE('--------------------------');
        LOOP
            FETCH yearly_cursor INTO yearly_record;
            EXIT WHEN yearly_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(yearly_record.year || CHR(9) || 'RM ' || yearly_record.totalsales);
        END LOOP;
        CLOSE yearly_cursor;

    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid range type. Please use "MONTHLY" or "YEARLY".');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Sales_by_Market_Report
create or replace PROCEDURE sales_by_market_report IS

    CURSOR market_cursor IS
    SELECT
        c.MARKET,
        SUM(oi.SALESAMOUNT) AS total_sales
    FROM
        SHIPPING s
        JOIN (SELECT o.SALESAMOUNT, o.ORDERID FROM ORDERITEM o) oi ON s.ORDERID = oi.ORDERID
        JOIN (SELECT c.CUSTOMERID, c.MARKET FROM CUSTOMER c) c ON s.CUSTOMERID = c.CUSTOMERID
    GROUP BY
        c.MARKET
    ORDER BY
        total_sales DESC;

    market_record market_cursor%ROWTYPE;
BEGIN
    OPEN market_cursor;
    DBMS_OUTPUT.PUT_LINE(RPAD('MARKET', 20) || 'Total Sales');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    LOOP
        FETCH market_cursor INTO market_record;
        EXIT WHEN market_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(market_record.MARKET, 20) || 'RM ' || market_record.total_sales);
    END LOOP;
    CLOSE market_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Top_5_Products_by_Market
create or replace PROCEDURE top_5_products_by_market (p_market VARCHAR2 DEFAULT 'ALL') IS

    market_count INTEGER;

    -- Cursor to check if the market exists
    CURSOR market_check_cursor IS
    SELECT COUNT(*)
    FROM CUSTOMER c
    WHERE UPPER(c.MARKET) = p_market;

    -- Cursor to retrieve the top 5 products for a specific market
    CURSOR product_cursor (market_name VARCHAR2) IS
    SELECT *
    FROM (
        SELECT
            p.PRODUCTID,
            p.PRODUCTNAME,
            SUM(oi.quantity) AS total_sales
        FROM
            ORDERITEM oi
            JOIN (SELECT p.productID,p.PRODUCTNAME from PRODUCT p) p ON oi.PRODUCTID = p.PRODUCTID
            JOIN (SELECT s.orderID, s.customerID from SHIPPING s) s ON oi.ORDERID = s.ORDERID
            JOIN (SELECT c.customerID, c.market FROM CUSTOMER c) c ON s.CUSTOMERID = c.CUSTOMERID
        WHERE
            UPPER(c.MARKET) = UPPER(market_name)
        GROUP BY
            p.PRODUCTID, p.PRODUCTNAME
        ORDER BY
            total_sales DESC
    )
    WHERE ROWNUM <= 5;

    -- Cursor to retrieve the top 5 products accross all markets
    CURSOR product_cursor_all IS
        SELECT * FROM
        (
        SELECT
            p.productid,
            p.productname,
            SUM(oi.quantity) AS total_sales
        FROM
            orderitem oi
        JOIN (SELECT p.productid, p.productname FROM product p) p ON oi.productid = p.productid
        JOIN (SELECT s.orderid FROM shipping s) s ON oi.orderid = s.orderid
        GROUP BY
            p.productid, p.productname
        ORDER BY
            total_sales DESC
        )
    WHERE ROWNUM <= 5;

    all_product_record product_cursor_all%ROWTYPE; 
    product_record product_cursor%ROWTYPE;
BEGIN
    IF p_market = 'ALL' THEN


            DBMS_OUTPUT.PUT_LINE('Market: ALL MARKET');
            DBMS_OUTPUT.PUT_LINE(RPAD('Product ID',18) || RPAD('Product Name',60) || 'Total Sales');
            DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------');

            OPEN product_cursor_all;
            LOOP
                FETCH product_cursor_all INTO all_product_record;
                EXIT WHEN product_cursor_all%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(RPAD(all_product_record.PRODUCTID,18) || RPAD(all_product_record.PRODUCTNAME,60) || all_product_record.total_sales);
            END LOOP;
            CLOSE product_cursor_all;
    ELSE
        -- Check if the specified market exists
        OPEN market_check_cursor;
        FETCH market_check_cursor INTO market_count;
        CLOSE market_check_cursor;

        IF market_count > 0 THEN
            -- Process the specific market
            DBMS_OUTPUT.PUT_LINE('Market: ' || p_market);
            DBMS_OUTPUT.PUT_LINE(RPAD('Product ID',18) || RPAD('Product Name',60) || 'Total Sales');
            DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------');

            OPEN product_cursor(p_market);
            LOOP
                FETCH product_cursor INTO product_record;
                EXIT WHEN product_cursor%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(RPAD(product_record.PRODUCTID,18) || RPAD(product_record.PRODUCTNAME,60) || product_record.total_sales);
            END LOOP;
            CLOSE product_cursor;

            DBMS_OUTPUT.PUT_LINE('');
        ELSE
            -- Market does not exist
            DBMS_OUTPUT.PUT_LINE('Market "' || p_market || '" does not exist.');
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/  


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Shipping_Mode_Report
create or replace PROCEDURE shipping_mode_report IS

    CURSOR quantity_cursor IS
    SELECT
        s.SHIPMODE,
        COUNT(DISTINCT oi.ORDERID) AS order_count,
        SUM(oi.PROFIT) AS total_profit
    FROM
        ORDERITEM oi
        JOIN (SELECT SHIPPING.SHIPMODE, SHIPPING.ORDERID FROM SHIPPING) s ON oi.ORDERID = s.ORDERID
    GROUP BY
        s.SHIPMODE
    ORDER BY
        total_profit DESC;

    quantity_record quantity_cursor%ROWTYPE;
BEGIN
    OPEN quantity_cursor;
    DBMS_OUTPUT.PUT_LINE(RPAD('Shipping Mode',20) || RPAD('Total Order',16) || 'Total Profit');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');

    LOOP
        FETCH quantity_cursor INTO quantity_record;
        EXIT WHEN quantity_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(quantity_record.SHIPMODE, 20) || RPAD(quantity_record.order_count,16) || 'RM ' || quantity_record.total_profit);
    END LOOP;
    CLOSE quantity_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--End_of_Report
CREATE OR REPLACE PROCEDURE end_of_report (
    p_date_type IN VARCHAR2,
    p_date_value IN VARCHAR2
) IS
    v_order_count   NUMBER;
    v_total_sales   NUMBER;
    v_total_profit  NUMBER;
    v_mode_count    NUMBER;
BEGIN

    -- Validate input date type and format
    IF p_date_type NOT IN ('MONTH', 'DAY', 'YEAR') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid date type. Use "MONTH", "DAY", or "YEAR".');
    END IF;

    IF p_date_type = 'MONTH' AND (NOT regexp_like(p_date_value, '^[0-9]{4}-[0-9]{2}$')) THEN
       RAISE_APPLICATION_ERROR(-20001, 'Invalid date value. Use YYYY-MM for MONTH.');
    END IF;  
    
    IF p_date_type = 'DAY' AND (NOT regexp_like(p_date_value, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')) THEN
       RAISE_APPLICATION_ERROR(-20001, 'Invalid date value. Use YYYY-MM-DD for DAY.');
    END IF; 
    
    IF p_date_type = 'YEAR' AND (NOT regexp_like(p_date_value, '^[0-9]{4}$')) THEN
       RAISE_APPLICATION_ERROR(-20001, 'Invalid date value. Use YYYY for YEAR.');
    END IF;

    -- Fetch the total order count, sales, and profit
    SELECT
        COUNT(DISTINCT oi.ORDERID),
        SUM(oi.SALESAMOUNT),
        SUM(oi.PROFIT)
    INTO
        v_order_count,
        v_total_sales,
        v_total_profit
    FROM
        ORDERITEM oi
    JOIN SHIPPING s ON oi.ORDERID = s.ORDERID
    WHERE
        (p_date_type = 'MONTH' AND TO_CHAR(s.ORDERDATE, 'YYYY-MM') = p_date_value)
        OR
        (p_date_type = 'DAY' AND TO_CHAR(s.ORDERDATE, 'YYYY-MM-DD') = p_date_value)
        OR
        (p_date_type = 'YEAR' AND TO_CHAR(s.ORDERDATE, 'YYYY') = p_date_value);

    IF v_order_count = 0 THEN
       DBMS_OUTPUT.PUT_LINE('No data found for the specified date.');
        RETURN;
    END IF;
    -- Output the totals
    DBMS_OUTPUT.PUT_LINE('Report for end of ' || LOWER(p_date_type) || ' ' || p_date_value);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Order Count: ' || v_order_count);
    DBMS_OUTPUT.PUT_LINE('Total Sales: RM ' || v_total_sales);
    DBMS_OUTPUT.PUT_LINE('Total Profit: RM ' || v_total_profit);
    DBMS_OUTPUT.PUT_LINE('');  -- New line for formatting

    -- Cursor to iterate through the ship modes and their counts
    DBMS_OUTPUT.PUT_LINE( RPAD('Shipping Mode', 18) || 'Order Count');
    FOR r IN (
        SELECT
            s.SHIPMODE,
            COUNT(*) AS mode_count
        FROM
            SHIPPING s
        WHERE
            (p_date_type = 'MONTH' AND TO_CHAR(s.ORDERDATE, 'YYYY-MM') = p_date_value)
            OR
            (p_date_type = 'DAY' AND TO_CHAR(s.ORDERDATE, 'YYYY-MM-DD') = p_date_value)
            OR
            (p_date_type = 'YEAR' AND TO_CHAR(s.ORDERDATE, 'YYYY') = p_date_value)
        GROUP BY
            s.SHIPMODE
        ORDER BY 
            mode_count DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE( RPAD(r.SHIPMODE, 18) || r.mode_count);
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for the specified date.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/