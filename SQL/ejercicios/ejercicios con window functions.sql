/*
Ejercicio 1 
El Ranking por Categoría (ROW_NUMBER + PARTITION BY)
Queremos saber cuáles son los productos más caros dentro de cada categoría de forma independiente.
Escribe una consulta (usando un CTE) que primero le asigne un número de fila a cada producto particionando por Categoría y ordenando por Precio de mayor a menor. Luego, en la consulta principal, filtra para mostrar solo los 2 productos más caros de cada categoría.
Debes mostrar: CategoryName, ProductName, UnitPrice y el ranking generado.
Tablas involucradas: Products y Categories.
*/

WITH RankingProductos AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        p.UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY c.CategoryName ORDER BY p.UnitPrice DESC) AS Ranking
    FROM Products p
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
)
SELECT CategoryName, ProductName, UnitPrice, Ranking
FROM RankingProductos
WHERE Ranking <= 2;

/*
Ejercicio 2 
El Total Acumulado Financiero (SUM + OVER ORDER BY)
Finanzas quiere ver cómo van creciendo los costos de envío a medida que pasan los días.
Muestra el OrderID, la fecha OrderDate, el costo del flete Freight, y una cuarta columna llamada CostoAcumulado que vaya sumando el flete fila por fila, ordenado cronológicamente por la fecha del pedido.
Tabla involucrada: Orders.
*/

SELECT 
    OrderID,
    OrderDate,
    Freight,
    SUM(Freight) OVER(ORDER BY OrderDate, OrderID) AS CostoAcumulado
FROM Orders;

/*
Ejercicio 3 
Tiempo entre Compras (LAG + PARTITION BY)
El equipo de retención de clientes quiere saber cada cuántos días nos compra un cliente.
Crea una consulta que muestre el CustomerID, el OrderID, el OrderDate, y una columna que muestre la fecha del pedido inmediatamente anterior de ese mismo cliente. Llama a esta columna FechaPedidoAnterior.
(Pista: La función LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) extrae el valor de la fila anterior basada en tu partición).
Tabla involucrada: Orders.
*/

SELECT 
    CustomerID,
    OrderID,
    OrderDate,
    LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS FechaPedidoAnterior
FROM Orders;

/*
Ejercicio 4
Para entender la distribución de nuestro inventario, necesitamos saber qué peso tiene cada categoría. 
Muestra el nombre de la categoría (CategoryName), la cantidad de productos que tiene esa categoría, 
y una tercera columna que muestre el porcentaje que representan esos productos sobre el total absoluto 
de productos en la base de datos (Ejemplo: Si hay 10 productos en 'Beverages' y 100 productos en total, 
debe resultar en un 10%).
(Pista: Necesitarás multiplicar por 100.0 y dividir entre el recuento total obtenido de una subconsulta 
independiente).
Tablas involucradas: Categories y Products.
*/

SELECT 
    c.CategoryName,
    COUNT(p.ProductID) AS 'cant prod',
    CAST(
        (COUNT(p.ProductID) * 100.0) / SUM(COUNT(p.ProductID)) OVER() 
        AS DECIMAL(10,2)
    ) AS '%Total'
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName;

/*
Ejercicio 5 
Premiando el Rendimiento (DENSE_RANK)
Vamos a rankear a los empleados según la cantidad de pedidos distintos que han gestionado.
Muestra el nombre completo del empleado y la cantidad de pedidos que ha procesado (COUNT(OrderID)). En una tercera columna, asígnales un ranking utilizando DENSE_RANK() ordenado por la cantidad de pedidos de mayor a menor.
(Nota: Usa DENSE_RANK() en lugar de RANK(), así si dos empleados empatan en el puesto 2, el siguiente empleado será el número 3 y no el 4).
Tablas involucradas: Employees y Orders.
*/

SELECT 
    CONCAT(e.LastName, ' ', e.FirstName) AS NombreCompleto,
    COUNT(o.OrderID) AS CantidadPedidos,
    DENSE_RANK() OVER(ORDER BY COUNT(o.OrderID) DESC) AS RankingPedidos
FROM Employees e
INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.LastName, e.FirstName;