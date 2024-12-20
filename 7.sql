-- Zadania 7. 29/11/2024

-- �wiczenie 1.

-- A.
CREATE TABLE A6_LRS (
    GEOM SDO_GEOMETRY
);

-- B.
SELECT SR.ID,
 SDO_GEOM.SDO_LENGTH(SR.GEOM, 1, 'unit=km') DISTANCE,
 ST_LINESTRING(SR.GEOM) .ST_NUMPOINTS() ST_NUMPOINTS
FROM STREETS_AND_RAILROADS SR, MAJOR_CITIES C
WHERE SDO_RELATE(SR.GEOM,
 SDO_GEOM.SDO_BUFFER(C.GEOM, 10, 1, 'unit=km'),
'MASK=ANYINTERACT') = 'TRUE'
and C.CITY_NAME = 'Koszalin';

INSERT INTO A6_LRS
 SELECT SDO_LRS.CONVERT_TO_LRS_GEOM(SR.GEOM, 0, 276.681)
 FROM STREETS_AND_RAILROADS SR
 WHERE SR.ID = 56;

-- C.
SELECT DISTINCT
 SDO_GEOM.SDO_LENGTH(SR.GEOM, 1, 'unit=km') DISTANCE,
 ST_LINESTRING(SR.GEOM) .ST_NUMPOINTS() ST_NUMPOINTS
FROM STREETS_AND_RAILROADS SR, MAJOR_CITIES C
WHERE SR.ID = 56;

-- D.
UPDATE A6_LRS
SET GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(
               GEOM,
               0,
               SDO_GEOM.SDO_LENGTH(GEOM, 0.005)
           )
WHERE GEOM IS NOT NULL;

-- E.
INSERT INTO USER_SDO_GEOM_METADATA
VALUES ('A6_LRS','GEOM',
MDSYS.SDO_DIM_ARRAY(
 MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
 MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
 MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1) ),
 8307);
 
-- F.
CREATE INDEX geom_idx ON A6_LRS(GEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX;


-- �wiczenie 2.

-- A.
SELECT SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
FROM A6_LRS;

-- B.
SELECT 
 SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
FROM A6_LRS;

-- C.
SELECT SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150 from A6_LRS;

-- D.
SELECT SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPPED from A6_LRS;

-- E.
SELECT SDO_LRS.GET_NEXT_SHAPE_PT(A6.GEOM, C.GEOM) WJAZD_NA_A6
FROM A6_LRS A6, MAJOR_CITIES C
WHERE C.CITY_NAME = 'Slupsk';

-- F.
WITH gas_pipeline AS (
    SELECT SDO_LRS.OFFSET_GEOM_SEGMENT(
               A6.GEOM,
               M.DIMINFO,
               50,
               200,
               -50,
               'unit=m arc_tolerance=0.01'
           ) AS pipeline_geom
    FROM A6_LRS A6, USER_SDO_GEOM_METADATA M
    WHERE M.TABLE_NAME = 'A6_LRS' AND M.COLUMN_NAME = 'GEOM'
)
SELECT 
    SDO_GEOM.SDO_LENGTH(pipeline_geom, 0.005) * 1000000 AS koszt
FROM gas_pipeline;

