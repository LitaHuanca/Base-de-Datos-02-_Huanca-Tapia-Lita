---- RESOLUCIÓN SEMANA 05 ----

-- 1) Cree una consulta para mostrar el apellido y salario de los empleados que ganan más de $12,000.

SELECT last_name, salary
FROM employees
WHERE salary > 12000;

-- 2) Cree una consulta para mostrar el apellido de empleado y el número de 
-- departamento para el número de empleado 176.
SELECT last_name, department_id
FROM employees
WHERE employee_id = 176;

-- 3) Modifique 1.1. para que muestre el apellido y salario de todos los empleados cuyo
-- salario no está en el rango de $5,000 y $12,000.
SELECT last_name, salary
FROM employees
WHERE salary > 12000 OR salary < 5000;

-- 4) Muestre el apellido de empleado, job ID, y fecha de inicio de los empleados
-- contratados entre el 20 de febrero de 1998 y el 1 de Mayo de 1998. Ordene la
-- consulta en orden ascendente por fecha de inicio
SELECT e.last_name, e.job_id, jh.start_date
FROM employees e
INNER JOIN job_history jh
ON e.employee_id = jh.employee_id
WHERE e.hire_date BETWEEN DATE '1998-02-20' AND DATE '1998-05-01'
ORDER BY jh.start_date ASC;

SELECT e.last_name, e.job_id, jh.start_date
FROM employees
WHERE hire_date BETWEEN DATE '1998-02-20' AND DATE '1998-05-01'
ORDER BY hire_date ASC; 

-- 5) Muestre el apellido y número de departamento de todos los empleados en los
-- departamentos 20 y 50 en orden alfabético de apellido.
SELECT last_name, department_id
FROM employees
WHERE department_id IN (20,50)
ORDER BY last_name;

-- 6) Modifique 1.3. para que muestre el apellido y salario de los empleados que gana
-- entre $5,000 y $12,000, y están en los departamentos 20 o 50. Etiquete las
-- columnas Employee y Monthly Salary, respectivamente.
SELECT last_name AS Employee, salary AS "Monthly Salary"
FROM employees
WHERE salary BETWEEN 5000 AND 12000 AND department_id IN (20,50);

-- 7) Muestre el apellido y fecha de contratación de todos los empleados contratados
-- en 1994.
SELECT last_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 1994;

SELECT MAX(hire_date), MIN(hire_date) FROM employees;
SELECT * FROM employees;

SELECT last_name, hire_date
FROM employees
WHERE hire_date LIKE '%94';
-- 8) Muestre el apellido y título de puesto de todos los empleados que no tienen gerente.
SELECT e.last_name, j.job_title
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
WHERE e.manager_id IS NULL;

-- 9) Muestre los apellidos de todos los empleados donde la tercera letra del nombre
-- es una a.
SELECT last_name, first_name
FROM employees
WHERE first_name LIKE '__a%';

SELECT last_name
FROM employees
WHERE last_name LIKE '__a%';
-- 10) Muestre el apellido de todos los empleados quienes tienen a y e en su apellido.
SELECT last_name
FROM employees
WHERE last_name LIKE '%a%' and last_name LIKE '%e%';

-- 11) Muestre el apellido, puesto y salario de todos los empleados cuyo puesto es
-- representante de ventas (sales representative) o asistente de almacén (stock
-- clerk) y cuyo salario es diferente de $2,500, $3,500 o $7,000.
SELECT e.last_name, j.job_title, e.salary
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
WHERE j.job_title IN('Sales Representative','Stock Clerk')
AND salary NOT IN (2500,3500,7000);

SELECT * FROM jobs;

-- 12) Modifique 1.6. para que muestre el apellido, salario y comisión para todos los
-- empleados cuya comisión es 20%.
SELECT last_name AS Employee, salary AS "Monthly Salary", commission_pct AS Comisión
FROM employees
WHERE commission_pct = 0.2;

SELECT * FROM employees;

-------- FUNCIONES DE UNA FILA ---------
-- 2) Para cada empleado, muestre el número de ID, apellido, salario, y el salario
-- incrementado por 15% y expresado por un solo número. Etiquete la columna New
-- Salary.
SELECT employee_id,last_name,salary,ROUND(1.15*salary,-1) AS "New Salary"
FROM employees;

