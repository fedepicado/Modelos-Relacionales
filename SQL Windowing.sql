-- Una funci�n Window es una funci�n que se aplica a un conjunto de filas. Window es el 
--t�rmino que usa el est�ndar SQL para describir el contexto en el que opera la funci�n. SQL usa 
--una cl�usula llamada OVER en la que se proporciona la especificaci�n de la ventana. 

-- OVER con ORDER BY- ROW_NUMBER()

SELECT 
	CustomerID, 
	SalesOrderID,
	ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber
FROM Sales.SalesOrderHeader;

-- OVER con PARTITION BY
-- Partition me permite enumerar por grupo

SELECT
	CustomerID, 
	SalesOrderID,
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
AS RowNumber
FROM Sales.SalesOrderHeader;

--
SELECT	
	DISTINCT OrderDate,
	ROW_NUMBER() OVER(ORDER BY OrderDate) AS RowNumber
FROM Sales.SalesOrderHeader
ORDER BY RowNumber;


--Ejercicio : A partir del problema anterior con el distinct se pide;
-- � Resolver el problema para que me queden numeradas las ordenes de fechas
-- distintas (es decir un numero por fecha sin repetir fechas.

WITH FechasUnicas AS (
    SELECT DISTINCT OrderDate
    FROM Sales.SalesOrderHeader
)
SELECT 
    OrderDate,
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber
FROM FechasUnicas;


-- � Obtener la a segunda fecha m�s antigua.

WITH FechasUnicas AS (
    SELECT DISTINCT OrderDate
    FROM Sales.SalesOrderHeader
),
FechasNumeradas AS 
(
    SELECT 
        OrderDate,
        ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber
    FROM FechasUnicas
)
SELECT 
	OrderDate AS SegundaFechaMasAntigua
FROM FechasNumeradas
WHERE RowNumber = 2;

-- Ranking Functions

-- NTILE:

--� Calcula la cantidad total de filas (por partici�n si se usa
--PARTITION BY, o en total si no).
-- � Divide las filas en n grupos, intentando que todos tengan la
-- misma cantidad, pero:Algunos grupos tendr�n una fila m�s
-- que otros, si la divisi�n no es exacta.
-- � Los primeros grupos (con n�meros de balde m�s bajos)
-- reciben la fila extra.

-- El problema del bonus llevado a este DB.
Select top 5 * FROM  Sales.SalesOrderHeader

WITH Vendedores AS (
	SELECT
		SalesPersonID, 
		COUNT(SalesOrderID) AS TotalVentas
	FROM Sales.SalesOrderHeader
	GROUP BY SalesPersonID
),
RankingVendedores AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY TotalVentas DESC) AS grupo_bonus
    FROM Vendedores
)
SELECT *,
    CASE grupo_bonus
        WHEN 1 THEN 4000
        WHEN 2 THEN 3000
        WHEN 3 THEN 2000
        ELSE 1000
    END AS Bonus
FROM RankingVendedores;


--- Funciones de agregacion

SELECT 
	CustomerID, 
	SalesOrderID,
	CAST(MIN(OrderDate) OVER() AS DATE) AS FirstOrderDate,
	CAST(MAX(OrderDate) OVER() AS DATE) AS LastOrderDate,
	COUNT(*) OVER() OrderCount,
	FORMAT(SUM(TotalDue) OVER(),'C') TotalAmount
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;

-- FirstOrderDate primera compra de toda la tabla y TotalAmount dinero gastado en todas las �rdenes.

SELECT CustomerID, SalesOrderID,
	CAST(MIN(OrderDate) OVER(PARTITION BY CustomerID) AS DATE) AS FirstOrderDate,
	CAST(MAX(OrderDate) OVER(PARTITION BY CustomerID) AS DATE) AS LastOrderDate,
	COUNT(*) OVER(PARTITION BY CustomerID) OrderCount,
	FORMAT(SUM(TotalDue) OVER(PARTITION BY CustomerID),'C') AS TotalAmount
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;

-- Cada columna orientado al cliente.

