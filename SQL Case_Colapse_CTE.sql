--  Elabore una consulta que recupere el identificador (BusinessEntityID) y la condici�n
-- contractual (SalariedFlag) de los empleados registrados en la tabla
-- HumanResources.Employee. La salida deber� estar ordenada de manera que los
-- empleados asalariados (SalariedFlag = 1) aparezcan primero en orden descendente
-- seg�n su identificador, seguidos por los empleados no asalariados (SalariedFlag = 0),
-- ordenados en forma ascendente por el mismo campo

SELECT TOP 5 * FROM HumanResources.Employee;

SELECT BusinessEntityID,
    SalariedFlag
FROM HumanResources.Employee
ORDER BY
    CASE SalariedFlag
        WHEN 1 THEN BusinessEntityID END DESC,
    CASE SalariedFlag
        WHEN 0 THEN BusinessEntityID END ASC;


-- Formule una consulta que liste el identificador (BusinessEntityID), apellido (LastName),
-- nombre del territorio (TerritoryName) y regi�n o pa�s (CountryRegionName) de los
-- vendedores registrados en la vista Sales.vSalesPerson. La consulta debe excluir aquellos
-- registros sin territorio asignado y ordenar los resultados alfab�ticamente por
-- TerritoryName �nicamente cuando el pa�s sea 'United States'; en caso contrario, debe
-- ordenar por CountryRegionName.


SELECT BusinessEntityID,
    LastName,
    TerritoryName,
    CountryRegionName
FROM Sales.vSalesPerson 
WHERE TerritoryName IS NOT NULL
ORDER BY CASE CountryRegionName
    WHEN 'United States' THEN TerritoryName
    ELSE CountryRegionName END;


-- Elabore una consulta que recupere el t�tulo del puesto (JobTitle) y la tasa m�xima
-- de pago (MaximumRate) de los empleados registrados en las tablas
-- HumanResources.Employee y HumanResources.EmployeePayHistory.
-- La consulta debe agrupar los resultados por t�tulo de puesto y filtrar aquellos
-- t�tulos en los que el salario m�ximo de los empleados asalariados sea mayor a
-- 40.00 o el salario m�ximo de los empleados no asalariados sea mayor a 15.00.
-- Los resultados deben ordenarse en orden descendente seg�n la tasa m�xima de pago.

SELECT 
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'HumanResources'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


SELECT JobTitle,
    MAX(ph.Rate) AS MaximumRate
FROM HumanResources.Employee AS e
INNER JOIN HumanResources.EmployeePayHistory AS ph
    ON e.BusinessEntityID = ph.BusinessEntityID
GROUP BY JobTitle
HAVING (
    MAX(CASE WHEN e.SalariedFlag = 1 THEN ph.Rate ELSE 0 END) > 40.00
    OR 
    MAX(CASE WHEN e.SalariedFlag = 0 THEN ph.Rate ELSE 0 END) > 15.00
)
ORDER BY MaximumRate DESC;


-- Colapse 

SELECT p.BusinessEntityID,
p.FirstName,p.LastName,
COALESCE(phBusiness.PhoneNumber, phHome.PhoneNumber, phCell.PhoneNumber, 'No Disponible') AS ContactPhone
FROM Person.Person AS p
LEFT JOIN Person.PersonPhone AS phBusiness ON p.BusinessEntityID = phBusiness.BusinessEntityID
AND phBusiness.PhoneNumberTypeID = 3 -- Tipo "Business"
LEFT JOIN Person.PersonPhone AS phHome ON p.BusinessEntityID = phHome.BusinessEntityID
AND phHome.PhoneNumberTypeID = 1 -- Tipo "Home"
LEFT JOIN Person.PersonPhone AS phCell ON p.BusinessEntityID = phCell.BusinessEntityID
AND phCell.PhoneNumberTypeID = 2 -- Tipo "Cell"
ORDER BY p.BusinessEntityID;

-- Y si quiero los empleados que no tienen telefono? Con la consulta, anterior creo un CTE y Filtro 

