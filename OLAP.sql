select * from supply;

select * from supply_monthly;


-- Rollup adds super-aggregate-row
-- for S#/P#, S# and entire table [last row]
-- returns 42 rows
select S#, P#, J#, sum(Quantity)
    from supply_monthly
    group by rollup (S#, P#, J#);

-- Grouping is used to help identify when a column
-- is (1) or is not (0) part of the super-aggregate-row
select S#, P#, J#, sum(Quantity), grouping(J#)
    from supply_monthly
    group by rollup (S#, P#, J#);
    
-- Group by CUBE to return ALL combination of columns
-- even if the row value for the combination doesn't exist
-- returns 93 rows
select S#, P#, J#, sum(Quantity)
    from supply_monthly
    group by cube (S#, P#, J#);
    
-- Instead of using UNION ALL to join two rollup statements
-- we can use GROUPING SETS
select S#, P#, J#, sum(Quantity)
    from supply_monthly
    group by grouping sets (
        rollup (S#, P#),
        rollup (S#, J#)
    );

-- Using WITH clause enables the common query expression to be
-- factored out with the table resulting from the query expression
-- being used in the subsequent query each time it is referenced
with TOTAL_WEIGHT_SUPPLY as
(
    select SPJ.S#, SPJ.P#, SPJ.J#,
        P.WEIGHT * SPJ.QUANTITY AS TOTAL_WEIGHT
        from supply SPJ, part P
        where SPJ.P# = p.P#
)
        
select S#, P#, J#, TOTAL_WEIGHT
    from TOTAL_WEIGHT_SUPPLY
    where TOTAL_WEIGHT = (
        select max(TOTAL_WEIGHT)
            from TOTAL_WEIGHT_SUPPLY
    );

-- Using CASE statement to pivot
with PIVOT_EXAMPLE as
(
    select P#, J#, City AS SCity, Quantity
        from supply_monthly SM inner join supplier s on s.S# = SM.S#
)

select
    p#,
    j#,
    max(case SCity when 'LEEDS' then Quantity else NULL end) as LEEDS_QTY,
    max(case SCity when 'LONDON' then Quantity else NULL end) as LONDON_QTY,
    max(case SCity when 'LILLE' then Quantity else NULL end) as LILLE_QTY
    from PIVOT_EXAMPLE
    group by P#, J#
    order by P#, J#;
    
-- RANK statement for top n queries
-- retrieve the rows with the 10 highest quantities from the SUPPLY table
select S#, P#, J#, QUANTITY, QUANTITY_RANK, QUANTITY_DENSE_RANK
    from
    (
        select
            S#,
            P#,
            J#,
            QUANTITY,
            rank() over (order by QUANTITY desc) as QUANTITY_RANK,
            dense_rank() over (order by QUANTITY desc) as QUANTITY_DENSE_RANK
            from supply
    )
    where quantity_rank <= 20;

-- WINDOW clause
-- retrieve from the SUPPLY_MONTHLY table in respect of each supply instance
-- the supplier involved, the month, and the total supplied by the supplier in that
-- and the two previous occasions that the supplier has supplied
select s#, MONTH, QUANTITY from supply_monthly where s# = 'S1' order by MONTH;
/*
S1	200301	100
S1	200302	100
S1	200305	100
S1	200305	300
S1	200306	200
S1	200309	100
*/

-- with ROWS window statement
select
    S#,
    MONTH,
    SUM(QUANTITY) OVER (PARTITION BY S# ORDER BY MONTH ROWS 2 PRECEDING) AS "3 SUPPLY TOTAL"
    from supply_monthly;
/*
S1	200301	100
S1	200302	200
S1	200305	300
S1	200305	500
S1	200306	600
S1	200309	600
...
*/

-- with RANGE window statement has the following restrictions
-- 1. only one ordering column may be specified in the ORDER BY clause
-- 2. the ordering column must be one of the following types: NUMERIC, DATETIME or INTERVAL
select
    S#,
    MONTH,
    SUM(QUANTITY) OVER (PARTITION BY S# ORDER BY MONTH RANGE 2 PRECEDING) AS "3 SUPPLY TOTAL"
    from supply_monthly;
/*
S1	200301	100
S1	200302	200
S1	200305	400
S1	200305	400
S1	200306	600
S1	200309	100
...
*/

select s#, MONTH, QUANTITY from supply_monthly where s# = 'S2' order by MONTH;
select
    S#,
    MONTH,
    SUM(QUANTITY) OVER (PARTITION BY S# ORDER BY MONTH RANGE UNBOUNDED PRECEDING) AS "3 SUPPLY TOTAL",
    ROW_NUMBER() OVER (PARTITION BY S# ORDER BY MONTH) AS R_NUM
    from supply_monthly;