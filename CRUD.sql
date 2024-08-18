-- Enable DBMS_OUTPUT
SET SERVEROUTPUT ON SIZE 1000000;

-- Delete Operation
DECLARE
    v_shipping_id VARCHAR2(10);
BEGIN
    v_shipping_id := '&shipping_id';

    -- Attempt to delete the shipping with the specified ID
    DELETE FROM shipping WHERE shippingID = v_shipping_id;

    -- Check if any rows were deleted
    IF SQL%ROWCOUNT > 0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Successful Message: Shipping ID: ' || v_shipping_id || ' has been successfully deleted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error Message: Shipping ID: ' || v_shipping_id || ' not found.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
END;
/
