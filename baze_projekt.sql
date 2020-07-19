SET SERVEROUTPUT ON
-------------------------------------------------------------------UPITI-------------------------------------------------------------------
------Upit 1: Želimo popis svih putnika koji putuju u klasi Business, relacije na kojima putuju, datum i vrijeme putovanja te aviokompaniju zato što imaju prioritet pri ukrcavanju u odnosu na putnike koji su u klasi Economy.
SELECT karta.broj_karte, putnik.ime, putnik.prezime, karta.broj_sjedala, detalji_leta.broj_leta, detalji_leta.polazak, detalji_leta.dolazak,
detalji_leta.datum_polaska, detalji_leta.vrijeme_polaska, aviokompanija.avio_naziv AS "AVIOKOMPANIJA"
FROM putnik, karta, detalji_leta, aviokompanija
WHERE karta.klasa = 'Business'
AND putnik.putnik_id = karta.putnik_id
AND detalji_leta.let_id=karta.let_id
AND aviokompanija.avio_naziv=detalji_leta.avio_naziv
ORDER BY detalji_leta.datum_polaska;

------Upita 2: Pretpostavimo da osoba traži putovanje i uvjet joj je da cijena karte bude manja od 1600kn i da za jedan kofer od 10kg plati najviše 170kn.
SELECT polazak AS "Polazak", dolazak AS "Dolazak", klasa AS "Klasa",
aviokompanija.avio_naziv AS "Aviokompanija", cijena_karte as "Cijena karte"
FROM aviokompanija INNER JOIN detalji_leta ON
aviokompanija.avio_naziv=detalji_leta.avio_naziv
INNER JOIN karta ON
karta.let_id=detalji_leta.let_id
WHERE cijena_karte <= 1600
AND cijena_prtljage<=170
AND tezina_prtljage=10
AND kolicina_prtljage=1;

-----Upit 3:Vraæamo rute èija je cijena karte klase Premium Economy manja od prosjeka
SELECT DISTINCT polazak, dolazak, datum_polaska, aviokompanija.avio_naziv, avion.tip
FROM detalji_leta, karta, aviokompanija, avion
WHERE karta.klasa='Premium Economy' 
AND detalji_leta.let_id=karta.let_id
AND aviokompanija.avio_naziv=detalji_leta.avio_naziv
AND avion.avion_id=detalji_leta.avion_id
AND cijena_karte < ALL
(SELECT AVG(cijena_karte)
FROM karta
WHERE karta.broj_karte=karta.broj_karte);

SELECT AVG(cijena_karte)
FROM karta;

-----Upit 4: za koju relaciju je kupac koji ima frequent_flyer_nr kupio let i tko æe letjeti na tom letu
SELECT kupac.ime AS "IME KUPCA", kupac.prezime AS "PREZIME KUPCA", milje.frequent_flyer_nr, milje.milje_po_letu,
detalji_leta.polazak, detalji_leta.dolazak, putnik.ime AS "IME PUTNIKA", putnik.prezime AS "PREZIME PUTNIKA"
FROM kupac, milje, kupovina, karta, detalji_leta, putnik
WHERE kupac.kupac_id=milje.kupac_id
AND kupovina.kupovina_id=milje.kupovina_id
AND kupovina.kupovina_id=karta.kupovina_id
AND detalji_leta.let_id=karta.let_id
AND putnik.putnik_id=karta.putnik_id
ORDER BY milje.frequent_flyer_nr;

------Upit 5: Želimo saznati gdje i kada možemo letjeti tijekom željenog razdoblja
SELECT detalji_leta.polazak, detalji_leta.dolazak, detalji_leta.datum_polaska
FROM detalji_leta
WHERE TO_DATE('09-04-2020 ','DD/MM/YYYY') < datum_polaska AND TO_DATE('26-06-2020 ','DD/MM/YYYY') > datum_polaska
ORDER BY detalji_leta.datum_polaska;


-----Upit 6: Želimo saznati gdje možemo letjeti sa nekog željenog aerodroma
SELECT detalji_leta.polazak, detalji_leta.dolazak, detalji_leta.datum_polaska
FROM detalji_leta
WHERE polazak = 'AMS';

-----Upit 7: Ispisati naziv svih aviokompanija, polazni aerodrom i dolazni aerodrom gdje je cijena karte < 2000, a tip aviona je Airbus i nije podtipa Airbus A2-

