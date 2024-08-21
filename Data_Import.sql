-- Step 1 : Validation function (Validate the csv file which gonna to use)
create or replace FUNCTION validate_file_path(p_file_name IN VARCHAR2)
RETURN BOOLEAN
IS
    csv_file    UTL_FILE.FILE_TYPE;
BEGIN
--    DBMS_OUTPUT.PUT_LINE(p_file_path);
    csv_file := UTL_FILE.FOPEN('MY_DIR', p_file_name, 'R');
    UTL_FILE.FCLOSE(csv_file);
    RETURN TRUE;

EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
        DBMS_OUTPUT.PUT_LINE('Invalid directory path: MY_DIR');
        RETURN FALSE;
    WHEN UTL_FILE.INVALID_MODE THEN
        DBMS_OUTPUT.PUT_LINE('Invalid file open mode.');
        RETURN FALSE;
    WHEN UTL_FILE.INVALID_OPERATION THEN
        DBMS_OUTPUT.PUT_LINE('Invalid operation.');
        RETURN FALSE;
    WHEN UTL_FILE.READ_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Read error.');
        RETURN FALSE;
    WHEN UTL_FILE.ACCESS_DENIED THEN
        DBMS_OUTPUT.PUT_LINE('Access denied.');
        RETURN FALSE;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        RETURN FALSE;
END validate_file_path;


-- Step 2 :Process CSV File Function (Read & Import Data from csv file) 
CREATE OR REPLACE FUNCTION process_csv_file(p_file_name IN VARCHAR2)
RETURN VARCHAR2
IS
    -- File reading variables
    file_handle   UTL_FILE.FILE_TYPE;
    line_buffer   CLOB;

    -- Variables for holding CSV data
    v_shipping_id      NUMBER;
    v_order_id         VARCHAR2(50);
    v_order_date       DATE;
    v_ship_date        DATE;
    v_ship_mode        VARCHAR2(50);
    v_customer_id      VARCHAR2(50);
    v_customer_name    VARCHAR2(100);
    v_segment          VARCHAR2(50);
    v_city             VARCHAR2(100);
    v_state            VARCHAR2(100);
    v_country          VARCHAR2(100);
    v_market           VARCHAR2(35);
    v_region           VARCHAR2(35);
    v_product_id       VARCHAR2(50);
    v_category         VARCHAR2(50);
    v_sub_category     VARCHAR2(50);
    v_product_name     VARCHAR2(255);
    v_sales_amount     NUMBER(10,2);
    v_quantity         NUMBER;
    v_discount         NUMBER(5,2);
    v_profit           NUMBER(10,2);
    v_shipping_cost    NUMBER(10,2);
    v_order_priority   VARCHAR2(50);
    v_record_count     INTEGER;
