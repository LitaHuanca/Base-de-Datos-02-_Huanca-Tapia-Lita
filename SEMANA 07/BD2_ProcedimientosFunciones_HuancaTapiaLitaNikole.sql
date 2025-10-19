-- Creación de tablespace y temporary tablespace --

CREATE TABLESPACE bd07
DATAFILE 'C:\APP\USUARIO\PRODUCT\21C\ORADATA\XE\bd07.dbf' SIZE 50M
AUTOEXTEND ON NEXT 5M MAXSIZE 100M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT MANUAL
LOGGING;

CREATE TEMPORARY TABLESPACE bd07_temp
TEMPFILE 'C:\APP\USUARIO\PRODUCT\21C\ORADATA\XE\bd07_temp.dbf' SIZE 20M
EXTENT MANAGEMENT LOCAL
UNIFORM SIZE 2M;

-- Creación de tablas
CREATE TABLE suppliers(
    s# CHAR(2) CONSTRAINT pk_suppliers PRIMARY KEY,
    sname VARCHAR2(30) NOT NULL,
    status NUMBER(3),
    city VARCHAR2(30)
) tablespace bd07;

CREATE TABLE parts(
    p# CHAR(2) CONSTRAINT pk_parts PRIMARY KEY,
    pname VARCHAR2(30) NOT NULL,
    color VARCHAR2(20),
    weight NUMBER(5,2),
    city VARCHAR2(30)
)tablespace bd07;

CREATE TABLE jobs(
    j# CHAR(2) CONSTRAINT j_parts PRIMARY KEY,
    jname VARCHAR2(30) NOT NULL,
    city VARCHAR2(30)
) tablespace bd07;

