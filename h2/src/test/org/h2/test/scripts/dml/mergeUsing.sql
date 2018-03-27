-- Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--
CREATE TABLE PARENT(ID INT, NAME VARCHAR, PRIMARY KEY(ID) );
> ok

MERGE INTO PARENT AS P
    USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
    ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
    WHEN MATCHED THEN
        UPDATE SET P.NAME = S.NAME WHERE 2 = 2 WHEN NOT
    MATCHED THEN
        INSERT (ID, NAME) VALUES (S.ID, S.NAME);
> update count: 2

SELECT * FROM PARENT;
> ID NAME
> -- -----
> 1  Coco1
> 2  Coco2

EXPLAIN PLAN
    MERGE INTO PARENT AS P
        USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
        ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
        WHEN MATCHED THEN
            UPDATE SET P.NAME = S.NAME WHERE 2 = 2 WHEN NOT
        MATCHED THEN
            INSERT (ID, NAME) VALUES (S.ID, S.NAME);
> PLAN
> ---------------------------------------------------------------------------------------------------------------------------------
> MERGE INTO PUBLIC.PARENT(ID, NAME) KEY(ID) SELECT X AS ID, ('Coco' || X) AS NAME FROM SYSTEM_RANGE(1, 2) /* PUBLIC.RANGE_INDEX */

DROP TABLE PARENT;
> ok

CREATE SCHEMA SOURCESCHEMA;
> ok

CREATE TABLE SOURCESCHEMA.SOURCE(ID INT PRIMARY KEY, VALUE INT);
> ok

INSERT INTO SOURCESCHEMA.SOURCE VALUES (1, 10), (3, 30), (5, 50);
> update count: 3

CREATE SCHEMA DESTSCHEMA;
> ok

CREATE TABLE DESTSCHEMA.DESTINATION(ID INT PRIMARY KEY, VALUE INT);
> ok

INSERT INTO DESTSCHEMA.DESTINATION VALUES (3, 300), (6, 600);
> update count: 2

MERGE INTO DESTSCHEMA.DESTINATION USING SOURCESCHEMA.SOURCE ON (DESTSCHEMA.DESTINATION.ID = SOURCESCHEMA.SOURCE.ID)
    WHEN MATCHED THEN UPDATE SET VALUE = SOURCESCHEMA.SOURCE.VALUE
    WHEN NOT MATCHED THEN INSERT (ID, VALUE) VALUES (SOURCESCHEMA.SOURCE.ID, SOURCESCHEMA.SOURCE.VALUE);
> update count: 3

SELECT * FROM DESTSCHEMA.DESTINATION;
> ID VALUE
> -- -----
> 1  10
> 3  30
> 5  50
> 6  600
> rows: 4

DROP SCHEMA SOURCESCHEMA CASCADE;
> ok

DROP SCHEMA DESTSCHEMA CASCADE;
> ok