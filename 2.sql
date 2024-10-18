-- æwiczenia 18.10.2024 -- Du¿e obiekty binarne

-- 1.
CREATE TABLE MOVIES_COPY AS
SELECT *
FROM ZTPD.MOVIES;

-- 2.
DESC MOVIES_COPY;

-- 3.
SELECT ID, TITLE
FROM MOVIES_COPY
WHERE COVER IS NULL;

-- 4.
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE
FROM MOVIES_COPY
WHERE COVER IS NOT NULL;

-- 5.
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE
FROM MOVIES_COPY
WHERE COVER IS NULL;

-- 6.
SELECT DIRECTORY_NAME, DIRECTORY_PATH
FROM ALL_DIRECTORIES
WHERE DIRECTORY_NAME = 'TPD_DIR';

-- 7.
UPDATE MOVIES_COPY
SET COVER = EMPTY_BLOB(),
    MIME_TYPE = 'image/jpeg'
WHERE ID = 66;

COMMIT;

-- 8.
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS FILESIZE
FROM MOVIES_COPY
WHERE ID IN (65, 66);

-- 9.
DECLARE
  cover_file BFILE;
  cover_blob BLOB;
  file_length NUMBER;
BEGIN
  -- 1) Po³¹czenie zmiennej cover_file z plikiem escape.jpg w katalogu TPD_DIR
  cover_file := BFILENAME('TPD_DIR', 'escape.jpg');

  DBMS_LOB.OPEN(cover_file, DBMS_LOB.LOB_READONLY);

  file_length := DBMS_LOB.GETLENGTH(cover_file);

  -- 2) Odczytanie pustego obiektu BLOB z tabeli MOVIES_COPY z blokad¹ wiersza FOR UPDATE
  SELECT COVER
  INTO cover_blob
  FROM MOVIES_COPY
  WHERE ID = 66
  FOR UPDATE;

  -- 3) Przekopiowanie zawartoœci z BFILE do BLOB
  DBMS_LOB.LOADFROMFILE(cover_blob, cover_file, file_length);

  DBMS_LOB.CLOSE(cover_file);

  UPDATE MOVIES_COPY
  SET COVER = cover_blob
  WHERE ID = 66;

  -- 4) Zatwierdzenie transakcji
  COMMIT;

END;
/

-- 10.
CREATE TABLE TEMP_COVERS (
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);

-- 11.
INSERT INTO TEMP_COVERS (movie_id, image, mime_type)
  VALUES (
    65, 
    BFILENAME('TPD_DIR', 'eagles.jpg'),
    'image/jpeg'
  );

COMMIT;

-- 12.
SELECT movie_id, 
       DBMS_LOB.GETLENGTH(image) AS FILESIZE
FROM TEMP_COVERS
WHERE movie_id = 65;

-- 13.
DECLARE
  cover_file BFILE;
  mime_type VARCHAR2(50);
  
  temp_blob BLOB;
  file_length NUMBER;
BEGIN
  -- 1) Odczytaj lokalizator BFILE i typ MIME z tabeli TEMP_COVERS
  SELECT image, mime_type
  INTO cover_file, mime_type
  FROM TEMP_COVERS
  WHERE movie_id = 65;

  DBMS_LOB.OPEN(cover_file, DBMS_LOB.LOB_READONLY);
  
  -- 2) Utwórz tymczasowy obiekt BLOB
  DBMS_LOB.CREATETEMPORARY(temp_blob, TRUE);

  file_length := DBMS_LOB.GETLENGTH(cover_file);

  -- 3) Przekopiuj zawartoœæ binarn¹ z BFILE do tymczasowego BLOB
  DBMS_LOB.LOADFROMFILE(temp_blob, cover_file, file_length);

  DBMS_LOB.CLOSE(cover_file);

  -- 4) Zapisz tymczasowy BLOB do tabeli MOVIES
  UPDATE MOVIES_COPY
  SET COVER = temp_blob,
      MIME_TYPE = mime_type
  WHERE ID = 65;

  -- 5) Zwolnij tymczasowy BLOB
  DBMS_LOB.FREETEMPORARY(temp_blob);

  -- 6) ZatwierdŸ transakcjê
  COMMIT;

END;
/

-- 14.
SELECT ID, 
       DBMS_LOB.GETLENGTH(COVER) AS FILESIZE
FROM MOVIES_COPY
WHERE ID IN (65, 66);

-- 15.
DROP TABLE MOVIES_COPY;
DROP TABLE TEMP_COVERS;








