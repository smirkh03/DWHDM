-- Question One
-- (i) Find the name and city of each project supplied with a red part.
SELECT p.JNAME, p.CITY
    FROM PROJECT p
    WHERE EXISTS (
        SELECT spy.P#
            FROM SUPPLY spy
                INNER JOIN Part prt ON prt.P# = spy.P#
            WHERE prt.COLOUR = 'RED'
                AND spy.J# = p.J#
    );
-- (ii) Find the name and city of each project not supplied with a red part.
SELECT p.JNAME, p.CITY
    FROM PROJECT p
    WHERE NOT EXISTS (
        SELECT spy.P#
            FROM SUPPLY spy
                INNER JOIN Part prt ON prt.P# = spy.P#
            WHERE prt.COLOUR = 'RED'
                AND spy.J# = p.J#
    );
    
-- (iii) For each red part, find the total number of suppliers supplying the part.
SELECT spy.P#, COUNT(S#)
    FROM SUPPLY spy
        INNER JOIN Part prt ON prt.P# = spy.P#
    WHERE prt.COLOUR = 'RED'
    GROUP BY spy.P#;

-- (iv) Find the name and city of each supplier supplying every red part.
SELECT s.SNAME, s.CITY
    FROM Supplier s
        INNER JOIN Supply spy ON spy.S# = s.S#
        INNER JOIN Part prt ON prt.P# = spy.P#
    WHERE prt.Colour = 'RED'
    GROUP BY s.S#, s.SNAME, s.CITY
    HAVING COUNT(DISTINCT prt.P#) = (
        SELECT COUNT(prt2.P#)
            FROM Part prt2
            WHERE prt2.Colour = 'RED');

-- Question Two
-- (i) For each constituency in which more than 5 parties had candidates, 
--     find the average vote received by parties in that constituency. Order the rows by constituency.
DESCRIBE UKCONSTS;
/*
Name       Null?    Type         
---------- -------- ------------ 
UKNUM      NOT NULL NUMBER(4)    
UKAREA     NOT NULL VARCHAR2(40) 
UKELECTORS NOT NULL NUMBER(6)   
*/
DESCRIBE UKRESULTS;
/*
Name    Null?    Type         
------- -------- ------------ 
UKNUM   NOT NULL NUMBER(4)    
PARTY   NOT NULL VARCHAR2(20) 
UKVOTES NOT NULL NUMBER(6)    
*/


WITH CONST_GREATER_THAN_FIVE_PARTIES AS (
SELECT UKNUM, AVG(UKVOTES) AS AVG_UKVOTES
    FROM UKRESULTS
    GROUP BY UKNUM
    HAVING (COUNT(PARTY) > 5))

SELECT U.UKAREA, ROUND(AVG_UKVOTES, 2) AS "AVERAGE VOTE"
    FROM UKCONSTS U
    INNER JOIN CONST_GREATER_THAN_FIVE_PARTIES CC ON CC.UKNUM = U.UKNUM
    ORDER BY UKAREA;

-- (ii) Find the constituency name, number of voters voting, and turnout (i.e. percentage of registered voters who voted) in
--      constituencies where less than 65% of registered voters voted. Order the rows by ascending turnout.

WITH TOTAL_CONST_VOTES AS (
SELECT UKNUM, SUM(UKVOTES) AS SUM_UKVOTES
    FROM UKRESULTS
    GROUP BY UKNUM)

SELECT U.UKAREA, SUM_UKVOTES AS "TOTAL VOTE", ROUND(((SUM_UKVOTES/UKELECTORS) * 100), 2) AS TURNOUT
    FROM UKCONSTS U
    INNER JOIN TOTAL_CONST_VOTES CC ON CC.UKNUM = U.UKNUM
    WHERE (SUM_UKVOTES/UKELECTORS) < 0.65
    ORDER BY TURNOUT;


-- (iii) Find the constituency name and turnout in constituencies which have at least 5000 more registered voters than the 
-- average number of registered voters in a constituency. Order the rows by descending turnout.
WITH TOTAL_CONST_VOTES AS (
SELECT UKNUM, SUM(UKVOTES) AS SUM_UKVOTES
    FROM UKRESULTS
    GROUP BY UKNUM)

SELECT U.UKAREA, SUM_UKVOTES AS "TOTAL VOTE", ROUND(((SUM_UKVOTES/UKELECTORS) * 100), 2) AS TURNOUT
    FROM UKCONSTS U
    INNER JOIN TOTAL_CONST_VOTES CC ON CC.UKNUM = U.UKNUM
    WHERE (UKELECTORS - 5000) > (SELECT AVG(UKELECTORS) FROM UKCONSTS)
    ORDER BY TURNOUT DESC;
    
-- (iv) Find the average turnout in constituencies.
WITH TOTAL_CONST_VOTES AS (
SELECT UKNUM, SUM(UKVOTES) AS SUM_UKVOTES
    FROM UKRESULTS
    GROUP BY UKNUM)

SELECT ROUND(AVG(TURNOUT), 2) AS "AVERAGE TURNOUT"
FROM
(
    SELECT U.UKAREA, SUM_UKVOTES AS "TOTAL VOTE", ROUND(((SUM_UKVOTES/UKELECTORS) * 100), 2) AS TURNOUT
        FROM UKCONSTS U
        INNER JOIN TOTAL_CONST_VOTES CC ON CC.UKNUM = U.UKNUM
);

-- (v) For each party, find the total number of seats won, i.e the number of constituencies in which they were the 
-- winning party. Order the rows by descending total number of seats.
WITH PARTY_WINS AS (
SELECT UKNUM, PARTY
    FROM UKRESULTS R1
    GROUP BY R1.UKNUM, R1.PARTY, UKVOTES
    HAVING R1.UKVOTES = (SELECT MAX(UKVOTES) FROM UKRESULTS R2 WHERE R2.UKNUM = R1.UKNUM)
)

SELECT PARTY, COUNT(UKNUM) AS TOTAL_SEATS
    FROM PARTY_WINS
    GROUP BY PARTY
    ORDER BY TOTAL_SEATS DESC;
    