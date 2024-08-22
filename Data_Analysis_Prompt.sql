-- Get Sales Report
ACCEPT range_type char PROMPT "Enter Sales Report Range Type (A for Monthly, B for Yearly): ";
DECLARE
    range_type VARCHAR2(10);
BEGIN
range_type := UPPER('&range_type'); 
range_sales_report(range_type);
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Sales Amount by Market
Execute sales_by_market_report();

--top 5 products in each market
ACCEPT market char DEFAULT "ALL" PROMPT "Enter Market to check TOP 5 Products (All(DEFAULT), APAC, Africa, Canada, EMEA, EU, LATAM, US): ";
DECLARE
    market VARCHAR2(10);
BEGIN
market := UPPER('&market'); 
TOP_5_PRODUCTS_BY_MARKET(market);
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Shipping Mode Report
EXECUTE shipping_mode_report();

-- end of report
ACCEPT i_type CHAR PROMPT 'Enter Range Type (YEAR, MONTH, DAY): ';
ACCEPT i_date CHAR PROMPT 'Enter Date with Format (YEAR = YYYY, MONTH = YYYY-MM, DAY = YYYY-MM-DD): ';

DECLARE
    v_type VARCHAR2(10);
    v_date VARCHAR2(15);
BEGIN
    v_type := UPPER('&i_type');
    v_date := '&i_date';

    end_of_report(v_type, v_date);
END;
/
