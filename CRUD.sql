-- Delete Operation
DECLARE
    v_order_id VARCHAR2(10);
BEGIN
    v_order_id := '&order_id';

    -- Attempt to delete the order with the specified ID
    DELETE FROM orders WHERE orderID = v_order_id;

    -- Check if any rows were deleted
    IF SQL%ROWCOUNT > 0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Successful Message : Order ID: ' || v_order_id || ' has been successfully deleted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error Message : Order ID :' || v_order_id || ' not found.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
END;
/

