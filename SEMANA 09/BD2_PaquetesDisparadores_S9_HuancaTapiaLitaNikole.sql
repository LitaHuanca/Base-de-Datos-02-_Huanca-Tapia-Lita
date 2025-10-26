
SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE pkg_empleado IS

  ------------------------- Crud básico de empleados -------------------------
  PROCEDURE crear_employee(
    p_employee_id   IN employees.employee_id%TYPE,
    p_first_name    IN employees.first_name%TYPE,
    p_last_name     IN employees.last_name%TYPE,
    p_email         IN employees.email%TYPE,
    p_phone_number  IN employees.phone_number%TYPE,
    p_hire_date     IN employees.hire_date%TYPE,
    p_job_id        IN employees.job_id%TYPE,
    p_salary        IN employees.salary%TYPE,
    p_commission_pct IN employees.commission_pct%TYPE DEFAULT NULL,
    p_manager_id    IN employees.manager_id%TYPE    DEFAULT NULL,
    p_department_id IN employees.department_id%TYPE DEFAULT NULL
  );

  PROCEDURE leer_employee(
    p_employee_id IN employees.employee_id%TYPE
  );

  PROCEDURE actualizar_employee(
    p_employee_id   IN employees.employee_id%TYPE,
    p_first_name    IN employees.first_name%TYPE,
    p_last_name     IN employees.last_name%TYPE,
    p_email         IN employees.email%TYPE,
    p_phone_number  IN employees.phone_number%TYPE,
    p_job_id        IN employees.job_id%TYPE,
    p_salary        IN employees.salary%TYPE,
    p_commission_pct IN employees.commission_pct%TYPE,
    p_manager_id    IN employees.manager_id%TYPE,
    p_department_id IN employees.department_id%TYPE
  );

  PROCEDURE eliminar_employee(
    p_employee_id IN employees.employee_id%TYPE
  );

  -- 3.1.1. Procedimiento que muestra los 4 empleados que han rotado más 
  PROCEDURE Top_Rotados;

  -- 3.1.2 Función que muestra un resumen estadístico de contrataciones por mes
  FUNCTION contrataciones_promedio RETURN NUMBER;

  -- 3.1.3 Procedimiento que muestra gastos en salario por región
  PROCEDURE gastos_por_region;

  -- 3.1.4 Función que muestra
  FUNCTION tiempo_servicio RETURN NUMBER;
END pkg_employee;
/


