-- Ejercicio 1
SELECT * FROM Person.Person 

-- Ejercicio 2: Mostrar los nombres y apelllido de cada persona que tenga como tratamiento �Ms.�

SELECT FirstName, LastName 
FROM Person.Person
WHERE FirstName like '%Ms' or LastName LIKE '%Ms'

-- Ejercicio 3: Mostrar el Id y apellido de las personas que se los llame como �Mr.� y su apellido sea �White�

SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE FirstName LIKE 'Mr.%' and LastName = 'White'

-- Ejercicio 4: �Cu�les son los tipos de personas existentes en la tabla?

SELECT PersonType, COUNT (PersonType)
FROM Person.Person
GROUP BY PersonType

-- Ejercicio 5: Mostrar los datos de las personas que tengan asignado el tipo �SP� � el tipo �VC�.

SELECT PersonType, FirstName, LastName
FROM Person.Person
WHERE PersonType= 'SP' OR PersonType= 'VC'

-- Ejercicio 6: Mostrar el contenido de la tabla Employee, del esquema HumanResources 

SELECT * FROM HumanResources.Employee 

-- Ejercicio 7: Hallar el Id y fecha de nacimiento de los empleados que tengan como funci�n �Research and Development Manager� y que tengan menos de 10 �VacationHours�.

SELECT BusinessEntityID, BirthDate 
FROM HumanResources.Employee
WHERE JobTitle = 'Research and Development Manager' AND VacationHours < 10

-- Ejercicio 8: �Cu�les son los tipos de �g�nero� que figuran en la tabla de empleados?

SELECT Gender, COUNT(Gender)
FROM HumanResources.Employee 
GROUP BY Gender

-- Ejecicio 9: Mostrar el id, nombres, apellido de los empleados ordenados desde el de fecha de nacimiento m�s antigua.

SELECT p.BusinessEntityID, FirstName, LastName, BirthDate
FROM Person.Person as p , HumanResources.Employee as e
ORDER BY (BirthDate)

-- Ejecicio 10: Mostrar el contenido de la tabla Departments

SELECT * FROM HumanResources.Department

-- Ejecicio 10: Mostrar el contenido de la tabla Departments

SELECT * FROM HumanResources.Department

-- Ejecicio 11: �Cu�les son los departamentos que est�n agrupados como �Manufacturing� � como �Quality Assurance�?

SELECT Name , GroupName
FROM HumanResources.Department
WHERE GroupName = 'Manufacturing' or GroupName = 'Quality Assurance'

-- Ejercicio 12: �Cu�les son los datos de los departamentos cuyo nombre est� relacionado con �Production�?

SELECT Name 
FROM HumanResources.Department
WHERE Name Like 'Production%'

-- Ejercicio 13: Mostrar los datos de los departamentos que no est�n agrupados como �Research and Develpment�

SELECT Name , GroupName
FROM HumanResources.Department
WHERE GroupName != 'Research and Develpment' 

-- Ejercicio 14: Mostrar los datos de la tabla Product del esquema Production

SELECT * FROM Production.Product 

-- Ejercicio 14: Mostrar los datos de la tabla Product del esquema Production

SELECT * FROM Production.Product 

-- Ejercicio 15: Hallar los productos que no tengan asignado color.

SELECT Name, ColorFROM Production.Product WHERE Color IS NULL

-- Ejercicio 16: Para todos los productos que tengan asignado alg�n color y que tengan un stock
-- (SafetyStockLevel) mayor a 900, mostrar su id, nombre y color. Ordernarlo por id descendente
-- y por color ascendente.

SELECT ProductID, Name, Color, SafetyStockLevel
FROM Production.Product 
WHERE Color IS NOT NULL and SafetyStockLevel > 900
ORDER BY ProductID ASC, Color DESC

-- Ejercicio 17: Hallar el Id y el nombre de los productos cuyo nombre comience con �Chain�

SELECT ProductID, Name 
FROM Production.Product
WHERE Name LIKE 'CHAIN%'

-- Ejercicio 18: Hallar el Id y el nombre de los productos cuyo nombre contenga �helmet�

SELECT ProductID, Name 
FROM Production.Product
WHERE Name LIKE '%helmet%'

-- Ejercicio 19: Modificar la consulta anterior para que retorne aquellos productos cuyo nombre no contenga �helmet�
SELECT ProductID, Name 
FROM Production.Product
WHERE Name NOT LIKE '%helmet%'


-- Ejercicio 20: Mostrar los datos principales de las personas (tabla Person) cuyo LastName termine con �es� y contenga en total 5 caracteres
SELECT TOP(10) BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE LastName LIKE '%___es%'


