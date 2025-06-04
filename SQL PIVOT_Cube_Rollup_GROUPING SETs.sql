--Pivot 

WITH Fuente (Producto,A�o,Total) AS 
(
SELECT p.Name AS Producto, 
	YEAR(soh.OrderDate) AS A�o, 
	Sum(sod.LineTotal) AS Total
 FROM Sales.SalesOrderHeader soh
 JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
 JOIN Production.Product p ON p.ProductID = sod.ProductID
group by p.Name, YEAR(soh.OrderDate)
)

SELECT *
FROM Fuente
PIVOT (
SUM(Total) FOR A�o IN ([2011], [2012], [2013], [2014])
) AS pvt

--La presencia de null ocurre porque en esos a�os no se realizaron ventas en esos productos

-- Unpivot

WITH Fuente (Producto,A�o,Total) AS 
(
SELECT p.Name AS Producto, 
	YEAR(soh.OrderDate) AS A�o, 
	Sum(sod.LineTotal) AS Total
 FROM Sales.SalesOrderHeader soh
 JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
 JOIN Production.Product p ON p.ProductID = sod.ProductID
group by p.Name, YEAR(soh.OrderDate)
)
SELECT Producto, A�o, Total
FROM (
 SELECT Producto, [2011], [2012], [2013], [2014]
 FROM Fuente
 PIVOT (
SUM(Total) FOR A�o IN ([2011], [2012], [2013], [2014])
 ) AS pvt
) AS datos_pivot
UNPIVOT (
 Total FOR A�o IN ([2011], [2012], [2013], [2014])
) AS unpvt;

-- Con dos CTE es mas prolijo,

WITH Fuente AS (
    SELECT 
        p.Name AS Producto, 
        YEAR(soh.OrderDate) AS A�o, 
        SUM(sod.LineTotal) AS Total
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON p.ProductID = sod.ProductID
    GROUP BY p.Name, YEAR(soh.OrderDate)
),
PivotFuente AS (
    SELECT Producto, [2011], [2012], [2013], [2014]
    FROM Fuente
    PIVOT (
        SUM(Total) FOR A�o IN ([2011], [2012], [2013], [2014])
    ) AS pvt
)
SELECT Producto, A�o, Total
FROM PivotFuente
UNPIVOT (
    Total FOR A�o IN ([2011], [2012], [2013], [2014])
) AS unpvt;

-- Ejercicio: Usando AdventureWorks, crear una consulta que muestre cu�ntas �rdenes realiz� cada
-- empleado por a�o (Sales.SalesOrderHeader y HumanResources.Employee). --> CTE

-- Usar PIVOT para mostrar cada a�o como columna y la cantidad de �rdenes por empleado.

WITH ventas_empleado (Empleado,A�o,Cantidad_ordenes) AS 
(
SELECT 
	e.BusinessEntityID AS Empleado,
	YEAR(soh.OrderDate) AS A�o, 
	COUNT(soh.SalesOrderID) AS Cantidad_ordenes
 FROM Sales.SalesOrderHeader soh
 JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
group by e.BusinessEntityID, YEAR(soh.OrderDate)
)

SELECT *
FROM ventas_empleado
PIVOT (
SUM(Cantidad_ordenes) FOR A�o IN ([2011], [2012], [2013], [2014])
) AS pvt


-- CUBE : La cl�usula CUBE en SQL Server es una extensi�n de la cl�usula GROUP BY que genera
-- subtotales para todas las combinaciones posibles de columnas especificadas.

-- ej: uso AdventureWorksDW20219

SELECT 
    fk.name AS ForeignKey,
    tp.name AS ParentTable,
    ref.name AS ReferencedTable,
    cpa.name AS ParentColumn,
    cref.name AS ReferencedColumn
FROM sys.foreign_keys fk
INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables ref ON fk.referenced_object_id = ref.object_id
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.columns cpa ON fkc.parent_object_id = cpa.object_id AND fkc.parent_column_id = cpa.column_id
INNER JOIN sys.columns cref ON fkc.referenced_object_id = cref.object_id AND fkc.referenced_column_id = cref.column_id
WHERE tp.name LIKE 'Dim%' OR tp.name LIKE 'Fact%'
ORDER BY ParentTable, ReferencedTable;


SELECT
	CalendarYear,
	SalesTerritoryGroup,
	SUM(SalesAmount) AS TotalVentas
FROM FactResellerSales AS frs
JOIN DimDate AS d ON frs.OrderDateKey = d.DateKey
JOIN DimSalesTerritory AS st ON frs.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY
CUBE(CalendarYear, SalesTerritoryGroup)
ORDER BY
CalendarYear, SalesTerritoryGroup;


-- ROLLUP: La cl�usula ROLLUP en SQL Server se utiliza junto con la cl�usula
-- GROUP BY para generar subtotales y totales adicionales para una o
-- m�s columnas especificadas. Proporciona un resumen jer�rquico de
-- los datos al incluir subtotales para combinaciones de columnas
-- espec�ficas.

SELECT 
    YEAR(fis.OrderDate) AS A�o,
    dp.EnglishProductName AS Producto,
    SUM(fis.SalesAmount) AS TotalVentas
FROM FactInternetSales fis
JOIN DimProduct dp ON fis.ProductKey = dp.ProductKey
GROUP BY 
    ROLLUP (YEAR(fis.OrderDate), dp.EnglishProductName)
ORDER BY 
    A�o, Producto;


-- GRUPING SETS: permite definir combinaciones espec�ficas de agrupamiento dentro de
-- una sola consulta GROUP BY

SELECT 
	Color,
	Size
FROM Production.Product
WHERE Color IS NOT NULL  AND Size IS NOT NULL
GROUP BY 
    GROUPING SETS (
        (Color, Size),  
        (Color),        
        (Size),         
        ()              
    )
ORDER BY Color, Size;

-- otra en DW

SELECT 
    YEAR(fis.OrderDate) AS A�o,
    dst.SalesTerritoryGroup AS Region,
    SUM(fis.SalesAmount) AS TotalVentas
FROM FactInternetSales fis
JOIN DimSalesTerritory dst ON fis.SalesTerritoryKey = dst.SalesTerritoryKey
GROUP BY 
    GROUPING SETS (
        (YEAR(fis.OrderDate), dst.SalesTerritoryGroup),  -- a�o y regi�n
        (YEAR(fis.OrderDate)),                           -- solo a�o
        (dst.SalesTerritoryGroup),                       -- solo regi�n
        ()                                               -- total general
    )
ORDER BY A�o, Region;


--ej:
SELECT
 ISNULL(Color,
CASE WHEN GROUPING(Color) = 1 THEN 'TODOS' ELSE 'DESC' END) AS Color,
 COUNT(*) AS Cantidad
FROM Production.Product
GROUP BY ROLLUP(Color);

-- Si el color esta ausente muestra DESC