CREATE TABLE sp(
    s# CHAR(2) NOT NULL,
    p# CHAR(2) NOT NULL,
    qty NUMBER(4),
    CONSTRAINT pk_sp 
        PRIMARY KEY (s#,p#),
    CONSTRAINT fk_sp_s
        FOREIGN KEY (s#) REFERENCES suppliers(s#),
    CONSTRAINT fk_sp_p
        FOREIGN KEY (p#) REFERENCES parts(p#)
) tablespace bd07;

CREATE TABLE spj(
    s# CHAR(2) NOT NULL,
    p# CHAR(2) NOT NULL,
    j# CHAR(2) NOT NULL,
    qty NUMBER(4),
    CONSTRAINT pk_spj 
        PRIMARY KEY (s#,p#,j#),
    CONSTRAINT fk_spj_s
        FOREIGN KEY (s#) REFERENCES suppliers(s#),
    CONSTRAINT fk_spj_p
        FOREIGN KEY (p#) REFERENCES parts(p#),
    CONSTRAINT fk_spj_j
        FOREIGN KEY (j#) REFERENCES jobs(j#)   
) tablespace bd07;

-- Inserción de registros en las tablas
INSERT INTO suppliers VALUES ('S1', 'Smith', 20, 'London');
INSERT INTO suppliers VALUES ('S2', 'Jones', 10, 'Paris');
INSERT INTO suppliers VALUES ('S3', 'Blake', 30, 'Paris');
INSERT INTO suppliers VALUES ('S4', 'Clark', 20, 'London');
INSERT INTO suppliers VALUES ('S5', 'Adams', 30, 'Athens');

INSERT INTO parts VALUES ('P1', 'Nut', 'Red', 12, 'London');
INSERT INTO parts VALUES ('P2', 'Bolt', 'Green', 17, 'Paris');
INSERT INTO parts VALUES ('P3', 'Screw', 'Blue', 17, 'Rome');
INSERT INTO parts VALUES ('P4', 'Screw', 'Red', 14, 'London');
INSERT INTO parts VALUES ('P5', 'Cam', 'Blue', 12, 'Paris');
INSERT INTO parts VALUES ('P6', 'Cog', 'Red', 19, 'London');

INSERT INTO jobs VALUES ('J1', 'Sorter', 'Paris');
INSERT INTO jobs VALUES ('J2', 'Mixer', 'Rome');
INSERT INTO jobs VALUES ('J3', 'Mixer', 'Athens');
INSERT INTO jobs VALUES ('J4', 'Assembler', 'Athens');
INSERT INTO jobs VALUES ('J5', 'Tester', 'London');
INSERT INTO jobs VALUES ('J6', 'Tester', 'Paris');
INSERT INTO jobs VALUES ('J7', 'Assembler', 'Rome');

INSERT INTO sp VALUES ('S1', 'P1', 300);
INSERT INTO sp VALUES ('S1', 'P2', 200);
INSERT INTO sp VALUES ('S1', 'P3', 400);
INSERT INTO sp VALUES ('S1', 'P4', 200);
INSERT INTO sp VALUES ('S1', 'P5', 100);
INSERT INTO sp VALUES ('S1', 'P6', 100);
INSERT INTO sp VALUES ('S2', 'P1', 300);
INSERT INTO sp VALUES ('S2', 'P2', 400);
INSERT INTO sp VALUES ('S3', 'P2', 200);
INSERT INTO sp VALUES ('S4', 'P2', 200);
INSERT INTO sp VALUES ('S4', 'P4', 300);
INSERT INTO sp VALUES ('S4', 'P5', 400);
INSERT INTO sp VALUES ('S5', 'P5', 500);
INSERT INTO sp VALUES ('S5', 'P6', 100);

INSERT INTO spj VALUES ('S1', 'P1', 'J1', 200);
INSERT INTO spj VALUES ('S1', 'P1', 'J4', 700);
INSERT INTO spj VALUES ('S2', 'P3', 'J1', 400);
INSERT INTO spj VALUES ('S2', 'P3', 'J2', 200);
INSERT INTO spj VALUES ('S2', 'P3', 'J3', 200);
INSERT INTO spj VALUES ('S2', 'P3', 'J4', 500);
INSERT INTO spj VALUES ('S2', 'P3', 'J5', 600);
INSERT INTO spj VALUES ('S2', 'P3', 'J6', 400);
INSERT INTO spj VALUES ('S2', 'P3', 'J7', 800);
INSERT INTO spj VALUES ('S2', 'P5', 'J2', 100);
INSERT INTO spj VALUES ('S3', 'P1', 'J1', 300);
INSERT INTO spj VALUES ('S3', 'P1', 'J2', 400);
INSERT INTO spj VALUES ('S4', 'P6', 'J3', 200);
INSERT INTO spj VALUES ('S4', 'P6', 'J7', 300);
INSERT INTO spj VALUES ('S5', 'P2', 'J2', 200);
INSERT INTO spj VALUES ('S5', 'P2', 'J4', 100);
INSERT INTO spj VALUES ('S5', 'P5', 'J5', 500);

----------------- EJERCICIOS -----------------
---- Procedimientos y funciones --------------

--------------------------------------------------------------------------------
-- 1)Obtenga el color y ciudad para las partes que no son de París, con un peso mayor
-- de diez.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionColorCiudad 
IS
    CURSOR c_obtencion IS
        SELECT color, city, weight
        FROM parts
        WHERE city <> 'Paris' AND weight > 10
        ORDER BY city, color;
BEGIN
    FOR r in c_obtencion LOOP
    dbms_output.put_line('Color: ' || r.color || '   Ciudad: ' || r.city || '   Peso: ' || r.weight);
    END LOOP;
END obtencionColorCiudad;

EXEC ObtencionColorCiudad;
--------------------------------------------------------------------------------
-- 2) Para todas las partes, obtenga el número de parte y el peso de dichas partes en
-- gramos.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionPartePeso IS
    CURSOR c_ObtencionPartes IS
        SELECT p#, ROUND(weight*453.59,2) AS pesoGramos
        FROM parts;
BEGIN
    FOR r in c_ObtencionPartes LOOP
        dbms_output.put_line('N° Parte: ' || r.p# || '  Peso: ' || TO_CHAR(r.pesoGramos) || ' gr.');
    END LOOP;
END ObtencionPartePeso;
/      

EXEC ObtencionPartePeso;
--------------------------------------------------------------------------------
-- 3) Obtenga el detalle completo de todos los proveedores.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE DetalleProveedores
IS 
    CURSOR c_proveedores IS
        SELECT s#, sname, status, city
        FROM suppliers;
    
BEGIN
    FOR r in c_proveedores LOOP
        dbms_output.put_line('N° de proveedor: ' || r.s# || '   Nombre: ' || r.sname || '   Calificación: ' || r.status || '   Ubicación: ' || r.city);
    END LOOP;
END DetalleProveedores;
/
EXEC DetalleProveedores;

--------------------------------------------------------------------------------
-- 4) Obtenga todas las combinaciones de proveedores y partes para aquellos provee-
-- dores y partes co-localizados.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionCombinaciones IS
    CURSOR c_combinaciones IS
        SELECT s.city, s.s#, s.sname, p.p#, p.pname
        FROM suppliers s
        INNER JOIN parts p
        ON s.city = p.city
        WHERE s.city IS NOT NULL AND p.city IS NOT NULL
        ORDER BY s.city, s.s#, p.p#;
BEGIN
    FOR r in c_combinaciones LOOP
    dbms_output.put_line('Ciudad: ' || r.city ||'  N° de proveedor: ' || r.s# || '  Nombre: ' || r.sname || '  N° de parte: ' || r.p# || '  Nombre: ' ||  r.pname);
    END LOOP;
END ObtencionCombinaciones;
/
EXEC ObtencionCombinaciones;
DROP PROCEDURE ObtencionCombinaciones;
--------------------------------------------------------------------------------
-- 5) Obtenga todos los pares de nombres de ciudades de tal forma que el proveedor
-- localizado en la primera ciudad del par abastece una parte almacenada en la se-
-- gunda ciudad del par.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionParesCiudades IS
    CURSOR c_ciudades IS
        SELECT DISTINCT s.city AS city1, p.city AS city2
        FROM suppliers s
        INNER JOIN sp
        ON s.s# = sp.s#
        INNER JOIN parts p
        ON p.p# = sp.p#
        ORDER BY s.city, p.city;
BEGIN
    FOR r in c_ciudades LOOP
    dbms_output.put_line('Ciudad del proveedor: ' || r.city1 ||'   Ciudad de la parte: ' || r.city2 );
    END LOOP;
END ObtencionParesCiudades;
/
EXEC ObtencionParesCiudades;
DROP PROCEDURE ObtencionParesCiudades;

--------------------------------------------------------------------------------
-- 6) Obtenga todos los pares de número de proveedor tales que los dos proveedores
-- del par estén co-localizados.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionProveedoresCo_localizados IS
    CURSOR c_proveedores_colo IS
        SELECT s1.city, s1.s# AS s1#, s1.sname AS s1sname, s2.s# AS s2#, s2.sname s2sname
        FROM suppliers s1
        INNER JOIN suppliers s2
        ON s1.city = s2.city
        AND s1.s# < s2.s#
        WHERE s1.city IS NOT NULL AND s2.city IS NOT NULL
        ORDER BY s1.city, s1.s#, s2.s#;
BEGIN
    FOR r in c_proveedores_colo LOOP
    dbms_output.put_line('Ciudad: ' || r.city ||'  N° de proveedor 1: ' || r.s1# || '  Nombre: ' || r.s1sname || '  N° de proveedor 2: ' || r.s2# || '  Nombre: ' ||  r.s2sname);
    END LOOP;
END ObtencionProveedoresCo_localizados;
/
EXEC ObtencionProveedoresCo_localizados;
DROP PROCEDURE ObtencionProveedoresCo_localizados;

--------------------------------------------------------------------------------
-- 7) Obtenga el número total de proveedores.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE NumeroProveedores IS
    v_numeroProv NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_numeroProv
    FROM suppliers;
    dbms_output.put_line('El número total de proveedores asciende a: ' || TO_CHAR(v_numeroProv));
END NumeroProveedores;
/
EXEC NumeroProveedores;
--------------------------------------------------------------------------------
-- 8) Obtenga la cantidad mínima y la cantidad máxima para la parte P2.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE CantidadMaxMin IS
    v_cantMax NUMBER;
    v_cantMin NUMBER;
BEGIN
    SELECT MIN(qty),MAX(qty)
    INTO v_cantMin, v_cantMax
    FROM sp
    WHERE p#='P2';
    dbms_output.put_line('Para P2 la cantidad máxima es ' || v_cantMax || ' y la mínima es ' || v_cantMin || '.');
END CantidadMaxMin;

EXEC CantidadMaxMin;
DROP PROCEDURE CantidadMaxMin;

--------------------------------------------------------------------------------
-- 9) Para cada parte abastecida, obtenga el número de parte y el total despachado.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionParteDespacho IS
    CURSOR c_ObtencionDespacho IS
        SELECT p#, SUM(qty)AS suma
        FROM sp
        GROUP BY p#;
BEGIN
    FOR r in c_ObtencionDespacho LOOP
        dbms_output.put_line('N° Parte: ' || r.p# || '  El total de despacho asciende a: ' || TO_CHAR(r.suma));
    END LOOP;
END ObtencionParteDespacho;
/    
EXEC ObtencionParteDespacho;
--------------------------------------------------------------------------------
-- 10) Obtenga el número de parte para todas las partes abastecidas por más de
-- un proveedor.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ObtencionParteAbastecidas IS
    CURSOR c_ObtencionAbastecimiento IS
        SELECT p#
        FROM sp
        GROUP BY p#
        HAVING COUNT(DISTINCT s#) >1
        ORDER BY p#;
BEGIN
    FOR r in c_ObtencionAbastecimiento LOOP
        dbms_output.put_line('N° Parte: ' || r.p#);
    END LOOP;
END ObtencionParteAbastecidas;
/
EXEC ObtencionParteAbastecidas;
--------------------------------------------------------------------------------
-- 11) Obtenga el nombre de proveedor para todos los proveedores que abastecen
-- la parte P2.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ObtencionProveedoresP2 IS
    CURSOR provP2 IS
        SELECT s.sname
        FROM suppliers s 
        INNER JOIN sp
        ON s.s# = sp.s#
        WHERE sp.p# = 'P2'
        ORDER BY s.sname;
    v_count NUMBER := 0;
BEGIN
    FOR r IN provP2 LOOP
    v_count := v_count + 1;
    dbms_output.put_line(r.sname || ' abastece la parte 2.');
    END LOOP;
    IF v_count = 0 THEN
    dbms_output.put_line('Ningún proveedor abastece la parte P2');
    END IF;
END ObtencionProveedoresP2;
/
EXEC ObtencionProveedoresP2;
DROP PROCEDURE ObtencionProveedoresP2;
--------------------------------------------------------------------------------
-- 12) Obtenga el nombre de proveedor de quienes abastecen por lo menos una
-- parte.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ObtencionProveedorAbas IS
    CURSOR c_ObtProveedor IS
        SELECT DISTINCT s.sname
        FROM suppliers s
        JOIN sp
        ON s.s# = sp.s#
        ORDER BY s.sname;
BEGIN
    FOR r in c_ObtProveedor LOOP
        dbms_output.put_line (r.sname || ' es un proveedor que abastece al menos una parte');
    END LOOP;
END ObtencionProveedorAbas;
/
EXEC ObtencionProveedorAbas;
DROP PROCEDURE ObtencionProveedorAbas;

--------------------------------------------------------------------------------
-- 13) Obtenga el número de proveedor para los proveedores con estado menor
-- que el máximo valor de estado en la tabla S.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ObtencionProveedoresMenor IS
        v_conteo NUMBER;
BEGIN
    SELECT COUNT(*)
        INTO v_conteo
        FROM suppliers
        WHERE status < (SELECT MAX(status)
                        FROM suppliers);
    dbms_output.put_line('Existen ' || TO_CHAR(v_conteo)|| ' proveedores con estado menor al máximo.');
END ObtencionProveedoresMenor;
/
EXEC ObtencionProveedoresMenor;


--------------------------------------------------------------------------------
-- 14) Obtenga el nombre de proveedor para los proveedores que abastecen la
-- parte P2 (aplicar EXISTS en su solución).
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionProveedorP2E IS
    CURSOR c_prov_exists IS
        SELECT s.sname
        FROM suppliers s
        WHERE EXISTS (
                SELECT 1
                FROM sp
                WHERE sp.s# = s.s#
                        AND sp.p# = 'P2')
        ORDER BY s.sname;
    v_count NUMBER := 0;
BEGIN
    FOR r IN c_prov_exists LOOP
    v_count := v_count + 1;
    dbms_output.put_line(r.sname || ' abastece la parte P2.');
    END LOOP;
    IF v_count = 0 THEN
        dbms_output.put_line('Ningún proveedor abastece la parte P2.');
    END IF;
END ObtencionProveedorP2E;
/
EXEC ObtencionProveedorP2E;
DROP PROCEDURE ObtencionProveedorP2E;
--------------------------------------------------------------------------------
-- 15) Obtenga el nombre de proveedor para los proveedores que no abastecen la
-- parte P2.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ObtencionNoProveedorP2
IS
    CURSOR c_prov_noexists IS
    SELECT s.sname
        FROM suppliers s
        WHERE NOT EXISTS (
                SELECT 1
                FROM sp
                WHERE sp.s# = s.s#
                        AND sp.p# = 'P2')
        ORDER BY s.sname;
    v_count NUMBER := 0;
BEGIN
    FOR r IN c_prov_noexists LOOP
    v_count := v_count + 1;
    dbms_output.put_line(r.sname || ' no abastece la parte P2');
    END LOOP;
    IF v_count = 0 THEN
        dbms_output.put_line('Todos los proveedores abastecen la parte P2.');
    END IF;
END ObtencionNoProveedorP2;
/
EXEC ObtencionNoProveedorP2;
--------------------------------------------------------------------------------
-- 16)Obtenga el nombre de proveedor para los proveedores que abastecen todas
-- las partes.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE ObtencionProveedorTodos
IS
    CURSOR c_prov_todos IS
    SELECT s.sname
        FROM suppliers s
        WHERE NOT EXISTS (
                SELECT 1
                FROM parts p
                WHERE NOT EXISTS(
                    SELECT 1
                    FROM sp
                    WHERE sp.s# = s.s# AND sp.p# = p.p#
                )
        )
        ORDER BY s.sname;
    v_count NUMBER := 0;