BEGIN
    -- Open the file from the directory 'MY_DIR'
    file_handle := utl_file.fopen('MY_DIR', p_file_name, 'R');

    -- Skip the header line
    utl_file.get_line(file_handle, line_buffer);

    -- Loop through each line in the file
    LOOP
        BEGIN
            -- Set a savepoint before processing each line
            SAVEPOINT savepoint_before_line;

            -- Read a line of data
            UTL_FILE.GET_LINE(file_handle, line_buffer);

            -- Extract data from the CSV line
            v_shipping_id := TO_NUMBER(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 1));
            v_order_id := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 2);
            v_order_date := TO_DATE(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 3), 'DD/MM/YYYY');
            v_ship_date := TO_DATE(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 4), 'DD/MM/YYYY');
            v_ship_mode := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 5);
            v_customer_id := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 6);
            v_customer_name := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 7);
            v_segment := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 8);
            v_city := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 9);
            v_state := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 10);
            v_country := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 11);
            v_market := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 12);
            v_region := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 13);
            v_product_id := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 14);
            v_category := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 15);
            v_sub_category := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 16);
            v_product_name := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 17);
            v_sales_amount := TO_NUMBER(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 18));
            v_quantity := TO_NUMBER(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 19));
            v_discount := TO_NUMBER(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 20));
            v_profit := TO_NUMBER(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 21));
            v_shipping_cost := TO_NUMBER(REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 22));
            v_order_priority := REGEXP_SUBSTR(line_buffer, '[^,]+', 1, 23);

            -- Check and insert into the Customer table
            BEGIN
                SELECT COUNT(*)
                INTO v_record_count
                FROM customer
                WHERE customerID = v_customer_id;

                IF v_record_count = 0 THEN
                    INSERT INTO customer (customerID, customerName, segment, city, state, country, market, region)
                    VALUES (v_customer_id, v_customer_name, v_segment, v_city, v_state, v_country, v_market, v_region);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error inserting customer: ' || SQLERRM || ' for customerID: ' || v_customer_id);
                    ROLLBACK TO savepoint_before_line;
                    CONTINUE;
            END;

            -- Check and insert into the Shipping table
            BEGIN
                SELECT COUNT(*)
                INTO v_record_count
                FROM shipping
                WHERE shippingID = v_shipping_id;

                IF v_record_count = 0 THEN
                    INSERT INTO shipping (shippingID, orderID, orderDate, shipDate, shipMode, customerID)
                    VALUES (v_shipping_id, v_order_id, v_order_date, v_ship_date, v_ship_mode, v_customer_id);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error inserting shipping: ' || SQLERRM || ' for shippingID: ' || v_shipping_id);
                    ROLLBACK TO savepoint_before_line;
                    CONTINUE;
            END;

            -- Check and insert into the Product table
            BEGIN
                SELECT COUNT(*)
                INTO v_record_count
                FROM product
                WHERE productID = v_product_id;

                IF v_record_count = 0 THEN
                    INSERT INTO product (productID, category, subCategory, productName)
                    VALUES (v_product_id, v_category, v_sub_category, v_product_name);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error inserting product: ' || SQLERRM || ' for productID: ' || v_product_id);
                    ROLLBACK TO savepoint_before_line;
                    CONTINUE;
            END;

            -- Insert into the OrderItem table
            BEGIN
                SELECT COUNT(*)
                INTO v_record_count
                FROM orderItem
                WHERE orderID = v_order_id AND productID = v_product_id;

                IF v_record_count = 0 THEN
                    INSERT INTO orderItem (orderID, productID, salesAmount, quantity, discount, profit, shippingCost, orderPriority)
                    VALUES (v_order_id, v_product_id, v_sales_amount, v_quantity, v_discount, v_profit, v_shipping_cost, v_order_priority);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error inserting orderItem: ' || SQLERRM || ' for orderID: ' || v_order_id || v_product_id);
                    ROLLBACK TO savepoint_before_line;
                    CONTINUE;
            END;

            -- Commit after each successful line
            COMMIT;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                UTL_FILE.FCLOSE(file_handle);
                EXIT;
            WHEN OTHERS THEN
                dbms_output.put_line('Error: ' || SQLERRM || ' in line: ' || line_buffer);
                ROLLBACK TO savepoint_before_line;
                CONTINUE;
        END;
    END LOOP;

    -- Close the file
    UTL_FILE.FCLOSE(file_handle);

    RETURN 'Success: File processed successfully.';
EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
        RETURN 'Error: Invalid path.';
    WHEN UTL_FILE.INVALID_MODE THEN
        RETURN 'Error: Invalid mode.';
    WHEN UTL_FILE.INVALID_OPERATION THEN
        RETURN 'Error: Invalid operation.';
    WHEN UTL_FILE.READ_ERROR THEN
        RETURN 'Error: Read error.';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/

--Step 3 : Prompt User (File Path & File Name)
SET SERVEROUTPUT ON
    ACCEPT file_path char PROMPT "Enter File Path: ";
    ACCEPT file_name char PROMPT "Enter Filename: ";
DECLARE
    file_path VARCHAR2(255);
    file_name VARCHAR2(255); 
    result_import VARCHAR2(100);
BEGIN
    file_path := '&file_path';  -- Prompt for input

    file_name := '&file_name';  -- Prompt for input
    
    -- Create the directory
    EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY my_dir AS '''
                      || file_path
                      || '''';
    dbms_output.put_line('Directory my_dir created successfully.');

    -- Validate the file
    IF validate_file_path(file_name) THEN
        dbms_output.put_line('File is valid and accessible.');
        result_import:= process_csv_file(file_name);
        dbms_output.put_line(result_import);
    ELSE
        dbms_output.put_line('File is invalid or inaccessible.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error creating directory: ' || sqlerrm);
END;
/