SELECT 
	CustomerID, 
	SalesOrderID,
	CAST(OrderDate AS Date) AS OrderDate,
	MIN(SalesOrderID/CustomerID) OVER(
	PARTITION BY CustomerID) AS Expr1,
	CAST(MIN(DATEADD(d,1,OrderDate)) OVER() AS DATE) AS Expr2,
	AVG((SELECT COUNT(*) FROM Sales.SalesOrderDetail AS SOD
WHERE SalesOrderID = SOH.SalesOrderID)) OVER() AS Expr3
FROM Sales.SalesOrderHeader AS SOH;

--

SELECT 
	CustomerID,
	SalesOrderID,
	CAST(OrderDate AS DATE) AS OrderDate,TotalDue,
	SUM(TotalDue) OVER(
	PARTITION BY CustomerID 
	ORDER BY SalesOrderID) AS Acumulado
FROM Sales.SalesOrderHeader;



-- Un frame (o ventana de filas) define el subconjunto de datos sobre el cual se aplican funciones de ventana (window functions).
-- Cuando se usa OVER(), SQL puede calcular una funci�n no sobre todas las filas de la partici�n, sino solo sobre un rango espec�fico de filas.

-- Terminos usados para frames

-- � ROWS: Un operador f�sico. Examina la posici�n de las filas.
-- � RANGE: Examina el valor de una expresi�n en lugar de la posici�n.
-- � UNBOUNDED PRECEDING: El frame comienza en la primera fila del conjunto.
-- � UNBOUNDED FOLLOWING: El frame termina en la �ltima fila del conjunto.
-- � N PRECEDING: Un n�mero f�sico de filas antes de la fila actual. Compatible solo con ROWS.
-- � N FOLLOWING: Un n�mero f�sico de filas despu�s de la fila actual. Compatible solo con ROWS.
-- � CURRENT ROW: La fila del c�lculo actual


-- LAG LEAD 

SELECT 
	CustomerID,
	SalesOrderID,
	CAST(OrderDate AS DATE) AS OrderDate,
	TotalDue,
	-- Acumulado progresivo por cliente
	SUM(TotalDue) OVER(
		PARTITION BY CustomerID 
		ORDER BY SalesOrderID) AS Acumulado,
	-- TotalDue del pedido anterior
	LAG(TotalDue) OVER(
		PARTITION BY CustomerID 
		ORDER BY SalesOrderID) AS PedidoAnterior,
	-- Diferencia con el pedido anterior
	TotalDue - LAG(TotalDue) OVER(
		PARTITION BY CustomerID 
		ORDER BY SalesOrderID) AS DiferenciaConAnterior,
	-- TotalDue del siguiente pedido
	LEAD(TotalDue) OVER(
		PARTITION BY CustomerID 
		ORDER BY SalesOrderID) AS PedidoSiguiente
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;

-- 
SELECT 
	CustomerID,
	CAST(OrderDate AS DATE) AS OrderDate,
	SalesOrderID,
	TotalDue,
	SUM(TotalDue) OVER(
	PARTITION BY CustomerID 
	ORDER BY SalesOrderID 
	ROWS UNBOUNDED PRECEDING) AS RunningTotal, -- Esto acumula las ventas desde la primera fila del cliente hasta la actual (acumulado progresivo)
	SUM(TotalDue) OVER(
	PARTITION BY CustomerID 
	ORDER BY SalesOrderID 
	ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS ReverseTotal -- Esto acumula desde la fila actual hasta la �ltima del cliente (acumulado hacia adelante).
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;

--

SELECT	JobTitle,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Rate) OVER (PARTITION BY JobTitle) AS Mediana_Cont, --Valor interpolado (puede devolver algo entre dos filas si el n�mero exacto no existe)
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Rate) OVER (PARTITION BY JobTitle) AS Mediana_Disc  --Valor real que aparece en los datos (nunca inventa valores, toma uno exacto)
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e ON eph.BusinessEntityID = e.BusinessEntityID;

-- con CTE
WITH PercentilesCalculados AS (
SELECT
JobTitle,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Rate) OVER (PARTITION BY JobTitle) AS Mediana_Cont,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Rate) OVER (PARTITION BY JobTitle) AS Mediana_Disc
FROM HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e ON eph.BusinessEntityID = e.BusinessEntityID
)
SELECT DISTINCT JobTitle, Mediana_Cont,Mediana_Disc
FROM PercentilesCalculados