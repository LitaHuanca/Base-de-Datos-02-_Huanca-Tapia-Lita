---- RESOLUCIÓN LABORATORIO 10: Transacciones Relacionales ----

-- Creamos una tabla temporal para poder trabajar con ella
CREATE TABLE employees_temp AS SELECT * FROM employees;
SELECT * FROM employees_temp;

--------------------------------------------------------------------------------------------------------------------------

-- EJERCICIO 01 - CONTROL BÁSICO DE TRANSACCIONES

SET SERVEROUTPUT ON;
BEGIN
    UPDATE employees_temp
    SET salary = salary * 1.1
    WHERE department_id = 90;
    
    SAVEPOINT punto1;
    
    UPDATE employees_temp
    SET salary = salary * 1.05
    WHERE department_id = 60;
    
    ROLLBACK to punto1;
    COMMIT;
END;
/

-- Resolución de las preguntas

--- PREGUNTA 01: ¿Qué departamento mantuvo los cambios? ---
-- El departmento que mantuvo los cambios fue el 90, ya que el ROLLBACK TO revirtió lo 
-- hecho después de SAVEPOINT.

--- PREGUNTA 02: ¿Qué efecto tuvo el ROLLBACK parcial? ---
-- El ROLLBACK TO deshizo el incremento de 5% en el salario de los empleados del departamento 60, pero
-- dejó intacto el aumento que se realizó previamente a los empleados del departamento 90.

--- PREGUNTA 03: ¿Qué ocurriría si se ejecutara ROLLBACK sin especificar SAVEPOINT? ---
-- Al no especificarlo, al aplicar ROLLBACK se desharía toda la transacción pendiente, incluyendo el aumento de 10% en el salario
-- de los empleados del departamento 90.

--------------------------------------------------------------------------------------------------------------------------

-- EJERCICIO 02 - BLOQUEO ENTRE SESIONES

-- Primera sesión
    UPDATE employees_temp
    SET salary = salary + 500
    WHERE employee_id = 103;
    
-- Segunda sesión
    UPDATE employees_temp
    SET salary = salary + 100
    WHERE employee_id = 103;

-- Se vuelve a la sesión 1
    ROLLBACK;
-- En la segunda sesión
-- UPDATE se ejecuta
-- COMMIT;

-- Resolución de las preguntas

--- PREGUNTA 01: ¿Por qué la segunda sesión quedó bloqueada? ---
-- Porque esta segunda sesión intenta modificar la misma fila que la sesión 1 que la modifica antes pero dicha modificación
-- no se termina de confirmar, hasta que no se confirme o deshace, la otra sesión queda bloqueada. 

--- PREGUNTA 02: ¿Qué comando libera los bloqueos? ---
-- Los comandos que liberan los bloqueos son aplicados a la primera sesión: COMMIT y ROLLBACK

--- PREGUNTA 03: ¿Qué vistas del diccionario permiten verificar sesiones bloqueadas? ---
-- V$LOCK y V$SESSION para ver esperas y dueños de bloqueos.
-- V$LOCKED_OBJECT + DBA_OBJECTS para objetos bloqueados.

--------------------------------------------------------------------------------------------------------------------------

-- EJERCICIO 03 - TRANSACCIÓN CONTROLADA CON BLOQUE PL/SQL

DECLARE
    v_emp_id employees.employee_id%TYPE := 104;
    v_new_dept employees.department_id%TYPE := 110;
    v_old_dept employees.department_id%TYPE;
    v_job_id employees.job_id%TYPE;
    v_hire_date employees.hire_date%TYPE;
    v_conteo NUMBER;
BEGIN
    SELECT COUNT(*) 
    INTO v_conteo 
    FROM departments
    WHERE department_id = v_new_dept;
    IF v_conteo = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Departamento destino no existe');
    END IF;
    
    SELECT department_id, job_id, hire_date
    INTO v_old_dept, v_job_id, v_hire_date
    FROM employees
    WHERE employee_id = v_emp_id
    FOR UPDATE;
    
    UPDATE employees
    SET department_id = v_new_dept
    WHERE employee_id = v_emp_id;
    
    INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
    VALUES (v_emp_id, v_hire_date, SYSDATE, v_job_id, v_old_dept);
    
    COMMIT;
    
    dbms_output.put_line('Transferencia completada con exito');
    dbms_output.put_line('Empleado: ' || v_emp_id || ' transferido del departamento '  || v_old_dept || ' al ' || v_new_dept);
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            dbms_output.put_line('Error: El empleado con ID '||v_emp_id||' no existe.');
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('Error: '||SQLERRM);
    
END;

-- Resolución de las preguntas

--- PREGUNTA 01: ¿Por qué se debe garantizar la atomicidad entre las dos operaciones? ---
-- Porque ambas, tanto actualizar la tabla employees como insertar un nuevo registro en la tabla job_history,
-- representan uno solo, si se cambia el departamento de un empleado ello necesita un nuevo registro en su historial:
-- o se registra ambos o ninguno.

--- PREGUNTA 02: ¿Qué pasaría si se produce un error antes del COMMIT? ---
-- Para esos casos se trabajó con el EXCEPTION y ROLLBACK que ante cualquier error que pueda darse
-- deshará los cambios.

--- PREGUNTA 03: ¿Cómo se asegura la integridad entre EMPLOYEES y JOB_HISTORY? ---
-- Se asegura con las transacciones atómicas, claves foráneas y validaciones previas.

--------------------------------------------------------------------------------------------------------------------------

-- EJERCICIO 04 - SAVEPOINT Y REVERSIÓN PARCIAL

BEGIN
    UPDATE employees_temp
    SET salary = salary * 1.08
    WHERE department_id = 100;
    
    SAVEPOINT A;
    
    UPDATE employees_temp
    SET salary = salary * 1.05
    WHERE department_id = 80;
    
    SAVEPOINT B;
    
    DELETE FROM employees_temp
    WHERE department_id = 50;
    
    ROLLBACK TO  SAVEPOINT B;
    
    COMMIT;
    
END;

-- Resolución de las preguntas

--- PREGUNTA 01: ¿Qué cambios quedan persistentes? ---
-- Quedan persistentes el aumento de salario a los empleados del departamento 100 (+8%)
-- y el departamento 80 (+5%).

--- PREGUNTA 02: ¿Qué sucede con las filas eliminadas? ---
-- Las filas eliminadas correspondientes a los empleados del departamento 50 se recuperan debido al
-- ROLLBACK TO B.

--- PREGUNTA 03: ¿Cómo puedes verificar los cambios antes y después del COMMIT? ---
-- Se puede verificar con selects antes y después. Al ejecutar los selects se podrá detectar los cambios que ocurrieron
-- cuáles se ejecutaron y cuáles no.