-- 3) Modifique la consulta en 2.2. para adicionar una columna que reste el salario
-- antiguo del nuevo salario. Etiquete la columna Increase.
SELECT employee_id,last_name,salary,newSalary, newSalary - salary AS Increase
FROM (SELECT  employee_id, last_name, salary, ROUND(salary*1.15,-1) AS newSalary
        FROM employees);

-- 4) Escriba una consulta que muestre los apellidos de los empleados con la primera
-- letra en mayúscula y las demás en minúscula, y la longitud de los nombres para
-- todos los nombres, para todos los empleados cuyo nombre inicie con J, A, o M.
-- De a cada columna una etiqueta apropiada. Ordene los resultados por apellido de
-- empleados.
SELECT INITCAP(first_name)Name , LENGTH(first_name) Length
FROM employees
WHERE first_name LIKE 'A%' OR
        first_name LIKE 'J%' OR
        first_name LIKE 'M%'
ORDER BY first_name;

SELECT INITCAP(last_name)Name , LENGTH(last_name) Length
FROM employees
WHERE last_name LIKE 'A%' OR
        last_name LIKE 'J%' OR
        last_name LIKE 'M%'
ORDER BY last_name;

-- 5)Para cada empleado, muestre el apellido de los empleados y calcule el número
-- de meses entre hoy y la fecha en que el empleado fue contratado. Etiquete la
--columna MONTHS_WORKED. Ordene sus resultados por número de meses
-- empleados. Redondee el número de meses al número entero más cercano.
SELECT last_name, ROUND(MONTHS_BETWEEN(SYSDATE,hire_date)) AS Meses
FROM employees
ORDER BY Meses ASC;


-- 6) Escriba una consulta que produzca lo siguiente para cada empleado: <apellido de
-- empleado> earns <salario> monthly but wants <3 veces el salario>. Etiquete la
-- columna Dream Salaries.
SELECT last_name || ' earns ' || salary || ' monthly but wants ' || salary*3 AS "Dream Salaries"
FROM employees;

SELECT last_name || ' earns ' || TO_CHAR(salary,'fm$99,999.00') || ' monthly but wants ' || TO_CHAR(salary*3,'fm$99,999.00') AS "Dream Salaries"
FROM employees;

-- 7) Cree una consulta para mostrar el apellido y salario de todos los empleados.
-- Formatee el salario a 15.
SELECT last_name, LPAD(salary,15,'$')
FROM employees;

-- 8) Muestre el apellido de cada empleado, fecha de contratación, y fecha de revisión
-- de salario, que es el primer Lunes después de seis meses de servicio. Etiquete la
-- columna REVIEW. Formatee las fechas para que aparezcan similares a “Monday,
-- the Thirty-First of July, 2000”.
SELECT last_name, hire_date,TO_CHAR(NEXT_DAY(ADD_MONTHS(hire_date,6),'LUNES'),'fmDay,"the" Ddspth "of" Month, YYYY') REVIEW 
FROM employees;

-- 9) Muestre el apellido, fecha de contratación, y día de la semana en la que el
-- empleado comenzó a trabajar. Etiquete la columna DAY. Ordene los resultados por el día
-- de la semana iniciado con Monday
SELECT last_name, hire_date, TO_CHAR(hire_date,'fmDAY') AS DAY
FROM employees
ORDER BY TO_CHAR(hire_date,'d');

-- 10) Cree una consulta que muestre los apellidos de los empleados e indique las
-- cantidades de sus salarios anuales con asteriscos. Cada asterisco significa miles
-- de dólares. Ordene los datos en orden descendente de salario. Etiquete la
-- columna EMPLOYEES_AND _THEIR_SALARIES.

SELECT last_name, TRUNC((salary*12)/1000,0) AS "EMPLOYESS_ AND_THEIR_SALARIES"
FROM employees
ORDER BY salary DESC;