SELECT DISTINCT a1.avio_naziv AS "Aviokompanija", dl1.polazak, dl1.dolazak, cijena_karte, av1.tip FROM
aviokompanija a1 INNER JOIN detalji_leta dl1 ON a1.avio_naziv=dl1.avio_naziv
INNER JOIN avion av1 ON av1.avion_id=dl1.avion_id
INNER JOIN karta k1 ON k1.let_id = dl1.let_id
WHERE cijena_karte<2000
AND av1.tip LIKE '%Airbus%'
AND a1.avio_naziv NOT IN
    (SELECT a2.avio_naziv FROM
    aviokompanija a2 INNER JOIN detalji_leta dl2 ON a2.avio_naziv=dl2.avio_naziv
    INNER JOIN avion av2 ON av2.avion_id=dl2.avion_id
    INNER JOIN karta k2 ON k2.let_id = dl2.let_id
    WHERE cijena_karte<2000
    AND av2.tip LIKE '%A2%')
ORDER BY a1.avio_naziv;


-------------------------------------------------------------------PROCEDURE-------------------------------------------------------------------

------Procedura 1: Procedura za unos putnika

SELECT * FROM putnik WHERE putnik_id = (SELECT MAX(putnik_id) FROM putnik); 

CREATE SEQUENCE putnik_sequence
START WITH 36
INCREMENT BY 1
NOCACHE;

CREATE PROCEDURE unos_putnik (
unos_putnik_ime IN putnik.ime%TYPE,
unos_putnik_prezime IN putnik.prezime%TYPE,
unos_putnik_datrodj IN putnik.datum_rodj%TYPE,
unos_putnik_email IN putnik.email%TYPE,
unos_putnik_drzava IN putnik.drzava%TYPE,
unos_putnik_brputovnice IN putnik.broj_putovnice%TYPE
) AS
putnik_count1 INTEGER;

BEGIN
SELECT COUNT(*)
INTO putnik_count1
FROM putnik
WHERE email=unos_putnik_email;

IF putnik_count1=0 THEN
INSERT INTO putnik(putnik_id, ime, prezime, datum_rodj, email, drzava, broj_putovnice)
VALUES(putnik_sequence.nextval, unos_putnik_ime, unos_putnik_prezime, unos_putnik_datrodj,
unos_putnik_email, unos_putnik_drzava, unos_putnik_brputovnice);
COMMIT;
END IF;
END unos_putnik;
/

DROP PROCEDURE unos_putnik;
DROP SEQUENCE putnik_sequence;

CALL unos_putnik ('Benedict', 'Cumberbatch', '19-07-1976', 'bcumberbatch@gmail.com', 'Turska', '123D456789');

SELECT * FROM putnik
ORDER BY putnik_id;


--------Procedura 2: Procedura za ažuriranje putnika

CREATE PROCEDURE azuriraj_putnik (
azuriraj_putnik_ime IN putnik.ime%TYPE,
azuriraj_putnik_prezime IN putnik.prezime%TYPE,
azuriraj_putnik_datrodj IN putnik.datum_rodj%TYPE,
azuriraj_putnik_email IN putnik.email%TYPE,
azuriraj_putnik_drzava IN putnik.drzava%TYPE,
azuriraj_putnik_brputovnice IN putnik.broj_putovnice%TYPE) AS
putnik_count INTEGER;
BEGIN

SELECT COUNT(*)
INTO putnik_count
FROM putnik
WHERE broj_putovnice=azuriraj_putnik_brputovnice;

IF putnik_count=1 THEN
UPDATE putnik
SET putnik.ime=azuriraj_putnik_ime, putnik.prezime=azuriraj_putnik_prezime,
putnik.datum_rodj=azuriraj_putnik_datrodj, putnik.email=azuriraj_putnik_email,
putnik.drzava=azuriraj_putnik_drzava
WHERE broj_putovnice=azuriraj_putnik_brputovnice;

COMMIT;
END IF;
END azuriraj_putnik;
/

--DROP PROCEDURE azuriraj_putnik;

CALL azuriraj_putnik ('Benedict', 'Cumberbatch', '19-07-1976', 'bcumberbatch76@gmail.com', 'Nizozemska', '123D456789');

SELECT * FROM putnik
ORDER BY putnik_id;


---------Procedura 3: Ispis podataka o putniku
CREATE PROCEDURE putnik_ispis (
p_putnik_id NUMBER ) IS
p_putnik putnik%ROWTYPE;
BEGIN
SELECT *
INTO p_putnik
FROM putnik
WHERE putnik_id=p_putnik_id;
dbms_output.put_line(p_putnik.ime || ' ' || p_putnik.prezime || ', ' || p_putnik.datum_rodj  || ', ' || p_putnik.email);
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line( SQLERRM );
END;
/

