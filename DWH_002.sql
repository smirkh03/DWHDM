DESCRIBE time_by_day;
/*
Name          Null?    Type          
------------- -------- ------------- 
TIME_ID       NOT NULL NUMBER(11)    
THE_DATE               DATE          
THE_DAY                VARCHAR2(15)  
THE_MONTH              VARCHAR2(15)  
THE_YEAR               NUMBER(5)     
DAY_OF_MONTH           NUMBER(5)     
WEEK_OF_YEAR           NUMBER(5)     
MONTH_OF_YEAR          NUMBER(5)     
QUARTER                VARCHAR2(2)   
FISCAL_PERIOD          VARCHAR2(255) 
*/
DESCRIBE SALES_FACT_1998;
/*
Name         Null? Type         
------------ ----- ------------ 
PRODUCT_ID         NUMBER(11)   
TIME_ID            NUMBER(11)   
CUSTOMER_ID        NUMBER(11)   
PROMOTION_ID       NUMBER(11)   
STORE_ID           NUMBER(11)   
STORE_SALES        NUMBER(15,2) 
STORE_COST         NUMBER(15,2) 
UNIT_SALES         NUMBER(11)
*/
DESCRIBE SALES_FACT_DEC_1998;
/*
Name         Null? Type         
------------ ----- ------------ 
PRODUCT_ID         NUMBER(11)   
TIME_ID            NUMBER(11)   
CUSTOMER_ID        NUMBER(11)   
PROMOTION_ID       NUMBER(11)   
STORE_ID           NUMBER(11)   
STORE_SALES        NUMBER(15,2) 
STORE_COST         NUMBER(15,2) 
UNIT_SALES         NUMBER(11)
*/

-- Q 4 i
-- In which months in 1998 did store 24 have total sales receipts exceeding 5000.00?
-- In each case display the month and the total sales receipts for that month.
SELECT THE_MONTH, UNIT_SALES_FOR_MONTH
FROM
(
    SELECT THE_MONTH, SUM(UNIT_SALES) AS UNIT_SALES_FOR_MONTH
        FROM SALES_FACT_1998 SF
            INNER JOIN time_by_day tbd ON tbd.TIME_ID = SF.TIME_ID
        WHERE STORE_ID = 24
        GROUP BY THE_MONTH
    UNION ALL
    SELECT THE_MONTH, SUM(UNIT_SALES) AS UNIT_SALES_FOR_MONTH
        FROM SALES_FACT_DEC_1998 SF2
            INNER JOIN time_by_day tbd ON tbd.TIME_ID = SF2.TIME_ID
        WHERE STORE_ID = 24
        GROUP BY THE_MONTH
)
WHERE UNIT_SALES_FOR_MONTH > 5000.00;

-- Q 4 ii
-- In which month in 1998 did store 12 have the highest total sales receipts? Display
-- the month and the total sales receipts for that month.
WITH STORE_12_1998_SALES AS
(
    SELECT THE_MONTH, UNIT_SALES_FOR_MONTH
    FROM
    (
        SELECT THE_MONTH, SUM(UNIT_SALES) AS UNIT_SALES_FOR_MONTH
            FROM SALES_FACT_1998 SF
                INNER JOIN time_by_day tbd ON tbd.TIME_ID = SF.TIME_ID
            WHERE STORE_ID = 12
            GROUP BY THE_MONTH
        UNION ALL
        SELECT THE_MONTH, SUM(UNIT_SALES) AS UNIT_SALES_FOR_MONTH
            FROM SALES_FACT_DEC_1998 SF2
                INNER JOIN time_by_day tbd ON tbd.TIME_ID = SF2.TIME_ID
            WHERE STORE_ID = 12
            GROUP BY THE_MONTH
    )
)

SELECT THE_MONTH, UNIT_SALES_FOR_MONTH
    FROM STORE_12_1998_SALES S1
    WHERE S1.UNIT_SALES_FOR_MONTH = (
        SELECT MAX(S2.UNIT_SALES_FOR_MONTH)
            FROM STORE_12_1998_SALES S2
    );
        