-- 11) Usando la función DECODE, escriba una consulta que muestre el grado de cada
-- empleado en base al valor de la columna JOB_ID, como aparece en la siguiente
-- tabla:
SELECT job_id, DECODE(job_id,'AD_PRES','A',
                            'ST_MAN','B',
                            'IT_PROG','C',
                            'SA_REP', 'D',
                            'ST_CLERK','E',
                            0) GRADE
FROM employees;

-- 12) Cree una consulta que muestre los apellidos de los empleados y los montos de
-- comisión. Si un empleado no tiene comisión, coloque “No Commission”. Etiquete
-- la columna como COMM.
SELECT last_name, 
    CASE 
    WHEN commission_pct IS NULL THEN 'No commission'
                    ELSE TO_CHAR(commission_pct)
                END as COMM
FROM employees;

--- DATOS DE VARIAS TABLAS
-- 1) Escriba una sentencia para mostrar el apellido,número de departamento, y
--    nombre departamento para todos los empleados.
SELECT e.last_name, e.department_id, d.department_name
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id;

-- 2) Cree una lista única de todos los puestos que están en el departamento 30.
-- Incluya la ubicación del departamento 90.
SELECT distinct e.job_id
FROM employees e
INNER JOIN  departments d
ON e.department_id = d.department_id
WHERE d.department_id = 30;


-- 3) Escriba una consulta que muestre el apellido de empleado, nombre de
-- departamento, ID de ubicación, y ciudad de todos los empleados que tienen
-- comisión.
SELECT e.last_name, d.department_name, d.location_id, l.city
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id
INNER JOIN locations l
ON d.location_id = l.location_id
WHERE e.commission_pct IS NOT NULL;

-- 4) Muestre el apellido de empleado y el nombre de departamento de todos los
-- empleados que tienen una a (minúscula) en sus apellidos.
SELECT e.last_name, d.department_name
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id
WHERE e.last_name LIKE '%a%';

-- 5) Escriba una consulta para mostrar el nombre, puesto, número de departamento y
-- nombre de departamento de todos los empleados que trabajan en Toronto.
SELECT e.last_name, e.job_id, e.department_id, d.department_name
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id
INNER JOIN locations l
ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

-- 6) Muestre el apellido de empleado y número de empleado así como el apellido de
-- su gerente y número de gerente. Etiquete las columnas Employee, Emp#,
-- Manager, y Mgr#, respectivamente.
SELECT e.last_name AS Employee, e.employee_id AS Emp#, emp.last_name AS Manager2 , emp.employee_id AS Mgr#
FROM employees e
INNER JOIN employees emp
ON e.manager_id = emp.employee_id;

-- 7) Modifique 3.6. para mostrar todos los empleados incluyendo los que no tienen
-- gerente. Ordene los resultados por número de empleado.
SELECT e.last_name AS Employee, e.employee_id AS Emp#, emp.last_name AS Manager2 , emp.employee_id AS Mgr#
FROM employees e
LEFT JOIN employees emp
ON e.manager_id = emp.employee_id;

-- 8) Cree una consulta que muestre los apellidos de empleado, números de
-- departamento y todos los empleados que trabajan en el mismo departamento que
-- un empleado dado. De a cada columna una etiqueta apropiada (Department,
-- Employee, Colleague).
SELECT e.last_name AS Employee, e.department_id AS Department, c.last_name AS Colleague
FROM employees e
INNER JOIN employees c
ON e.department_id = c.department_id
WHERE e.employee_id <> c.employee_id
ORDER BY e.department_id, e.last_name, c.last_name;

-- 9)Cree una consulta que muestre el nombre y la fecha de contratación de cualquier
-- empleado contratado después del empleado Davies.
SELECT last_name, hire_date
FROM employees
WHERE hire_date > (SELECT MIN(hire_date)
                    FROM  employees
                    WHERE last_name = 'Davies')
ORDER BY hire_date;
                    

-- 10) Muestre los nombres y fecha de contratación de todos los empleados que fueron
-- contratados antes que sus gerentes, junto con los nombres de sus gerentes y la
-- fecha de contratación. Etiquete a las columnas Employee, Emp, Hired, Manager
-- y Mgr Hired respectivamente.
SELECT  e.last_name AS Employee, e.hire_date AS "Emp Hired", m.last_name AS Manager, m.hire_date AS "Mgr Hired"
FROM employees e
INNER JOIN employees m
ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;

