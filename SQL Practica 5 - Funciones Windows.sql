--1. Ranking de empleados por salario
-- Obt�n el ranking de empleados basado en su salario (Rate) dentro de cada departamento (DepartmentID), usando RANK().

SELECT TOP 5 * FROM HumanResources.EmployeePayHistory
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Department

SELECT 
	p.FirstName,
	p.LastName,
	d.Name,
	RANK () OVER (
	PARTITION BY edh.DepartmentID
	ORDER BY eph.rate DESC) AS Ranking_rate,
	eph.rate AS rate
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Department d
	ON d.DepartmentID= edh.DepartmentID

-- RANK le da el mismo lugar si tienen el mismo valor. 


-- 2. Orden de ventas por fecha
-- Para cada cliente (CustomerID), muestra sus �rdenes (SalesOrderID) y la fecha de la orden, 
-- junto con un n�mero de orden creciente (ROW_NUMBER()) seg�n la fecha de la venta.


SELECT 
	CustomerID AS Cliente,
	SalesOrderID AS ID_venta,
	OrderDate AS Fecha_orden,
	ROW_NUMBER() OVER (
	PARTITION BY CustomerID
	ORDER BY OrderDate
	) AS Orden_creciente
FROM Sales.SalesOrderHeader

-- 3. Promedio acumulado de salarios.
-- Para cada empleado, calcula el promedio acumulado (AVG() OVER) de salarios ordenado por la fecha de ingreso (HireDate).

SELECT TOP 5 * FROM HumanResources.EmployeePayHistory
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Employee

SELECT 
	p.FirstName,
	p.LastName,
	AVG(eph.rate) OVER (
	PARTITION BY eph.BusinessEntityID
	) AS Promedio_empleado,
	eph.rate AS rate -- para chequear nomas
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Employee e
	ON e.BusinessEntityID = eph.BusinessEntityID
ORDER BY e.HireDate DESC;


-- 4. Ventas acumuladas por cliente.
--Para cada cliente, muestra cada orden junto con el total acumulado de compras (SubTotal) ordenadas por fecha.

SELECT TOP 5* FROM Sales.SalesOrderHeader

SELECT 
	CustomerID AS Cliente,
	SalesOrderID AS ID_venta,
	OrderDate AS Fecha_orden,
	SUM(SubTotal) OVER (
	PARTITION BY CustomerID
	ORDER BY OrderDate
	) AS Total_Acumulado
FROM Sales.SalesOrderHeader


-- 5. Diferencia de salario respecto al anterior.
-- Para cada empleado ordenado por fecha de contrataci�n, muestra la diferencia de su salario respecto al empleado anterior.


WITH empleados_sueldo AS
(
SELECT
	p.FirstName As Nombre,
	p.LastName AS Apellido,
	SUM(eph.rate) OVER (
	PARTITION BY eph.BusinessEntityID
	) AS Sueldo,
	e.HireDate AS fecha_contratacion
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Employee e
	ON e.BusinessEntityID = eph.BusinessEntityID
)
SELECT 
    Nombre,
    Apellido,
    Sueldo,
    fecha_contratacion,
    LAG(Sueldo) OVER (
        ORDER BY fecha_contratacion
    ) AS Sueldo_Anterior
FROM empleados_sueldo;

-- aca me quedan repetidos los empleados, tengo que eliminar empleado que hayan cobrado mas de una vez?

WITH sueldo_final AS (
    SELECT 
        eph.BusinessEntityID,
        eph.Rate AS Sueldo,
        ROW_NUMBER() OVER (
		PARTITION BY eph.BusinessEntityID 
		ORDER BY eph.RateChangeDate DESC) AS rn
    FROM HumanResources.EmployeePayHistory eph
),
empleados_unicos AS (
    SELECT 
        e.BusinessEntityID,
        p.FirstName AS Nombre,
        p.LastName AS Apellido,
        e.HireDate,
        s.Sueldo
    FROM HumanResources.Employee e
    INNER JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
    INNER JOIN sueldo_final s ON s.BusinessEntityID = e.BusinessEntityID
    WHERE s.rn = 1 -- nos quedamos con el �ltimo sueldo
)
SELECT 
    Nombre,
    Apellido,
    Sueldo,
    HireDate AS fecha_contratacion,
    LAG(Sueldo) OVER (ORDER BY HireDate) AS Sueldo_Anterior
FROM empleados_unicos;


-- 6. Salario m�ximo y m�nimo por departamento.
-- Muestra el salario actual de cada empleado, el salario m�ximo y el m�nimo dentro de su departamento.

SELECT TOP 5 * FROM HumanResources.EmployeePayHistory
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Employee

-- 7. Identificar empleados con salario mayor al promedio del departamento.
-- Lista los empleados cuyo salario (Rate) es mayor al promedio de su departamento usando AVG() OVER (PARTITION BY ...).


-- 8. Duraci�n entre �rdenes consecutivas.
-- Para cada cliente, calcula cu�ntos d�as pasaron entre cada orden y la anterior (LAG() o LEAD()).

-- 9. Top 3 productos m�s vendidos por categor�a.
-- Obt�n los tres productos m�s vendidos (por cantidad) en cada categor�a de producto usando DENSE_RANK().


-- 10. Detecci�n de cambios de tarifa.
-- Para cada empleado, detecta cu�ndo cambi� su tarifa (Rate) respecto a la anterior usando LAG().