-- Ejercicio 21: Usando la tabla SpecialOffer del esquema Sales, mostrar la diferencia entre MinQty y MaxQty, con el id y descripci�n.
SELECT TOP(10)* FROM Sales.SpecialOffer

-- Ejercicio 21,22,23: Usando la tabla SpecialOffer del esquema Sales, mostrar la diferencia entre MinQty y MaxQty, con el id y descripci�n.
SELECT SpecialOfferID, Description, MaxQty, MinQty,
    CASE 
        WHEN MinQty = 0 OR MinQty IS NULL OR MaxQty IS NULL THEN NULL
        ELSE MaxQty - MinQty 
    END AS Diferencia
FROM Sales.SpecialOffer

-- Ejercicio 24: �Cu�ntos clientes est�n almacenados en la tabla Customers?

SELECT COUNT(CustomerID)
FROM Sales.Customer

-- Ejercicio 25: �Cu�l es la cantidad de clientes por tienda? Y cu�l es la cantidad de clientes por territorio para
-- aquellos territorios que tengan m�s de 100 clientes? �Cu�les son las tiendas (su Id) asociadas
-- al territorio Id 4 que tienen menos de 2 clientes?

SELECT StoreID, COUNT(CustomerID)
FROM Sales.Customer
GROUP BY StoreID

SELECT TerritoryID, COUNT(CustomerID)
FROM Sales.Customer
GROUP BY TerritoryIDHAVING COUNT(CustomerID) > 100

SELECT StoreID
FROM Sales.Customer
WHERE TerritoryID = 4
GROUP BY StoreID
HAVING COUNT(CustomerID) < 2

-- Ejercicio 26: Para la tabla SalesOrderDetail del esquema Sales, calcular cu�l es la cantidad total de items
-- ordenados (OrderQty) para el producto con Id igual a 778.

SELECT SUM(OrderQty) AS TotalItemsOrdered
FROM Sales.SalesOrderDetail
WHERE ProductID = 778

--27.Usando la misma tabla,
SELECT TOP(10) *
FROM Sales.SalesOrderDetail

---a) Cu�l es el precio unitario m�s caro vendido?
SELECT MAX(UnitPrice) 
FROM Sales.SalesOrderDetail

---b) Cu�l es el n�mero total de items ordenado para cada producto?

SELECT ProductID, SUM(OrderQty) 
FROM Sales.SalesOrderDetail
GROUP BY ProductID

---c) Cu�l es la cantidad de l�neas de cada orden?

SELECT SalesOrderID, COUNT(*) AS LineasPorOrden
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID

-- d) Cu�l es la cantidad de l�neas de cada orden, s�lo para aquellas �rdenes que tengan
-- m�s de 3 l�neas? Ordenar por id de orden descendente.

SELECT SalesOrderID, COUNT(*) AS LineasPorOrden
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(*) > 3
ORDER BY SalesOrderID DESC

-- e) Cu�l es el importe total (LineTotal) de cada orden, para aquellas que tengan menos de
-- 3 l�neas?

SELECT SalesOrderID, COUNT(*) AS LineasPorOrden, SUM(LineTotal) AS ImporteTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(*) < 3

-- f) Cu�l es la cantidad distinta de productos ordenados?

SELECT COUNT(DISTINCT ProductID) AS CantProdDistintos
FROM Sales.SalesOrderDetail 

-- Ejercicio 28: Usando la tabla SalesOrderHeader, cu�l es la cantidad de �rdenes emitidas en cada a�o?
-- (usar la funci�n Year, aplicada a la columna OrderDate).


SELECT TOP(10) *
FROM Sales.SalesOrderHeader

SELECT YEAR(OrderDate),COUNT(SalesOrderID)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)

-- Ejercicio 29.Usando la misma tabla, cu�l es la cantidad de �rdenes emitidas para cada cliente en cada a�o?

SELECT YEAR(OrderDate),CustomerID, COUNT(SalesOrderID)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), CustomerID

-- Ejercicio 30: Para los empleados, contar la cantidad de empleados solteros nacidos por a�o y por g�nero,
-- para aquellos a�os donde hayan nacido m�s de 10 empleados.

SELECT TOP(10) * 
FROM HumanResources.Employee

SELECT     
	YEAR(BirthDate) AS A�oNacimiento,
    Gender AS Genero,
    COUNT(BusinessEntityID) AS CantEmpleados
FROM HumanResources.Employee
WHERE MaritalStatus = 'S'
GROUP BY YEAR(BirthDate), Gender
HAVING COUNT(*) > 10