-- OTRO LABORATORITO
-- 1) Muestre el salario mas alto, más bajo, sumatoria y promedio para todos los
-- empleados. Etiquete las columnas Maximum, Minimum, Sum y Average
-- respectivamente. Redondee los resultados al valor entero más cercano.
SELECT MAX(salary) AS Maximum, MIN(salary) AS Minimum, SUM(salary) AS Sum, ROUND(AVG(salary),0) AS Average
FROM employees;

-- 2) Modifique la consulta en 4.4. para que muestre el salario mínimo, maximo,
-- sumatoria y promedio para cada tipo de puesto.
SELECT job_id, MAX(salary) AS Maximum, MIN(salary) AS Minimum, SUM(salary) AS Sum, ROUND(AVG(salary),0) AS Average
FROM employees 
GROUP BY job_id;

-- 3) Escriba una consulta para mostrar el número de personas con el mismo puesto.
SELECT job_id, COUNT(*)
FROM employees
GROUP BY job_id;

-- 4) Determine el número de gerentes sin listarlos a ellos. Etiquete la columna
-- Number of Managers. Sugerencia: Utilice la columna MANAGER_ID para
-- determinar el número de gerentes.
SELECT COUNT(distinct MANAGER_ID) AS "Number of Managers"
FROM employees;

-- 5) Escriba una consulta para mostrar la diferencia entre el salario más alto y el
-- salario más bajo. Etiquete la columna DIFFERENCE.
SELECT MAX(salary) - MIN(salary) AS DIFFERENCE
FROM employees;

-- 6) Muestre el número de gerente y el salario del empleado con menos paga para
-- ese gerente. Excluya a cualquiera cuyo gerente sea desconocido. Excluya
-- cualquier grupo donde el salario mínimo sea menor que $6,000. Ordene la
-- salida en orden descendente por salario.
SELECT manager_id, MIN(salary)
FROM employees 
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING MIN(salary) >= 6000
ORDER BY MIN(salary) DESC;

-- 7) Escriba una consulta para mostrar el nombre de cada departamento, ubicación,
-- número de empleados, y el salario promedio de todos los empleados en el
-- departamento. Etiquete las columnas Name, Location, Number of People, y
-- Salary, respectivamente. Redondee el salario promedio a dos decimales.
SELECT d.department_name AS Name, l.city AS Location, COUNT(e.employee_id) AS "Number of people", ROUND(AVG(e.salary),2) AS Salary
FROM employees e
LEFT JOIN departments d
ON  e.department_id = d.department_id
LEFT JOIN locations l
ON d.location_id = l.location_id
GROUP BY d.department_name, l.city;




-- 8) Cree una consulta que muestre el número total de empleados y, para ese total,
-- el número de empleados contratados en 1995, 1996, 1997 y 1998. Cree
-- encabezados de columnas apropiados (TOTAL, 1995, 1996, 1997, 1998).
SELECT COUNT(*) total,
SUM(DECODE(TO_CHAR(hire_date,'YYYY'),1995,1,0)) "1995",
SUM(DECODE(TO_CHAR(hire_date,'YYYY'),1996,1,0)) "1996",
SUM(DECODE(TO_CHAR(hire_date,'YYYY'),1997,1,0)) "1997",
SUM(DECODE(TO_CHAR(hire_date,'YYYY'),1998,1,0)) "1998"
FROM employees;

-- 9) Cree una consulta de matriz que muestre el puesto, el salario para ese puesto
-- en base al número de departamento y el salario total para ese puesto, para los
-- departamentos 20, 50, 80 y 90, dando a cada columna el encabezado
-- apropiado (Job, Dept 20, Dept 50, Dept 80, Dept 90, Total).
SELECT job_id Job,
SUM(DECODE(department_id, 20, salary)) "Dept 20",
SUM(DECODE(department_id, 50, salary)) "Dept 50",
SUM(DECODE(department_id, 80, salary)) "Dept 80",
SUM(DECODE(department_id, 90, salary)) "Dept 90",
SUM(salary) Total
FROM employees
GROUP BY job_id;