CREATE OR REPLACE PACKAGE BODY pkg_employee IS

  PROCEDURE raise_app_err(p_msg VARCHAR2, p_code NUMBER DEFAULT -20000) IS
  BEGIN
    RAISE_APPLICATION_ERROR(p_code, p_msg);
  END;

  FUNCTION years_between(d1 DATE, d2 DATE) RETURN NUMBER IS
  BEGIN
    RETURN FLOOR(MONTHS_BETWEEN(d2, d1) / 12);
  END;

  -- Desarrollo del CRUD de empleados
  PROCEDURE crear_employee(
    p_employee_id   IN employees.employee_id%TYPE,
    p_first_name    IN employees.first_name%TYPE,
    p_last_name     IN employees.last_name%TYPE,
    p_email         IN employees.email%TYPE,
    p_phone_number  IN employees.phone_number%TYPE,
    p_hire_date     IN employees.hire_date%TYPE,
    p_job_id        IN employees.job_id%TYPE,
    p_salary        IN employees.salary%TYPE,
    p_commission_pct IN employees.commission_pct%TYPE,
    p_manager_id    IN employees.manager_id%TYPE,
    p_department_id IN employees.department_id%TYPE
  ) IS
  BEGIN
    INSERT INTO employees(
      employee_id, first_name, last_name, email, phone_number,
      hire_date, job_id, salary, commission_pct, manager_id, department_id
    ) VALUES (
      p_employee_id, p_first_name, p_last_name, p_email, p_phone_number,
      p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id
    );

    dbms_output.put_line('Empleado creado: '|| p_employee_id||' - '|| p_last_name||' '|| p_first_name);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_app_err('employee_id duplicado: '||p_employee_id, -20001);
    WHEN OTHERS THEN
      raise_app_err('Error create_employee: '||SQLERRM, -20002);
  END crear_employee;

  PROCEDURE leer_employee(
    p_employee_id IN employees.employee_id%TYPE
  ) IS
    r employees%ROWTYPE;
    v_job_title jobs.job_title%TYPE;
  BEGIN
    SELECT e.*, j.job_title
    INTO r, v_job_title
    FROM employees e
    JOIN jobs j ON j.job_id = e.job_id
    WHERE e.employee_id = p_employee_id;

    dbms_output.put_line('ID: ' || r.employee_id || '  Nombre: ' || r.last_name || ', ' || r.first_name);
    dbms_output.put_line('Trabajo: ' || r.job_id || ' - ' || v_job_title || '  Salary: ' || r.salary);
    dbms_output.put_line('Fecha de contratacion: ' || TO_CHAR(r.hire_date, 'YYYY-MM-DD'));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_app_err('Empleado no existe: '||p_employee_id, -20003);
    WHEN OTHERS THEN
      raise_app_err('Error read_employee: '||SQLERRM, -20004);
  END leer_employee;

  PROCEDURE actualizar_employee(
    p_employee_id   IN employees.employee_id%TYPE,
    p_first_name    IN employees.first_name%TYPE,
    p_last_name     IN employees.last_name%TYPE,
    p_email         IN employees.email%TYPE,
    p_phone_number  IN employees.phone_number%TYPE,
    p_job_id        IN employees.job_id%TYPE,
    p_salary        IN employees.salary%TYPE,
    p_commission_pct IN employees.commission_pct%TYPE,
    p_manager_id    IN employees.manager_id%TYPE,
    p_department_id IN employees.department_id%TYPE
  ) IS
    v_rows NUMBER;
  BEGIN
    UPDATE employees
       SET first_name    = p_first_name,
           last_name     = p_last_name,
           email         = p_email,
           phone_number  = p_phone_number,
           job_id        = p_job_id,
           salary        = p_salary,
           commission_pct= p_commission_pct,
           manager_id    = p_manager_id,
           department_id = p_department_id
     WHERE employee_id   = p_employee_id;

    v_rows := SQL%ROWCOUNT;

    IF v_rows = 0 THEN
      raise_app_err('Empleado no existe: '||p_employee_id, -20005);
    ELSE
      dbms_output.put ('Empleado actualizado: ' || p_employee_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_app_err('Error update_employee: '||SQLERRM, -20006);
  END actualizar_employee;

  PROCEDURE eliminar_employee(
    p_employee_id IN employees.employee_id%TYPE
  ) IS
    v_rows NUMBER;
  BEGIN
    DELETE FROM employees WHERE employee_id = p_employee_id;
    v_rows := SQL%ROWCOUNT;

    IF v_rows = 0 THEN
      raise_app_err('Empleado no existe: '||p_employee_id, -20007);
    ELSE
      dbms_output.put_line ('Empleado eliminado: '||p_employee_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_app_err('Error delete_employee: '||SQLERRM, -20008);
  END eliminar_employee;

--------------------------------------------------------------------------------------------------------------------
--- 3.1.1
    PROCEDURE Top_Rotados IS 
        CURSOR c_top_rotados IS 
            SELECT e.employee_id, e.last_name, e.first_name, e.job_id, j.job_title, COUNT(jh.employee_id)AS Cambios_puesto 
            FROM employees e 
            JOIN jobs j 
            ON e.job_id = j.job_id 
            LEFT JOIN job_history jh 
            ON e.employee_id = jh.employee_id 
            GROUP BY e.employee_id, e.last_name, e.first_name, e.job_id, j.job_title 
            ORDER BY count(jh.employee_id) DESC 
            FETCH FIRST 4 ROWS ONLY; 
    BEGIN 
        FOR r in c_top_rotados LOOP 
        dbms_output.put_line('ID del empleado: ' || r.employee_id || ' Nombre: ' || r.last_name || ' ' || 
            r.first_name || ' Puesto actual: ' || r.job_id || ': ' || r.job_title || ' Numero de rotaciones: ' || r.Cambios_puesto); 
        END LOOP; 
    END Top_Rotados;

--- 3.1.2

    FUNCTION contrataciones_promedio RETURN NUMBER IS 
        CURSOR c_contrataciones IS 
            SELECT RTRIM(TO_CHAR(mes_anio, 'Month', 'NLS_DATE_LANGUAGE=SPANISH')) AS mes, 
                    EXTRACT(MONTH FROM mes_anio) AS mes_num, ROUND(AVG(cnt_mes_anio), 2) AS promedio 
            FROM 
                (SELECT TRUNC(hire_date, 'MM') AS mes_anio, COUNT(*) AS cnt_mes_anio 
                 FROM employees GROUP BY TRUNC(hire_date, 'MM') ) 
            GROUP BY RTRIM(TO_CHAR(mes_anio, 'Month', 'NLS_DATE_LANGUAGE=SPANISH')), EXTRACT(MONTH FROM mes_anio) 
            ORDER BY mes_num; 
        v_contar_meses NUMBER := 0; 
    BEGIN 
        FOR s in c_contrataciones LOOP 
            v_contar_meses := v_contar_meses + 1; 
            dbms_output.put_line('Mes: '|| s.mes || ' Promedio de contrataciones: ' || s.promedio); 
        END LOOP;
        RETURN v_contar_meses;
    END contrataciones_promedio;

--- 3.1.3
    PROCEDURE gastos_por_region IS 
        CURSOR c_gastos_por_region IS 
            SELECT r.region_name, NVL(SUM(e.salary),0) AS gasto_salario, 
                    COUNT(e.employee_id) AS cantidad_empleados , NVL(TO_CHAR(MIN(e.hire_date), 'YYYY-MM-DD'), 'Sin empleados') AS empleado_antiguo 
            FROM regions r 
            LEFT JOIN countries c 
            ON r.region_id = c.region_id 
            LEFT JOIN locations l 
            ON c.country_id = l.country_id 
            LEFT JOIN departments d 
            ON l.location_id = d.location_id 
            LEFT JOIN employees e 
            ON d.department_id = e.department_id 
            GROUP BY r.region_id, r.region_name; 
    BEGIN 
        FOR r in c_gastos_por_region LOOP 
            dbms_output.put_line(' Region: ' || r.region_name || ' Gasto total en salario: S/. ' || r.gasto_salario || 
                        ' Cantidad de empleados: ' || r.cantidad_empleados || ' Empleado más antiguo: ' || r.empleado_antiguo); 
        END LOOP; 
    END gastos_por_region;

--- 3.1.4

    FUNCTION tiempo_servicio
    RETURN NUMBER
    IS
      CURSOR c_emp IS
        SELECT employee_id, first_name, last_name, hire_date
        FROM employees;
      v_total_meses NUMBER := 0;
      v_meses_vac NUMBER;
      v_anios_serv NUMBER;
    BEGIN
      FOR r IN c_emp LOOP
        v_anios_serv := MONTHS_BETWEEN(SYSDATE, r.hire_date) / 12;
        v_meses_vac  := TRUNC(v_anios_serv);
        v_total_meses := v_total_meses + v_meses_vac;
        dbms_output.put_line('Empleado: '||r.employee_id||' - '||r.last_name|| ' '|| r.first_name);
        dbms_output.put_line('Años de servicio: '|| ROUND(v_anios_serv,2));
        dbms_output.put_line('Meses de vacaciones: '|| v_meses_vac);
      END LOOP;
      RETURN v_total_meses;
    END tiempo_servicio;
END pkg_employee;


-- Creación de tablas horario, empleado_horario, asistencia_empleado 
CREATE TABLE horario (
  dia_semana VARCHAR2(10) NOT NULL,
  turno VARCHAR2(10) NOT NULL,
  hora_inicio DATE NOT NULL,
  hora_termino DATE NOT NULL,
  CONSTRAINT pk_horario 
    PRIMARY KEY (dia_semana, turno),
  CONSTRAINT chk_horario_dia 
    CHECK (dia_semana IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO')),
  CONSTRAINT chk_horario_turno 
    CHECK (turno IN ('MANANA','TARDE','NOCHE')),
  CONSTRAINT chk_horario_horas 
    CHECK (hora_termino > hora_inicio)
);

CREATE TABLE empleado_horario (
  employee_id NUMBER NOT NULL,
  dia_semana VARCHAR2(10) NOT NULL,
  turno VARCHAR2(10) NOT NULL,
  CONSTRAINT pk_empleado_horario 
    PRIMARY KEY (employee_id, dia_semana, turno),
  CONSTRAINT fk_eh_emp 
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT fk_eh_hor 
    FOREIGN KEY (dia_semana, turno) REFERENCES horario(dia_semana, turno),
  CONSTRAINT chk_eh_dia 
    CHECK (dia_semana IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO')),
  CONSTRAINT chk_eh_turno 
    CHECK (turno IN ('MANANA','TARDE','NOCHE'))
);

CREATE TABLE asistencia_empleado (
  employee_id NUMBER NOT NULL,
  dia_semana VARCHAR2(10) NOT NULL,
  fecha_real DATE NOT NULL,
  hora_inicio_real DATE NOT NULL,
  hora_termino_real DATE NOT NULL,
  CONSTRAINT pk_asistencia_empleado 
    PRIMARY KEY (employee_id, fecha_real),
  CONSTRAINT fk_ae_emp 
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT chk_ae_dia 
    CHECK (dia_semana IN ('LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO','DOMINGO')),
  CONSTRAINT chk_ae_horas 
    CHECK (hora_termino_real >= hora_inicio_real)
);

-- Llenado de las tablas creadas con algunos registros

INSERT INTO horario VALUES ('LUNES', 'MANANA', TO_DATE('08:00','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO horario VALUES ('LUNES', 'TARDE',  TO_DATE('13:00','HH24:MI'), TO_DATE('17:00','HH24:MI'));
INSERT INTO horario VALUES ('MARTES', 'MANANA', TO_DATE('08:00','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO horario VALUES ('MARTES', 'TARDE',  TO_DATE('13:00','HH24:MI'), TO_DATE('17:00','HH24:MI'));
INSERT INTO horario VALUES ('MIERCOLES', 'MANANA', TO_DATE('08:00','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO horario VALUES ('MIERCOLES', 'TARDE',  TO_DATE('13:00','HH24:MI'), TO_DATE('17:00','HH24:MI'));
INSERT INTO horario VALUES ('JUEVES', 'MANANA', TO_DATE('08:00','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO horario VALUES ('JUEVES', 'TARDE',  TO_DATE('13:00','HH24:MI'), TO_DATE('17:00','HH24:MI'));
INSERT INTO horario VALUES ('VIERNES', 'MANANA', TO_DATE('08:00','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO horario VALUES ('VIERNES', 'TARDE',  TO_DATE('13:00','HH24:MI'), TO_DATE('17:00','HH24:MI'));

INSERT INTO empleado_horario VALUES (100, 'LUNES', 'MANANA');
INSERT INTO empleado_horario VALUES (101, 'LUNES', 'TARDE');
INSERT INTO empleado_horario VALUES (102, 'MARTES', 'MANANA');
INSERT INTO empleado_horario VALUES (103, 'MARTES', 'TARDE');
INSERT INTO empleado_horario VALUES (104, 'MIERCOLES', 'MANANA');
INSERT INTO empleado_horario VALUES (105, 'MIERCOLES', 'TARDE');
INSERT INTO empleado_horario VALUES (106, 'JUEVES', 'MANANA');
INSERT INTO empleado_horario VALUES (107, 'JUEVES', 'TARDE');
INSERT INTO empleado_horario VALUES (108, 'VIERNES','MANANA');
INSERT INTO empleado_horario VALUES (109, 'VIERNES', 'TARDE');

INSERT INTO asistencia_empleado VALUES (100, 'LUNES', DATE '2025-10-06', TO_DATE('08:02','HH24:MI'), TO_DATE('12:01','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (101, 'LUNES', DATE '2025-10-06', TO_DATE('13:00','HH24:MI'), TO_DATE('17:05','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (102, 'MARTES', DATE '2025-10-07', TO_DATE('08:00','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (103, 'MARTES', DATE '2025-10-07', TO_DATE('13:10','HH24:MI'), TO_DATE('17:00','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (104, 'MIERCOLES', DATE '2025-10-08', TO_DATE('08:05','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (105, 'MIERCOLES', DATE '2025-10-08', TO_DATE('13:00','HH24:MI'), TO_DATE('17:02','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (106, 'JUEVES', DATE '2025-10-09', TO_DATE('08:00','HH24:MI'), TO_DATE('12:03','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (107, 'JUEVES', DATE '2025-10-09', TO_DATE('13:00','HH24:MI'), TO_DATE('17:07','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (108, 'VIERNES', DATE '2025-10-10', TO_DATE('08:12','HH24:MI'), TO_DATE('12:00','HH24:MI'));
INSERT INTO asistencia_empleado VALUES (109, 'VIERNES', DATE '2025-10-10', TO_DATE('13:00','HH24:MI'), TO_DATE('17:01','HH24:MI'));

--- Creación de más funciones y procedimientos que involucran las nuevas tablas

-- 3.1.5 Funcion que recibe código de empleado, número de mes y número de año, se retorna número de horas laboradas durante ese mes y año
CREATE OR REPLACE FUNCTION horas_laboradas_mes (
    v_employee_id IN employees.employee_id%TYPE,
    v_num_mes IN NUMBER,
    v_num_anio IN NUMBER
)RETURN NUMBER
IS v_horas NUMBER := 0;
BEGIN
    SELECT NVL(SUM(((TRUNC(fecha_real)+(hora_termino_real -TRUNC(hora_termino_real)))
               -(TRUNC(fecha_real)+(hora_inicio_real-TRUNC(hora_inicio_real ))))*24),0)
    INTO v_horas
    FROM asistencia_empleado
    WHERE employee_id = v_employee_id
        AND EXTRACT (MONTH FROM fecha_real) = v_num_mes
        AND EXTRACT (YEAR FROM fecha_real) = v_num_anio;
    RETURN v_horas;
END horas_laboradas_mes;

-- 3.1.6 Funcion que recibe código del empleado, número de mes y año y devuelve la cantidad de horas que faltó al trabajo
CREATE OR REPLACE FUNCTION horas_faltantes_mes (
    p_employee_id IN employees.employee_id%TYPE,
    p_mes IN NUMBER,
    p_anio IN NUMBER
) RETURN NUMBER
IS
    v_ini_mes DATE;
    v_fin_mes DATE;
    v_prog NUMBER := 0;
    v_real NUMBER := 0;
BEGIN
    v_ini_mes := TRUNC(TO_DATE(p_anio||LPAD(p_mes,2,'0')||'01','YYYYMMDD'),'MM');
    v_fin_mes := ADD_MONTHS(v_ini_mes, 1);
    SELECT NVL(SUM( (h.hora_termino - h.hora_inicio) * 24 ), 0)
        INTO v_prog
    FROM (
      SELECT v_ini_mes + LEVEL - 1 AS fecha
      FROM dual
      CONNECT BY LEVEL <= (v_fin_mes - v_ini_mes)
    ) cal
    JOIN empleado_horario eh
      ON eh.employee_id = p_employee_id
     AND INITCAP(TRIM(TO_CHAR(cal.fecha, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH'))) = eh.dia_semana
    JOIN horario h
      ON h.dia_semana = eh.dia_semana
     AND h.turno = eh.turno;

  v_real := horas_laboradas_mes(p_employee_id, p_mes, p_anio);
  RETURN GREATEST(0, ROUND(v_prog - v_real, 2));
END horas_faltantes_mes;

-- 3.1.7 Procedimiento que recibe número del mes y número del año y devuleve el salario que le corresponde a cada empleado en función a sus horas trabajadas
CREATE OR REPLACE PROCEDURE sueldo_mensual (
  p_mes  IN NUMBER,
  p_anio IN NUMBER
) IS
  v_lab   NUMBER;  
  v_fal   NUMBER; 
  v_prog  NUMBER; 
  v_tar   NUMBER;
  v_pago  NUMBER;
BEGIN
  FOR r IN (
    SELECT employee_id, first_name, last_name, salary
    FROM employees
    ORDER BY last_name, first_name
    ) LOOP
    v_lab := NVL(horas_laboradas_mes(r.employee_id, p_mes, p_anio), 0);
    v_fal := NVL(horas_faltantes_mes(r.employee_id, p_mes, p_anio), 0);
    v_prog := v_lab + v_fal;

    IF v_prog > 0 THEN
      v_tar  := r.salary / v_prog;
      v_pago := v_tar * v_lab;
    ELSE
      v_tar  := 0;
      v_pago := 0;
    END IF;

    dbms_output.put_line('Empleado: ' || r.employee_id || ' - ' || r.last_name || ' ' || r.first_name);
    dbms_output.put_line('Cantidad de horas trabajadas: ' || TO_CHAR(ROUND(v_lab,2)));
    dbms_output.put_line('Horas faltantes: ' || TO_CHAR(ROUND(v_fal,2)));
    dbms_output.put_line('Sueldo mensual: S/. ' || TO_CHAR(ROUND(v_pago,2)));
  END LOOP;
END sueldo_mensual;

-- Creación de las tablas capacitación y empleadoCapacitación

CREATE TABLE capacitacion (
  cod_capacitacion     NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nombre_capacitacion  VARCHAR2(100) NOT NULL,
  horas_capacitacion   NUMBER(4)     CHECK (horas_capacitacion > 0),
  descripcion          VARCHAR2(300)
);

CREATE TABLE empleado_capacitacion (
  employee_id        NUMBER NOT NULL,
  cod_capacitacion   NUMBER NOT NULL,
  CONSTRAINT pk_emp_cap PRIMARY KEY (employee_id, cod_capacitacion),
  CONSTRAINT fk_emp_cap_emp FOREIGN KEY (employee_id)
      REFERENCES employees(employee_id),
  CONSTRAINT fk_emp_cap_cap FOREIGN KEY (cod_capacitacion)
      REFERENCES capacitacion(cod_capacitacion)
);

-- Inserción de registros en dichas tablas
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Gestión de Proyectos Ágiles', 24, 'Introducción a Scrum y metodologías ágiles para equipos de desarrollo.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Seguridad Informática', 30, 'Buenas prácticas de ciberseguridad, gestión de contraseñas y protección de datos.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Liderazgo y Trabajo en Equipo', 20, 'Fortalecimiento de habilidades blandas para la gestión de equipos.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Base de Datos Oracle', 40, 'Fundamentos de SQL, PL/SQL y administración básica en Oracle Database.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Excel Avanzado', 16, 'Uso de fórmulas, tablas dinámicas, macros y análisis de datos.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Comunicación Efectiva', 12, 'Desarrollo de habilidades de comunicación oral y escrita.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Gestión del Tiempo', 10, 'Técnicas para mejorar la productividad y priorización de tareas.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Machine Learning Básico', 25, 'Fundamentos de aprendizaje automático y uso de herramientas básicas.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Desarrollo Web con Java', 35, 'Conceptos de backend y frontend usando Java y frameworks modernos.');
INSERT INTO capacitacion (nombre_capacitacion, horas_capacitacion, descripcion)
VALUES ('Prevención de Riesgos Laborales', 8, 'Normas básicas de seguridad y prevención en el lugar de trabajo.');

INSERT INTO empleado_capacitacion VALUES (100, 1);
INSERT INTO empleado_capacitacion VALUES (101, 2);
INSERT INTO empleado_capacitacion VALUES (102, 3);
INSERT INTO empleado_capacitacion VALUES (103, 4);
INSERT INTO empleado_capacitacion VALUES (104, 5);
INSERT INTO empleado_capacitacion VALUES (105, 6);
INSERT INTO empleado_capacitacion VALUES (106, 7);
INSERT INTO empleado_capacitacion VALUES (107, 8);
INSERT INTO empleado_capacitacion VALUES (108, 9);
INSERT INTO empleado_capacitacion VALUES (109, 10);

-- 3.1.8 Funcion que retorna la cantidad de horas de capacitación de un empleado

CREATE OR REPLACE FUNCTION total_horas_capacitacion (
  p_employee_id IN employees.employee_id%TYPE
) RETURN NUMBER
IS
  v_total NUMBER := 0;
BEGIN
  SELECT NVL(SUM(c.horas_capacitacion), 0)
    INTO v_total
    FROM empleado_capacitacion ec
    JOIN capacitacion c
      ON c.cod_capacitacion = ec.cod_capacitacion
   WHERE ec.employee_id = p_employee_id;

  RETURN v_total;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END total_horas_capacitacion;

-- 3.1.9 Procedimiento que lista todas las capacitaciones desarrolladas

CREATE OR REPLACE PROCEDURE reporte_capacitaciones_empleados
IS
BEGIN
    dbms_output.put_line('----------------- CAPACITACIONES DESARROLLAS -----------------');
    FOR t IN (
        SELECT cod_capacitacion, nombre_capacitacion, horas_capacitacion
        FROM capacitacion
        ORDER BY cod_capacitacion
    ) LOOP
    dbms_output.put_line('Capacitacion: ' || t.cod_capacitacion || ' - ' || t.nombre_capacitacion);
    dbms_outuput.put_line('      Duracion:  ' || t.horas_capacitacion);
    END LOOP;

    FOR r IN (
        SELECT e.employee_id, e.last_name, e.first_name, NVL(SUM(c.horas_capacitacion), 0) AS total_horas
    FROM employees e
    LEFT JOIN empleado_capacitacion ec
    ON ec.employee_id = e.employee_id
    LEFT JOIN capacitacion c
    ON c.cod_capacitacion = ec.cod_capacitacion
    GROUP BY e.employee_id, e.last_name, e.first_name
    ORDER BY total_horas DESC, e.last_name, e.first_name
    ) LOOP
    dbms_output.put_line('Empleado: ' || r.employee_id || ' - ' || r.last_name || ' ' || r.first_name);
    dbms_output.put_line('Horas en capacitacion: ' || r.total_horas || ' h');
    END LOOP;
END reporte_capacitaciones_empleados;
/
------------------------------ TRIGGERS ------------------------------
-- 3.2 Trigger before insert o update en la asistencia de empleados
CREATE OR REPLACE TRIGGER trg_correcta_asistencia
BEFORE INSERT OR UPDATE OF dia_semana, fecha_real, hora_inicio_real, hora_termino_real
ON asistencia_empleado
FOR EACH ROW
DECLARE
  v_dia_calculado  VARCHAR2(20);
  v_hi_horario DATE;
  v_ht_horario DATE;
  
  FUNCTION hora_sola(p_date DATE) RETURN NUMBER IS
  BEGIN
    RETURN p_date - TRUNC(p_date);
  END;
BEGIN
  v_dia_calculado := INITCAP(TRIM(TO_CHAR(:NEW.fecha_real, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
  IF v_dia_calculado <> :NEW.dia_semana THEN
    raise_application_error(-20501, 'Día de la semana no coincide con fecha_real: ' || v_dia_calculado||' <> '||:NEW.dia_semana);
  END IF;

  SELECT h.hora_inicio, h.hora_termino
    INTO v_hi_horario, v_ht_horario
    FROM empleado_horario eh
    JOIN horario h
      ON h.dia_semana = eh.dia_semana
     AND h.turno = eh.turno
   WHERE eh.employee_id = :NEW.employee_id
     AND eh.dia_semana = :NEW.dia_semana;

  IF hora_sola(:NEW.hora_inicio_real) <> hora_sola(v_hi_horario) THEN
    raise_application_error(-20502, 'Hora de inicio real no corresponde al horario (' || TO_CHAR(v_hi_horario,'HH24:MI')||')');
  END IF;

  IF hora_sola(:NEW.hora_termino_real) <> hora_sola(v_ht_horario) THEN
    raise_application_error(-20503, 'Hora de término real no corresponde al horario ('|| TO_CHAR(v_ht_horario,'HH24:MI')||')');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(-20500, 'No existe asignación de turno en EMPLEADO_HORARIO para ese empleado y día.');
END trg_correcta_asistencia;
/

-- 3.3 Trigger beofre insert o update en la asignación de sueldos

CREATE OR REPLACE TRIGGER trg_sueldo_verificado
BEFORE INSERT OR UPDATE OF salary, job_id ON employees
FOR EACH ROW
DECLARE
  v_min jobs.min_salary%TYPE;
  v_max jobs.max_salary%TYPE;
BEGIN
  SELECT min_salary, max_salary
    INTO v_min, v_max
    FROM jobs
   WHERE job_id = :NEW.job_id;

  IF :NEW.salary < v_min OR :NEW.salary > v_max THEN
    raise_application_error(-20888, 'Monto salario '||:NEW.salary|| ' fuera de rango: ['||v_min||' - '||v_max||']');
  END IF;
END trg_sueldo_verificado;
/

-- 3.4 Trigger que restringe el acceso 30 mins + o -
CREATE OR REPLACE TRIGGER trg_horario_acceso
BEFORE INSERT OR UPDATE OF hora_inicio_real ON asistencia_empleado
FOR EACH ROW
DECLARE
  v_hi DATE;
  v_diferente_hora NUMBER;
  FUNCTION hora_sola(p_date DATE) RETURN NUMBER IS
  BEGIN
    RETURN p_date - TRUNC(p_date);
  END;
BEGIN
    SELECT h.hora_inicio
    INTO v_hi
    FROM empleado_horario eh
    JOIN horario h
    ON h.dia_semana = eh.dia_semana
    AND h.turno      = eh.turno
    WHERE eh.employee_id = :NEW.employee_id
    AND eh.dia_semana  = :NEW.dia_semana;

  v_diferente_hora :=
    ABS( ( (TRUNC(:NEW.fecha_real) + hora_sola(:NEW.hora_inicio_real))
         - (TRUNC(:NEW.fecha_real) + hora_sola(v_hi)) ) * 24 );

  IF v_diferente_hora > 0.5 THEN
    :NEW.hora_inicio_real  := TRUNC(:NEW.fecha_real) + hora_sola(v_hi);
    :NEW.hora_termino_real := :NEW.hora_inicio_real;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(-20600, 'No existe turno asignado para ese empleado/día.');
END trg_horario_acceso;
/