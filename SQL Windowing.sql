-- Una funci�n Window es una funci�n que se aplica a un conjunto de filas. Window es el-- t�rmino que usa el est�ndar SQL para describir el contexto en el que opera la funci�n. SQL usa-- una cl�usula llamada OVER en la que se proporciona la especificaci�n de la ventana.

-- OVER con ORDER BY- ROW_NUMBER()

SELECT 
	CustomerID, 
	SalesOrderID,
	ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber
FROM Sales.SalesOrderHeader;

-- OVER con PARTITION BY

SELECT CustomerID, SalesOrderID,
ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
AS RowNumber
FROM Sales.SalesOrderHeader;

--
SELECT DISTINCT OrderDate,
ROW_NUMBER() OVER(ORDER BY OrderDate) AS RowNumber
FROM Sales.SalesOrderHeader
ORDER BY RowNumber;


--Ejercicio : A partir del problema anterior con el distinct se pide;
-- � Resolver el problema para que me queden numeradas las ordenes de fechas
-- distintas (es decir un numero por fecha sin repetir fechas.
-- � Obtener la a segunda fecha m�s antigua.

WITH FechasUnicas AS (
    SELECT DISTINCT OrderDate
    FROM Sales.SalesOrderHeader
)
SELECT 
    OrderDate,
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber
FROM FechasUnicas;

-------- 
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
SELECT OrderDate AS SegundaFechaMasAntigua
FROM FechasNumeradas
WHERE RowNumber = 2;


-- Ranking Functions, seguir