------ SUBCONSULTAS ----------
-- 1) Cree una consulta para mostrar el apellido y fecha de contrato de cualquier
-- empleado en el mismo departamento que Zlotkey. Excluya a Zlotkey.
SELECT last_name, hire_date
FROM employees
WHERE department_id = (SELECT department_id
                        FROM employees
                        WHERE last_name = 'Zlotkey')
    AND employee_id <> (SELECT employee_id
                        FROM employees
                        WHERE last_name = 'Zlotkey');

-- 2) Cree una consulta para mostrar los números de empleados y apellidos de todos
-- los empleados que ganan por encima del salario promedio. Ordene los
-- resultados en orden descendente de salario.
SELECT employee_id, last_name
FROM employees
WHERE salary > (SELECT AVG(salary)
                FROM employees)
ORDER BY salary DESC;

-- 3) Cree una consulta que muestre los números de empleado y apellidos de todos
-- los empleados que trabajen en un departamento con otro empleado cuyo
-- apellido contiene una u.
SELECT employee_id, last_name
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM employees
                        WHERE last_name LIKE '%u%');

-- 4) Muestre el apellido, número de departamento y id de puesto de todos los
-- empleados cuyo código de ubicación de departamento es 1700.
SELECT last_name, department_id, job_id
FROM employees 
WHERE department_id IN (SELECT department_id
                        FROM departments
                        WHERE location_id = 1700);

-- 5) Muestre el apellido y salario de todos los empleados que reportan a King.
SELECT last_name, salary
FROM employees
WHERE manager_id IN (SELECT employee_id
                        FROM employees
                        WHERE last_name = 'King');

-- 6) Muestre el número de departamento, apellido y id de puesto de todos los
-- empleados en el departamento Executive.
SELECT employee_id, last_name, job_id
FROM employees
WHERE department_id IN(SELECT department_id
                        FROM departments
                        WHERE department_name = 'Executive');

-- 7) Modifique la consulta 2.3 para que muestre los números de empleado,
-- apellidos y salarios de todos los empleados que ganan mas del salario
-- promedio y que trabajan en un departamento con cualquier empleado que
-- tenga una u en su apellido.
SELECT employee_id, last_name, salary
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM employees
                        WHERE last_name LIKE '%u%')
    AND salary > (SELECT AVG(salary)
                    FROM employees);
                    
-- PL ----- NECESITO MUCHA FE EN ESE EXAMEN, YO SOY FE, DECRETO FE
SET SERVEROUTPUT ON
DECLARE
 v_nombrePais countries.country_name%TYPE;
BEGIN
    SELECT country_name
    INTO v_nombrePais
    FROM countries
    WHERE country_id = 'AU';
    DBMS_OUTPUT.PUT_LINE('El país es ' || v_nombrePais);
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encontró el país');

END;


SET SERVEROUTPUT ON
DECLARE
    CURSOR bonito_cursor IS
    --Consultita
    SELECT employee_id, last_name, first_name
    FROM employees
    WHERE last_name LIKE 'A%';
    TYPE bonito_type IS RECORD (
        employee_id employees.employee_id%TYPE,
        last_name employees.last_name%TYPE,
        first_name employees.first_name%TYPE
    );
    tipito bonito_type;
BEGIN
OPEN bonito_cursor;
LOOP
    FETCH bonito_cursor INTO tipito;
    EXIT WHEN bonito_cursor%notfound;
    dbms_output.put_line('Un empleado que tiene como inicial la letra A es: ' || tipito.last_name || ' ' || tipito.first_name || 
                            ' con identificador ' || TO_CHAR(tipito.employee_id));
END LOOP;
CLOSE bonito_cursor;
END;

-- INTENTOS

