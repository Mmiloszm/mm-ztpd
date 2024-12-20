-- Temat 6.

-- �wiczenie 1.

-- A.
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
 and prior t.owner = t.owner;
 
-- B.
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

-- C.
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

-- D.
INSERT INTO MYST_MAJOR_CITIES
SELECT C.FIPS_CNTRY, C.CITY_NAME,
TREAT(ST_POINT.FROM_SDO_GEOM(C.GEOM) AS ST_POINT) STGEOM
FROM MAJOR_CITIES C;
    
-- �wiczenie 2.
-- A.
INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
VALUES (
    'PL', 
    'Szczyrk', 
    ST_POINT(19.036107, 49.718655, 4326)
);



-- �wiczenie 3.
-- A.
CREATE TABLE MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

-- B.
INSERT INTO MYST_COUNTRY_BOUNDARIES
SELECT B.FIPS_CNTRY, B.CNTRY_NAME, ST_MULTIPOLYGON(B.GEOM)
FROM COUNTRY_BOUNDARIES B;

-- C.
SELECT COUNT(*) AS ILE,
 B.STGEOM.ST_GEOMETRYTYPE() TYP
FROM MYST_COUNTRY_BOUNDARIES B
GROUP BY B.STGEOM.ST_GEOMETRYTYPE();

-- D.
SELECT COUNT(*) AS ILE,
 B.STGEOM.ST_ISSIMPLE()
FROM MYST_COUNTRY_BOUNDARIES B
GROUP BY B.STGEOM.ST_ISSIMPLE();


-- �wiczenie 4.
-- A.
SELECT B.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B,
     MYST_MAJOR_CITIES C
WHERE B.STGEOM.ST_CONTAINS(C.STGEOM) = 1
GROUP BY B.CNTRY_NAME;

-- B.
SELECT A.CNTRY_NAME A_NAME, B.CNTRY_NAME B_NAME
FROM MYST_COUNTRY_BOUNDARIES A,
 MYST_COUNTRY_BOUNDARIES B
WHERE A.STGEOM.ST_TOUCHES(B.STGEOM) = 1
AND B.CNTRY_NAME = 'Czech Republic';

-- C.
SELECT DISTINCT B.CNTRY_NAME, R.name
FROM MYST_COUNTRY_BOUNDARIES B, RIVERS R
WHERE B.CNTRY_NAME = 'Czech Republic'
AND ST_LINESTRING(R.GEOM).ST_INTERSECTS(B.STGEOM) = 1;

-- D.
SELECT TREAT(A.STGEOM.ST_UNION(B.STGEOM) as ST_POLYGON).ST_AREA() POWIERZCHNIA
FROM MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
WHERE A.CNTRY_NAME = 'Czech Republic'
AND B.CNTRY_NAME = 'Slovakia';

-- E.
SELECT 
    A.STGEOM AS OBIEKT,
    A.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(B.GEOM)).ST_GEOMETRYTYPE() AS WEGRY_BEZ
FROM 
    MYST_COUNTRY_BOUNDARIES A
JOIN 
    WATER_BODIES B
ON 
    B.NAME = 'Balaton'
WHERE 
    A.CNTRY_NAME = 'Hungary';
    
-- �wiczenie 5.

-- A.
SELECT 
    COUNT(*) AS liczba_miejscowosci
FROM 
    MYST_MAJOR_CITIES A
JOIN 
    MYST_COUNTRY_BOUNDARIES B
ON 
    SDO_WITHIN_DISTANCE(A.STGEOM, B.STGEOM, 'distance=100 unit=km') = 'TRUE'
WHERE 
    B.CNTRY_NAME = 'Poland';
    
-- B.
INSERT INTO USER_SDO_GEOM_METADATA
 SELECT 'MYST_MAJOR_CITIES', 'STGEOM',
 T.DIMINFO, T.SRID
 FROM USER_SDO_GEOM_METADATA T
 WHERE T.TABLE_NAME = 'MAJOR_CITIES';
 
-- C.
CREATE INDEX MYST_MAJOR_CITIES_IDX ON
 MYST_MAJOR_CITIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- D.
SELECT 
    COUNT(*) AS liczba_miejscowosci
FROM 
    MYST_MAJOR_CITIES A
JOIN 
    MYST_COUNTRY_BOUNDARIES B
ON 
    SDO_WITHIN_DISTANCE(A.STGEOM, B.STGEOM, 'distance=100 unit=km') = 'TRUE'
WHERE 
    B.CNTRY_NAME = 'Poland';






    