BEGIN
    FOR r IN c_prov_todos LOOP
    v_count := v_count + 1;
    dbms_output.put_line(r.sname || ' abastece a todas las partes');
    END LOOP;
    IF v_count = 0 THEN
        dbms_output.put_line('No existen proveedores que abastescan a todas las partes');
    END IF;
END ObtencionProveedorTodos;
/
EXEC ObtencionProveedorTodos;

--------------------------------------------------------------------------------
-- 17) Obtenga el número de parte para todas las partes que pesan más de 16 libras
-- ó son abastecidas por el proveedor S2, ó cumplen con ambos criterios.
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ObtencionNumProveedorPart IS
    CURSOR c_num_prov_part IS
        SELECT p.p#
        FROM parts p
        WHERE EXISTS (
                SELECT 1
                FROM sp
                WHERE sp.p# = p.p#
                        AND sp.s# = 'S2')
            OR p.weight > 16
        ORDER BY p.p#;
    v_count NUMBER := 0;
BEGIN
    FOR r IN c_num_prov_part LOOP
    v_count := v_count + 1;
    dbms_output.put_line('La parte ' ||TO_CHAR(r.p#) || ' al menos cumple con una de las condiciones');
    END LOOP;
    IF v_count = 0 THEN
        dbms_output.put_line('Ninguna parte pesa más de 16 libras ni es abastecida por el proveedor S2');
    END IF;
END ObtencionNumProveedorPart;
/
EXEC ObtencionNumProveedorPart;
DROP PROCEDURE ObtencionNumProveedorPart;