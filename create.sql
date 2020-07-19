---------------KREIRANJE TABLICA--------------
DROP TABLE milje;
DROP TABLE karta;
DROP TABLE detalji_leta;
DROP TABLE aviokompanija;
DROP TABLE avion;
DROP TABLE putnik;
DROP TABLE kupovina_agencija;
DROP TABLE agencija;
DROP TABLE kupovina_samostalna;
DROP TABLE kupovina;
DROP TABLE kupac;


CREATE TABLE putnik (
    putnik_id NUMBER(10) PRIMARY KEY,
    ime VARCHAR(30) NOT NULL,
    prezime VARCHAR(30) NOT NULL,
    datum_rodj DATE NOT NULL,
    email VARCHAR(35) NOT NULL,
    drzava VARCHAR(30) NOT NULL,
    broj_putovnice VARCHAR(15) NOT NULL
);
--DESCRIBE putnik;


CREATE TABLE agencija (
    agencija_id NUMBER(10) PRIMARY KEY,
    naziv VARCHAR(20) NOT NULL
);
--DESCRIBE agencija;

CREATE TABLE kupac (
    kupac_id VARCHAR(10) PRIMARY KEY,
    ime VARCHAR(30) NOT NULL,
    prezime VARCHAR(30) NOT NULL,
    email VARCHAR(35)
);
--DESCRIBE kupac;

CREATE TABLE aviokompanija (
    avio_naziv VARCHAR(25) PRIMARY KEY
);
--DESCRIBE aviokompanija;

CREATE TABLE avion (
    avion_id VARCHAR(10) PRIMARY KEY,
    tip VARCHAR(25) NOT NULL,
    ukupno_sjedala NUMBER(3) NOT NULL
);
--DESCRIBE avion;

CREATE TABLE kupovina (
    kupovina_id VARCHAR(10) PRIMARY KEY,
    nacin_placanja VARCHAR(10) NOT NULL,
    kupac_id VARCHAR(10) NOT NULL CONSTRAINT kupac_id REFERENCES kupac(kupac_id)
);
--DESCRIBE kupovina;

CREATE TABLE kupovina_samostalna (
    kupovina_id VARCHAR(10) NOT NULL CONSTRAINT kupovina_id_s REFERENCES kupovina(kupovina_id),
    PRIMARY KEY (kupovina_id)
);
--DESCRIBE kupovina_samostalna;

CREATE TABLE kupovina_agencija(
    kupovina_id VARCHAR(10) NOT NULL CONSTRAINT kupovina_id_a REFERENCES kupovina(kupovina_id),
    agencija_id NUMBER(10) NOT NULL CONSTRAINT agencija_id REFERENCES agencija(agencija_id),
    provizija FLOAT(5) NOT NULL,
    popust FLOAT(5),
    PRIMARY KEY (kupovina_id)
);
--DESCRIBE kupovina_agencija;

CREATE TABLE detalji_leta (
    let_id NUMBER(10) PRIMARY KEY,
    broj_leta VARCHAR(8) NOT NULL,
    polazak VARCHAR(5) NOT NULL,
    dolazak VARCHAR(5) NOT NULL,
    datum_polaska DATE NOT NULL,
    vrijeme_polaska VARCHAR(5) NOT NULL,
    datum_dolaska DATE NOT NULL,
    vrijeme_dolaska VARCHAR(5) NOT NULL,
    avio_naziv VARCHAR(25) NOT NULL CONSTRAINT avio_naziv_let REFERENCES aviokompanija(avio_naziv),
    avion_id VARCHAR(10) NOT NULL CONSTRAINT avion_id REFERENCES avion(avion_id)
);
--DESCRIBE detalji_leta;

CREATE TABLE karta (
    broj_karte VARCHAR(10) PRIMARY KEY,
    cijena_karte FLOAT(7) NOT NULL,
    klasa VARCHAR(20) NOT NULL,
    broj_sjedala VARCHAR(4) NOT NULL,
    cijena_prtljage FLOAT(7),
    tezina_prtljage INTEGER,
    kolicina_prtljage INTEGER,
    cijena_hrane FLOAT(5),
    cijena_osiguranja FLOAT(5),
    trajanje_osiguranja VARCHAR(30),
    cijena_lounge_salona FLOAT(5),
    putnik_id NUMBER(10) NOT NULL CONSTRAINT putnik_id REFERENCES putnik(putnik_id),
    kupovina_id VARCHAR(10) NOT NULL CONSTRAINT kupovina_id_karta REFERENCES kupovina(kupovina_id),
    let_id NUMBER(10) NOT NULL CONSTRAINT let_id REFERENCES detalji_leta(let_id)
);
--DESCRIBE karta; 

CREATE TABLE milje (
    frequent_flyer_nr NUMBER(10) NOT NULL,
    milje_po_letu INTEGER NOT NULL,
    kupac_id VARCHAR(10) NOT NULL CONSTRAINT kupac_id_milje REFERENCES kupac(kupac_id),
    kupovina_id VARCHAR(10) NOT NULL CONSTRAINT kupovina_id_milje REFERENCES kupovina(kupovina_id),
    PRIMARY KEY(kupovina_id)
);
--DESCRIBE milje;