-- 2) Obtener y presentar la información de gastos en salario y estadística de empleados a
-- nivel regional. Como encabezado de cada región presente el nombre de la región y en
-- la siguiente línea indique como detalle la suma de salarios, cantidad de empleados, y
-- fecha de ingreso del empleado más antiguo.
SET SERVEROUTPUT ON;
DECLARE 
    cursor mi_cursor IS
        SELECT r.region_name, SUM(e.salary) AS sumSalary, COUNT(e.employee_id) AS numEmpl, MIN(hire_date) AS empAnt
        FROM employees e
        INNER JOIN departments d
        ON e.department_id = d.department_id
        INNER JOIN locations l
        ON d.location_id = l.location_id
        INNER JOIN  countries c
        ON l.country_id = c.country_id
        INNER JOIN regions r
        ON c.region_id = r.region_id
        GROUP BY r.region_name;
    TYPE my_type IS RECORD(
        region_name regions.region_name%TYPE,
        sumSalary employees.salary%TYPE,
        numEmpl PLS_INTEGER,
        empAnt employees.hire_date%TYPE
    ); 
    tipy my_type;
BEGIN
OPEN mi_cursor;
LOOP
    FETCH mi_cursor INTO tipy;
    EXIT WHEN mi_cursor%notfound;
    dbms_output.put_line('--- '|| tipy.region_name || ' ---');
    dbms_output.put_line('La suma de salarios asciende a: ' || TO_CHAR(tipy.sumSalary));
    dbms_output.put_line('Esta región cuenta con: ' || TO_CHAR(tipy.numEmpl));
    dbms_output.put_line('El empleado más antiguo ingreso el : ' || TO_CHAR(tipy.empAnt));
END LOOP;
CLOSE mi_cursor;
END;

-- 3.6)Obtenga el apellido del empleado, nombre de departamento y id de puesto de todos los
-- empleados cuya dirección de localización del departamento está en la quinta avenida (co-
-- lumna street_address).

SET SERVEROUTPUT ON;
DECLARE
    CURSOR myPrecioso IS
        SELECT e.last_name, d.department_name, e.job_id 
        FROM employees e
        INNER JOIN departments d
        ON e.department_id = d.department_id
        INNER JOIN locations l
        ON d.location_id = l.location_id
        WHERE l.street_address = '2014 Jabberwocky Rd';
    TYPE mytipito IS RECORD(
        last_name employees.last_name%TYPE,
        department_name departments.department_name%TYPE,
        job_id employees.job_id%TYPE
    );
    confe mytipito;
BEGIN
OPEN myPrecioso;
LOOP
    FETCH myPrecioso INTO confe;
    EXIT WHEN myPrecioso%NOTFOUND;
    dbms_output.put_line(confe.last_name || ' trabaja en el departamento ' || confe.department_name || ' como ' || confe.job_id);
END LOOP;
CLOSE myPrecioso;
END;


SET SERVEROUTPUT ON;
ACCEPT depa_id PROMPT 'Inserte el ID del departamento de interés: '
DECLARE
    v_department_id departments.department_id%type := &depa_id;
    v_department_name departments.department_name%TYPE;
    v_totalEmp PLS_INTEGER;
    v_salProm NUMBER(10,2);
    v_emplAnt employees.first_name%TYPE;
BEGIN
    SELECT d.department_name, COUNT(e.employee_id), ROUND(AVG(e.salary),2)
    INTO v_department_name, v_totalEmp,  v_salProm
    FROM employees e
    INNER JOIN departments d
    ON e.department_id = d.department_id
    WHERE d.department_id = v_department_id
    GROUP BY d.department_name;
    
    SELECT first_name || ' ' || last_name
    INTO v_emplAnt
    FROM employees
    WHERE hire_date IN (SELECT MIN(hire_date)
                        FROM employees
                        WHERE department_id = v_department_id)
        AND department_id = v_department_id;
    dbms_output.put_line('Nombre del departamento: '||v_department_name);
    dbms_output.put_line('Total de empleados: '||v_totalEmp);
    dbms_output.put_line('Salario promedio: '|| TO_CHAR(v_salProm));
    dbms_output.put_line('Empleado más antiguo: '||v_emplAnt);
EXCEPTION
    WHEN no_data_found THEN
    dbms_output.put_line('No existe ningún departmento con ese ID.');
END;

SELECT * FROM departments;
