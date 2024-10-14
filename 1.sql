-- Obiektowo-relacyjne bazy danych - æwiczenia (11.10)
-- 1.
CREATE TYPE SAMOCHOD AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2)
);

CREATE TABLE SAMOCHODY OF SAMOCHOD;

INSERT INTO SAMOCHODY VALUES (SAMOCHOD('Toyota', 'Corolla', 120000, TO_DATE('2015-06-15', 'YYYY-MM-DD'), 50000));
INSERT INTO SAMOCHODY VALUES (SAMOCHOD('Honda', 'Civic', 80000, TO_DATE('2017-03-20', 'YYYY-MM-DD'), 65000));
INSERT INTO SAMOCHODY VALUES (SAMOCHOD('Ford', 'Focus', 150000, TO_DATE('2013-09-05', 'YYYY-MM-DD'), 30000));
INSERT INTO SAMOCHODY VALUES (SAMOCHOD('BMW', '3 Series', 60000, TO_DATE('2018-11-10', 'YYYY-MM-DD'), 90000));

DESC SAMOCHOD;

SELECT * FROM SAMOCHODY;

-- 2.
CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    model_samochodu SAMOCHOD
);

desc WLASCICIEL;

CREATE TABLE WLASCICIELE OF WLASCICIEL;

INSERT INTO WLASCICIELE VALUES (
    WLASCICIEL('Jan', 'Kowalski', SAMOCHOD('Toyota', 'Corolla', 120000, TO_DATE('2015-06-15', 'YYYY-MM-DD'), 50000))
);

INSERT INTO WLASCICIELE VALUES (
    WLASCICIEL('Anna', 'Nowak', SAMOCHOD('Honda', 'Civic', 80000, TO_DATE('2017-03-20', 'YYYY-MM-DD'), 65000))
);

INSERT INTO WLASCICIELE VALUES (
    WLASCICIEL('Piotr', 'Zieliñski', SAMOCHOD('Ford', 'Focus', 150000, TO_DATE('2013-09-05', 'YYYY-MM-DD'), 30000))
);

-- 3.
ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        lata NUMBER;
        aktualna_wartosc NUMBER;
    BEGIN
        lata := TRUNC(MONTHS_BETWEEN(SYSDATE, data_produkcji) / 12);
        aktualna_wartosc := cena * POWER(0.9, lata);
        RETURN aktualna_wartosc;
    END;
END;

-- 4.
ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER,
    MAP MEMBER FUNCTION zuzycie RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
     MEMBER FUNCTION wartosc RETURN NUMBER IS
        lata NUMBER;
        aktualna_wartosc NUMBER;
    BEGIN
        lata := TRUNC(MONTHS_BETWEEN(SYSDATE, data_produkcji) / 12);
        aktualna_wartosc := cena * POWER(0.9, lata);
        RETURN aktualna_wartosc;
    END;
    
    MAP MEMBER FUNCTION zuzycie RETURN NUMBER IS
        wiek NUMBER;
        dodatkowe_lata NUMBER;
    BEGIN
        wiek := MONTHS_BETWEEN(SYSDATE, data_produkcji) / 12;
        dodatkowe_lata := kilometry / 10000;
        RETURN wiek + dodatkowe_lata;
    END;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

--  5.
DROP TABLE WLASCICIELE;
DROP TABLE SAMOCHODY;

CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);

CREATE OR REPLACE TYPE SAMOCHOD AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10, 2),
    wlasciciel_samochodu REF WLASCICIEL,
    MEMBER FUNCTION wartosc RETURN NUMBER,
    MAP MEMBER FUNCTION zuzycie RETURN NUMBER
);

CREATE TABLE WLASCICIELE OF WLASCICIEL;
CREATE TABLE SAMOCHODY OF SAMOCHOD;

INSERT INTO WLASCICIELE VALUES (WLASCICIEL('Jan', 'Kowalski'));
INSERT INTO WLASCICIELE VALUES (WLASCICIEL('Anna', 'Nowak'));
INSERT INTO WLASCICIELE VALUES (WLASCICIEL('Piotr', 'Zieliñski'));
INSERT INTO WLASCICIELE VALUES (WLASCICIEL('Katarzyna', 'Wiœniewska'));

DECLARE
  v_wlasciciel REF WLASCICIEL;
BEGIN
  SELECT REF(w) INTO v_wlasciciel FROM WLASCICIELE w WHERE w.imie = 'Jan' AND w.nazwisko = 'Kowalski';
  INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('Toyota', 'Corolla', 120000, TO_DATE('2015-06-15', 'YYYY-MM-DD'), 50000, v_wlasciciel)
  );

  SELECT REF(w) INTO v_wlasciciel FROM WLASCICIELE w WHERE w.imie = 'Anna' AND w.nazwisko = 'Nowak';
  INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('Honda', 'Civic', 80000, TO_DATE('2017-03-20', 'YYYY-MM-DD'), 65000, v_wlasciciel)
  );

  SELECT REF(w) INTO v_wlasciciel FROM WLASCICIELE w WHERE w.imie = 'Piotr' AND w.nazwisko = 'Zieliñski';
  INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('Ford', 'Focus', 150000, TO_DATE('2013-09-05', 'YYYY-MM-DD'), 30000, v_wlasciciel)
  );

  SELECT REF(w) INTO v_wlasciciel FROM WLASCICIELE w WHERE w.imie = 'Katarzyna' AND w.nazwisko = 'Wiœniewska';
  INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('BMW', '3 Series', 60000, TO_DATE('2018-11-10', 'YYYY-MM-DD'), 90000, v_wlasciciel)
  );