WITH Telefonos (BusinessEntityID, FirstName, LastName, ContactPhone)
AS 
(
SELECT p.BusinessEntityID,
p.FirstName,p.LastName,
COALESCE(phBusiness.PhoneNumber, phHome.PhoneNumber, phCell.PhoneNumber, 'No Disponible') AS ContactPhone
FROM Person.Person AS p
LEFT JOIN Person.PersonPhone AS phBusiness ON p.BusinessEntityID = phBusiness.BusinessEntityID
AND phBusiness.PhoneNumberTypeID = 3 -- Tipo "Business"
LEFT JOIN Person.PersonPhone AS phHome ON p.BusinessEntityID = phHome.BusinessEntityID
AND phHome.PhoneNumberTypeID = 1 -- Tipo "Home"
LEFT JOIN Person.PersonPhone AS phCell ON p.BusinessEntityID = phCell.BusinessEntityID
AND phCell.PhoneNumberTypeID = 2 -- Tipo "Cell"
)
SELECT BusinessEntityID, FirstName, LastName, ContactPhone 
FROM Telefonos
WHERE ContactPhone = 'No Disponible';


-- Definir CTE nombre y lista de columnas

WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)  
AS  
-- Definir CTE query.  
(  
    SELECT SalesPersonID, SalesOrderID, YEAR(OrderDate) AS SalesYear  
    FROM Sales.SalesOrderHeader  
    WHERE SalesPersonID IS NOT NULL  
)  

-- Definir  outer query referenciando al CT .  
SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, SalesYear  
FROM Sales_CTE  
GROUP BY SalesYear, SalesPersonID  
ORDER BY SalesPersonID, SalesYear; 


--  A partir de la tabla Sales.SalesOrderHeader, calcular cu�ntas �rdenes realiz� cada
-- vendedor por a�o (campo SalesPersonID), y luego obtener el promedio anual de �rdenes
-- por persona. Utilizar una CTE para agrupar por a�o y vendedor, y luego una consulta
-- principal que agrupe por vendedor. 

-- DEfino CTE A�o_vendedor
WITH A�o_vendedor (SalesPersonID, A�o, CantidadOrdenes)
AS (
SELECT 
    soh.SalesPersonID AS SalesPersonID,
    YEAR(soh.OrderDate) AS A�o,
    COUNT(*) AS CantidadOrdenes
FROM Sales.SalesOrderHeader soh
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY soh.SalesPersonID, YEAR(soh.OrderDate)
)
-- Consulta principal 
SELECT 
SalesPersonID, 
AVG(CantidadOrdenes) As Promedio_cantidadOrdenes_A�o
FROM A�o_vendedor
GROUP BY SalesPersonID
ORDER BY Promedio_cantidadOrdenes_A�o DESC;


-- Mostrar cu�nto vendi� cada vendedor por a�o, cu�l era su cuota anual y si super� o no
-- esa cuota, usando m�ltiples CTE

WITH Sales_CTE (SalesPersonID, TotalSales, SalesYear)  
AS  
-- Definir primer CTE.  
(  
    SELECT 
	SalesPersonID, 
	SUM(TotalDue) AS TotalSales, 
	YEAR(OrderDate) AS SalesYear  
    FROM Sales.SalesOrderHeader  
    WHERE SalesPersonID IS NOT NULL  
    GROUP BY SalesPersonID, YEAR(OrderDate)  
)  
,  
  
--  Definir la segunda consulta CTE, que devuelve datos de cuota de ventas por a�o para cada vendedor.
Sales_Quota_CTE (BusinessEntityID, SalesQuota, SalesQuotaYear)  
AS  
(  
       SELECT 
	   BusinessEntityID, 
	   SUM(SalesQuota)AS SalesQuota, 
	   YEAR(QuotaDate) AS SalesQuotaYear  
       FROM Sales.SalesPersonQuotaHistory  
       GROUP BY BusinessEntityID, YEAR(QuotaDate)  
)  
  
-- Definir  la outer query referenciando columnas de ambas CTE
SELECT SalesPersonID  
  , SalesYear  Year
  , FORMAT(TotalSales,'C','en-us') AS TotalSales  
  
  , FORMAT (SalesQuota,'C','en-us') AS SalesQuota  
  , FORMAT (TotalSales -SalesQuota, 'C','en-us') AS Amt_Above_or_Below_Quota  
FROM Sales_CTE  
inner JOIN Sales_Quota_CTE 
ON Sales_Quota_CTE.BusinessEntityID = Sales_CTE.SalesPersonID  
AND Sales_CTE.SalesYear = Sales_Quota_CTE.SalesQuotaYear  
ORDER BY SalesPersonID, SalesYear;




