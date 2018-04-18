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
    