DROP PROCEDURE putnik_ispis;

EXEC putnik_ispis(5);

--------Procedura 4: Procedura koja vraæa dostupne relacije za odreðeni datum putovanja
CREATE PROCEDURE dostupne_relacije (
p_datum_polaska IN detalji_leta.datum_polaska%TYPE)
AS
BEGIN
DECLARE
p_polazak detalji_leta.polazak%TYPE;
p_dolazak detalji_leta.dolazak%TYPE;
CURSOR ispis_letova IS
SELECT detalji_leta.polazak, detalji_leta.dolazak
FROM detalji_leta
WHERE datum_polaska=p_datum_polaska;
BEGIN
OPEN ispis_letova;
LOOP
FETCH ispis_letova
INTO p_polazak, p_dolazak;
EXIT WHEN ispis_letova%NOTFOUND;
dbms_output.put_line(p_polazak || '-' || p_dolazak);
END LOOP;
CLOSE ispis_letova;
END;
END dostupne_relacije;
/

DROP PROCEDURE dostupne_relacije;

CALL dostupne_relacije('25-06-2020');


------Procedura 5: Brisanje aviokompanije zbog èega dolazi i do brisanja tablice detalji_leta i tablie karta

CREATE OR REPLACE PROCEDURE otkazan_let(
    p_avio_naziv IN aviokompanija.avio_naziv%TYPE
) AS
counter INTEGER;
p_let_id detalji_leta.let_id %TYPE;

CURSOR cursor_let IS
SELECT let_id
FROM detalji_leta
WHERE avio_naziv=p_avio_naziv;

BEGIN

SELECT COUNT (*) INTO counter
FROM aviokompanija
WHERE avio_naziv=p_avio_naziv;

IF counter=1 THEN
OPEN cursor_let;
LOOP
FETCH cursor_let INTO p_let_id;
EXIT WHEN cursor_let%NOTFOUND;
--tablica karta
DELETE FROM karta
WHERE let_id=p_let_id;
END LOOP;
--detalji_leta
DELETE FROM detalji_leta
WHERE avio_naziv=p_avio_naziv;
DELETE FROM aviokompanija
WHERE avio_naziv=p_avio_naziv;

CLOSE cursor_let;
COMMIT;
END IF;
END;
/

DROP PROCEDURE otkazan_let;

CALL otkazan_let('Croatia Airlines');

-------Procedura 6: Procedura koja ispisuje ime i prezime putnika ako joj pošaljemo let_id i sjedalo ili sjedalo, polazak, dolazak, datum_polaska, vrijeme_polaska

CREATE OR REPLACE PROCEDURE proc_putnik (
    p_sjedalo IN karta.broj_sjedala%TYPE,
    p_let_id IN detalji_leta.let_id%TYPE,
    p_polazak IN detalji_leta.polazak%TYPE,
    p_dolazak IN detalji_leta.dolazak%TYPE,
    p_datum_polaska in detalji_leta.datum_polaska%TYPE,
    p_vrijeme_polaska in detalji_leta.vrijeme_polaska%TYPE)
AS
	p_ime varchar(30);
	p_prezime varchar(30);
	p_let_id_count number;
	p_id detalji_leta.let_id%TYPE;
BEGIN
	IF p_let_id IS NOT NULL THEN
		SELECT COUNT(*)
		INTO p_let_id_count
		FROM detalji_leta
		WHERE let_id = p_let_id;
		IF p_let_id_count = 1 THEN
			SELECT ime
			INTO p_ime
			FROM putnik pu
			JOIN karta ka USING(putnik_id)
			WHERE let_id = p_let_id  AND broj_sjedala = p_sjedalo;

			SELECT prezime
			INTO p_prezime
			FROM putnik pu
			JOIN karta ka USING(putnik_id)
			WHERE let_id = p_let_id AND broj_sjedala = p_sjedalo;
			DBMS_OUTPUT.PUT_LINE(p_ime || ' ' || p_prezime);
		END IF;
	ELSE
		SELECT let_id
		INTO p_id
		FROM detalji_leta
		WHERE polazak = p_polazak AND dolazak = p_dolazak AND datum_polaska = p_datum_polaska AND vrijeme_polaska = p_vrijeme_polaska;

		SELECT ime
			INTO p_ime
			FROM putnik pu
			JOIN karta ka USING(putnik_id)
			WHERE let_id = p_id  AND broj_sjedala = p_sjedalo;

			SELECT prezime
			INTO p_prezime
			FROM putnik pu
			JOIN karta ka USING(putnik_id)
			WHERE let_id = p_id AND broj_sjedala = p_sjedalo;
			DBMS_OUTPUT.PUT_LINE(p_ime || ' ' || p_prezime);
	END IF;