END;

SELECT * from SAMOCHODY;

-- 6.
DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
 moje_przedmioty(1) := 'MATEMATYKA';
 moje_przedmioty.EXTEND(9);
 FOR i IN 2..10 LOOP
 moje_przedmioty(i) := 'PRZEDMIOT_' || i;
 END LOOP;
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 moje_przedmioty.TRIM(2);
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.EXTEND();
 moje_przedmioty(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

-- 7.

DECLARE
 TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
 moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
 moje_ksiazki(1) := 'PAN TADEUSZ';
 moje_ksiazki.EXTEND(9);
 FOR i IN 2..10 LOOP
 moje_ksiazki(i) := 'KSIAZKA' || i;
 END LOOP;
 FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
 END LOOP;
 moje_ksiazki.TRIM(2);
 FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
 moje_ksiazki.EXTEND();
 moje_ksiazki(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
 moje_ksiazki.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_ksiazki.COUNT());
END;

-- 8.
DECLARE
 TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
 moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
 moi_wykladowcy.EXTEND(2);
 moi_wykladowcy(1) := 'MORZY';
 moi_wykladowcy(2) := 'WOJCIECHOWSKI';
 moi_wykladowcy.EXTEND(8);
 FOR i IN 3..10 LOOP
 moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
 END LOOP;
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.TRIM(2);
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.DELETE(5,7);
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 moi_wykladowcy(5) := 'ZAKRZEWICZ';
 moi_wykladowcy(6) := 'KROLIKOWSKI';
 moi_wykladowcy(7) := 'KOSZLAJDA';
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- 9.
DECLARE
  TYPE t_miesiace IS TABLE OF VARCHAR2(20);
  miesiace t_miesiace := t_miesiace();
BEGIN
  miesiace.EXTEND(12);
  miesiace(1) := 'Styczeñ';
  miesiace(2) := 'Luty';
  miesiace(3) := 'Marzec';
  miesiace(4) := 'Kwiecieñ';
  miesiace(5) := 'Maj';
  miesiace(6) := 'Czerwiec';
  miesiace(7) := 'Lipiec';
  miesiace(8) := 'Sierpieñ';
  miesiace(9) := 'Wrzesieñ';
  miesiace(10) := 'PaŸdziernik';
  miesiace(11) := 'Listopad';
  miesiace(12) := 'Grudzieñ';

  DBMS_OUTPUT.PUT_LINE('Lista miesiêcy:');
  FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(miesiace(i));
  END LOOP;

  miesiace.DELETE(4);
  miesiace.DELETE(7);

  DBMS_OUTPUT.PUT_LINE('Lista miesiêcy po usuniêciu:');
  FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
    IF miesiace.EXISTS(i) THEN
      DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
  DBMS_OUTPUT.PUT_LINE('Liczba elementów: ' || miesiace.COUNT());
END;

-- 10.
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
 nazwa VARCHAR2(50),
 kraj VARCHAR2(30),
 jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
 numer NUMBER,
 egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

-- 11.

CREATE OR REPLACE TYPE produkt AS OBJECT (
    nazwa VARCHAR2(50),
    cena NUMBER(10, 2)
);

CREATE OR REPLACE TYPE koszyk_produktow AS TABLE OF produkt;

CREATE TABLE ZAKUPY (
    id_zakupu NUMBER PRIMARY KEY,
    data_zakupu DATE,
    koszyk_produktow koszyk_produktow
) NESTED TABLE koszyk_produktow STORE AS koszyk_produktow_nt;

INSERT INTO ZAKUPY VALUES (
    1,
    SYSDATE,
    koszyk_produktow(produkt('Produkt A', 19.99), produkt('Produkt B', 29.99))
);
INSERT INTO ZAKUPY VALUES (
    2,
    SYSDATE,
    koszyk_produktow(produkt('Produkt C', 15.50), produkt('Produkt A', 19.99))
);
INSERT INTO ZAKUPY VALUES (
    3,
    SYSDATE,
    koszyk_produktow(produkt('Produkt D', 25.00))
);

-- Usuwanie transakcji
DELETE FROM ZAKUPY z
WHERE EXISTS (
    SELECT 1
    FROM TABLE(z.koszyk_produktow) p
    WHERE p.nazwa = 'Produkt A'
);

-- 12.
CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN dzwiek;
 END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
 RETURN glosnosc||':'||dzwiek;
 END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;
/

DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
 dbms_output.put_line(tamburyn.graj);
 dbms_output.put_line(trabka.graj);
 dbms_output.put_line(trabka.graj('glosno'));
 dbms_output.put_line(fortepian.graj);
END;

-- 13.

CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
 RETURN 'upolowana ofiara: '||ofiara;
 END;
END;
DECLARE
 KrolLew lew := lew('LEW',4);
 InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
 DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

-- 14.
DECLARE
 tamburyn instrument;
 cymbalki instrument;
 trabka instrument_dety;
 saksofon instrument_dety;
BEGIN
 tamburyn := instrument('tamburyn','brzdek-brzdek');
 cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
 trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
 -- saksofon := instrument('saksofon','tra-taaaa');
 -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

-- 15.
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
);
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;












