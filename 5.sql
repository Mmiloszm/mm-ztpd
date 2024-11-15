-- æwiczenia 5.

-- æwiczenie 1

-- A.
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
    'FIGURY',
    'KSZTALT',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 0, 100, 0.01),
        MDSYS.SDO_DIM_ELEMENT('Y', 0, 100, 0.01)
    ),
    NULL
);

-- B.
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) FROM FIGURY;

-- C.
CREATE INDEX idx_figury_ksztalt ON FIGURY(KSZTALT)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;
   
-- D.
SELECT ID
FROM FIGURY
WHERE SDO_FILTER(
    KSZTALT,
    SDO_GEOMETRY(
        2001,
        NULL,
        SDO_POINT_TYPE(3, 3, NULL),
        NULL,
        NULL
    )
) = 'TRUE';

/* Operator SDO_FILTER, który wykorzystuje
jedynie pierwsz¹ fazê zapytania, czyli daje w
wyniku zbiór "kandydatów", dla indeksu
r-tree uzna, ¿e z punktem 3,3 maj¹ "coœ
wspólnego" wszystkie 3 geometrie */

-- E.
SELECT ID
FROM FIGURY
WHERE SDO_RELATE(
    KSZTALT,
    SDO_GEOMETRY(
        2001,
        NULL,
        SDO_POINT_TYPE(3, 3, NULL),
        NULL,
        NULL),
        'mask=ANYINTERACT'
    ) = 'TRUE';
 
-- wynik odpowiada prawdzie

-- æwiczenie 2.

-- A.
SELECT 
    CITY_NAME,
    vertex.X AS X_COORDINATE,
    vertex.Y AS Y_COORDINATE
FROM 
    MAJOR_CITIES,
    TABLE(SDO_UTIL.GETVERTICES(GEOM)) vertex
WHERE 
    CITY_NAME = 'Warsaw';
    
    
SELECT A.CITY_NAME, SDO_NN_DISTANCE(1) DISTANCE
FROM MAJOR_CITIES A
WHERE SDO_NN(GEOM,MDSYS.SDO_GEOMETRY(2001, 8307, NULL,
 MDSYS.SDO_ELEM_INFO_ARRAY(1, 1, 1),
MDSYS.SDO_ORDINATE_ARRAY(21.01187, 52.24494)),
 'sdo_num_res=10 unit=km',1) = 'TRUE' AND CITY_NAME != 'Warsaw';
 
-- B.

SELECT 
    CITY_NAME
FROM 
    MAJOR_CITIES
WHERE 
    SDO_WITHIN_DISTANCE(
        GEOM,
        (SELECT GEOM FROM MAJOR_CITIES WHERE CITY_NAME = 'Warsaw'),
        'distance=100 unit=km'
    ) = 'TRUE' AND CITY_NAME != 'Warsaw';
    
-- C.

SELECT
    CNTRY_NAME,
    CITY_NAME
FROM 
    MAJOR_CITIES