END proc_putnik;
/

CALL proc_putnik ('07D', 1, null, null, null, null);

CALL proc_putnik ('07D', null, 'MAD', 'LHR', TO_DATE('06-26-2020 ','MM-DD-YYYY'), '16:20');

DROP PROCEDURE proc_putnik;

------Funkcija: Raèuna ukupno troškove za neki let
CREATE FUNCTION ukupna_cijena(
    f_putnik_id IN NUMBER,
    f_broj_karte IN VARCHAR
    ) RETURN FLOAT AS
    ukupni_troskovi_karte FLOAT;
BEGIN
    SELECT (COALESCE(cijena_karte,0) + COALESCE(cijena_prtljage,0) + COALESCE(cijena_hrane,0) + COALESCE(cijena_osiguranja,0) + COALESCE(cijena_lounge_salona,0))
    INTO ukupni_troskovi_karte
    FROM karta
    WHERE putnik_id=f_putnik_id AND broj_karte=f_broj_karte;
    RETURN ukupni_troskovi_karte;
END ukupna_cijena;
/

SELECT ukupna_cijena(2, '1111121111') AS "Ukupni troškovi"
FROM dual;

--DROP FUNCTION ukupna_cijena;


-------Trigger 1:
CREATE TRIGGER trigger_provizija
BEFORE INSERT OR UPDATE
ON kupovina_agencija
FOR EACH ROW WHEN (new.provizija>0.20)
BEGIN
    raise_application_error(-20000, 'Provizija je previsoka.');
END trigger_provizija;
/

UPDATE kupovina_agencija
SET provizija = 0.21
WHERE kupovina_id='A7';

--DROP TRIGGER trigger_provizija;

-------Trigger 2: Želimo osigurati da pri ažuriranju leta datum_polaska nije raniji nego što je bio prvobitno predviðen
CREATE TRIGGER trigger_detalji_leta
BEFORE UPDATE OF datum_polaska
ON detalji_leta
FOR EACH ROW WHEN (NEW.datum_polaska < OLD.datum_polaska)
BEGIN
    raise_application_error(-20000, 'Avion ne smije krenuti ranije od predviðenog');
END trigger_detalji_leta;
/

UPDATE detalji_leta
SET datum_polaska = TO_DATE('09-08-2020')
WHERE broj_leta='WUK8130';

--DROP TRIGGER trigger_detalji_leta;

-------Trigger 3: Ovim triggerom osiguravamo da svaka kupovina èiji id poèinje sa 'S' mora biti u kupovina_samostalna, a ne u kupovina_agencija
CREATE TRIGGER trigger_kupovina_agencija
BEFORE INSERT Or UPDATE
ON kupovina_agencija
FOR EACH ROW WHEN (new.kupovina_id LIKE '%S%')
BEGIN
    raise_application_error(-20000, 'Unesena kupovina izvršena je samostalno.');
END trigger_kupovina_agencija;
/

INSERT INTO kupovina_agencija VALUES ('S2', '6', 0.14, null);

--DROP TRIGGER trigger_kupovina_agencija;

------Trigger 4: Ovim triggerom osiguravamo da svaka kupovina èiji id poèinje sa 'A' mora biti u kupovina_agencija, a ne u kupovina_samostalna

CREATE TRIGGER trigger_kupovina_samostalna
BEFORE INSERT OR UPDATE OF kupovina_id
ON kupovina_samostalna
FOR EACH ROW WHEN (new.kupovina_id LIKE '%A%')
BEGIN
    raise_application_error(-20000, 'Unesena kupovina izvršena je preko agencije.');
END trigger_kupovina_samostalna;
/

INSERT INTO kupovina_samostalna VALUES ('A4');

--DROP TRIGGER trigger_kupovina_samostalna;

------Indexi

CREATE INDEX index_broj_leta ON detalji_leta(broj_leta);

CREATE INDEX index_putnik_email ON putnik(email);

SELECT detalji_leta.broj_leta
FROM detalji_leta;

SELECT putnik.email
FROM putnik
WHERE putnik_id>10;

--DROP INDEX index_broj_leta;
--DROP INDEX index_putnik_email;


