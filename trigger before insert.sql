--Trigger for shipMode in the shipping table

CREATE OR REPLACE TRIGGER trg_validate_shipMode
BEFORE INSERT OR UPDATE ON Shipping
FOR EACH ROW
BEGIN
    IF :NEW.shipMode NOT IN ('first class', 'same day', 'second class', 'standard class') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid ship mode. Allowed values are: first class, same day, second class, standard class.');
    END IF;
END;
/

--Trigger for segment, market, and region in the customer table

CREATE OR REPLACE TRIGGER trg_validate_customer_fields
BEFORE INSERT OR UPDATE ON Customer
FOR EACH ROW
BEGIN
    -- Validate segment
    IF :NEW.segment NOT IN ('consumer', 'corporate', 'home office') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid segment. Allowed values are: consumer, corporate, home office.');
    END IF;

    -- Validate market
    IF :NEW.market NOT IN ('africa', 'apac', 'canada', 'emea', 'eu', 'latam', 'us') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid market. Allowed values are: africa, apac, canada, emea, eu, latam, us.');
    END IF;

    -- Validate region
    IF :NEW.region NOT IN ('africa', 'canada', 'caribbean', 'central', 'central asia', 'east', 'emea', 'north', 'north asia', 'oceania', 'south', 'southeast asia', 'west') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid region. Allowed values are: africa, canada, caribbean, central, central asia, east, emea, north, north asia, oceania, south, southeast asia, west.');
    END IF;
END;
/

--Trigger for category and subCategory in the product table

CREATE OR REPLACE TRIGGER trg_validate_product_fields
BEFORE INSERT OR UPDATE ON Product
FOR EACH ROW
BEGIN
    -- Validate category
    IF :NEW.category NOT IN ('technology', 'office supplies', 'furniture') THEN
        RAISE_APPLICATION_ERROR(-20005, 'Invalid category. Allowed values are: technology, office supplies, furniture.');
    END IF;

    -- Validate subCategory
    IF :NEW.subCategory NOT IN ('accessories', 'appliances', 'art', 'binders', 'bookcases', 'chairs', 'copiers', 'envelopes', 'fasteners', 'furnishings', 'labels', 'machines', 'paper', 'phones', 'storage', 'suppliers', 'tables') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Invalid subCategory. Allowed values are: accessories, appliances, art, binders, bookcases, chairs, copiers, envelopes, fasteners, furnishings, labels, machines, paper, phones, storage, suppliers, tables.');
    END IF;
END;
/

--Trigger for orderPriority in the orderItem table

CREATE OR REPLACE TRIGGER trg_validate_orderPriority
BEFORE INSERT OR UPDATE ON OrderItem
FOR EACH ROW
BEGIN
    IF :NEW.orderPriority NOT IN ('critical', 'high', 'low', 'medium') THEN
        RAISE_APPLICATION_ERROR(-20007, 'Invalid order priority. Allowed values are: critical, high, low, medium.');
    END IF;
END;
/