WHERE 
    SDO_RELATE(
        GEOM,
        (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Slovakia'),
        'MASK=INSIDE'
    ) = 'TRUE';
    
-- D.
WITH neighboring_countries AS (
    SELECT 
        CNTRY_NAME
    FROM 
        COUNTRY_BOUNDARIES
    WHERE 
        SDO_RELATE(
            GEOM,
            (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'),
            'MASK=TOUCH'
        ) = 'TRUE'
),
non_neighboring_countries AS (
    SELECT 
        CNTRY_NAME,
        GEOM
    FROM 
        COUNTRY_BOUNDARIES
    WHERE 
        CNTRY_NAME NOT IN (SELECT CNTRY_NAME FROM neighboring_countries)
)
SELECT 
    ncc.CNTRY_NAME AS panstwo,
    SDO_GEOM.SDO_DISTANCE(
        (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'),
        ncc.GEOM,
        0.005
    ) / 1000 AS odl
FROM 
    non_neighboring_countries ncc
WHERE ncc.CNTRY_NAME != 'Poland';

-- æwiczenie 3.

-- A.
WITH poland_boundary AS (
    SELECT GEOM
    FROM COUNTRY_BOUNDARIES
    WHERE CNTRY_NAME = 'Poland'
),
neighbors AS (
    SELECT 
        CB.CNTRY_NAME,
        SDO_GEOM.SDO_INTERSECTION(
            CB.GEOM,
            (SELECT GEOM FROM poland_boundary),
            0.005
        ) AS shared_boundary
    FROM 
        COUNTRY_BOUNDARIES CB
    WHERE 
        CB.CNTRY_NAME != 'Poland'
        AND SDO_RELATE(
            CB.GEOM,
            (SELECT GEOM FROM poland_boundary),
            'MASK=TOUCH'
        ) = 'TRUE'
)
SELECT 
    cntry_name,
    (SDO_GEOM.SDO_LENGTH(shared_boundary, 0.005) / 1000) AS odleglosc
FROM 
    neighbors
ORDER BY 
    odleglosc DESC;
    
-- B.
SELECT 
    CNTRY_NAME
FROM 
    COUNTRY_BOUNDARIES
ORDER BY 
    SDO_GEOM.SDO_AREA(GEOM, 0.005) DESC
FETCH FIRST 1 ROWS ONLY;

-- C.
WITH cities_geom AS (
    SELECT SDO_GEOM.SDO_UNION(
        (SELECT GEOM FROM MAJOR_CITIES WHERE CITY_NAME = 'Warsaw'),
        (SELECT GEOM FROM MAJOR_CITIES WHERE CITY_NAME = 'Lodz'),
        0.005
    ) AS combined_geom
    FROM DUAL
),
mbr AS (
    SELECT 
        SDO_GEOM.SDO_MBR(combined_geom) AS bounding_box
    FROM 
        cities_geom
)
SELECT 
    (SDO_GEOM.SDO_AREA(bounding_box, 0.005) / 1000000)  AS sq_km
FROM 
    mbr;
    
-- D.
WITH country_centroids AS (
    SELECT 
        CNTRY_NAME,
        SDO_GEOM.SDO_CENTROID(GEOM, 0.005) AS CENTROID
    FROM 
        COUNTRY_BOUNDARIES
),
city_distances AS (
    SELECT 
        c.CNTRY_NAME AS country_name,
        m.CITY_NAME AS city_name,
        SDO_GEOM.SDO_DISTANCE(
            m.GEOM,
            c.CENTROID,
            0.005
        ) AS distance_to_centroid
    FROM 
        MAJOR_CITIES m
    JOIN 
        country_centroids c
    ON 
        SDO_WITHIN_DISTANCE(
            m.GEOM, 
            c.CENTROID, 
            'distance=1000000 unit=meter'
        ) = 'TRUE'
)
SELECT 
    country_name,
    city_name
FROM (
    SELECT 
        country_name,
        city_name,
        ROW_NUMBER() OVER (ORDER BY distance_to_centroid ASC) AS rn
    FROM 
        city_distances
)
WHERE 
    rn = 1;
    
-- E.
WITH poland_geom AS (
    SELECT GEOM
    FROM COUNTRY_BOUNDARIES
    WHERE CNTRY_NAME = 'Poland'
),
rivers_in_poland AS (
    SELECT 
        r.NAME,
        SDO_GEOM.SDO_INTERSECTION(
            r.GEOM,
            (SELECT GEOM FROM poland_geom),
            0.005
        ) AS river_segment_in_poland
    FROM 
        RIVERS r
    WHERE 
        SDO_RELATE(
            r.GEOM,
            (SELECT GEOM FROM poland_geom),
            'MASK=ANYINTERACT'
        ) = 'TRUE'
)
SELECT 
    name,
    SUM ((SDO_GEOM.SDO_LENGTH(river_segment_in_poland, 0.005)) / 1000) AS dlugosc
FROM 
    rivers_in_poland
WHERE 
    river_segment_in_poland IS NOT NULL
GROUP BY 
    name
ORDER BY 
    dlugosc DESC;


































