/*
Ejercicio 1 
El área de control de calidad quiere evaluar a las empresas de transporte (Shippers). 
Escribe una consulta que muestre el nombre del transportista (CompanyName), el total de 
pedidos que ha enviado, y dos columnas calculadas:

    PedidosATiempo: Contabiliza cuántos pedidos se enviaron a tiempo (donde ShippedDate es menor o 
    igual a RequiredDate).

    PedidosAtrasados: Contabiliza cuántos pedidos sufrieron retraso (donde ShippedDate es mayor a 
    RequiredDate).

(Pista: Puedes usar SUM(CASE WHEN... THEN 1 ELSE 0 END) para contar bajo ciertas condiciones dentro 
del agrupamiento).
Tablas involucradas: Shippers y Orders.
*/

SELECT s.CompanyName, 
SUM(CASE
WHEN o.ShippedDate is not null THEN 1 ELSE 0
END) as 'Total Pedidos Enviados', 
SUM(CASE
WHEN o.ShippedDate <= o.RequiredDate THEN 1 ELSE 0
END) as 'PedidoATiempo',
SUM(CASE
WHEN o.ShippedDate > o.RequiredDate THEN 1 ELSE 0
END) as 'PedidosAtrasados',
SUM(CASE
WHEN o.ShippedDate is null THEN 1 ELSE 0
END) as 'PedidosAEnviar'
FROM Orders o
inner join Shippers s
on o.ShipVia=s.ShipperID
group by s.CompanyName;

/*
Ejercicio 2 
Finanzas quiere comparar el rendimiento de los empleados entre los años 1996 y 1997.
Crea un primer CTE que calcule el total de ventas por empleado para 1996, y un segundo CTE que calcule lo mismo pero para 1997. Finalmente, en tu consulta principal, cruza la tabla Employees con ambos CTEs para mostrar: El nombre completo del empleado, las ventas del 96 y las ventas del 97.
Tablas involucradas: Employees, Orders, Order Details.
*/

WITH primercte as(
Select e.EmployeeID, (CONCAT(e.LastName,' ',e.FirstName)) as 'Nombre', SUM((od.Quantity*od.UnitPrice)) as 'Total Venta'
from Orders o
inner join Employees e
on o.EmployeeID=e.EmployeeID
inner join [Order Details] od
on o.OrderID=od.OrderID
where o.OrderDate between '1997-01-01' and '1997-12-31'
group by (CONCAT(e.LastName,' ',e.FirstName)), e.EmployeeID

),

segundocte as(
Select e.EmployeeID, (CONCAT(e.LastName,' ',e.FirstName)) as 'Nombre', SUM((od.Quantity*od.UnitPrice)) as 'Total Venta'
from Orders o
inner join Employees e
on o.EmployeeID=e.EmployeeID
inner join [Order Details] od
on o.OrderID=od.OrderID
where o.OrderDate between '1996-01-01' and '1996-12-31'
group by (CONCAT(e.LastName,' ',e.FirstName)), e.EmployeeID
)

select (CONCAT(e.LastName,' ',e.FirstName)) as 'Nombre', p.[Total Venta] as 'TotalVenta1997', s.[Total Venta] as 'TotalVenta1998'
from Employees e
inner join primercte p
on e.EmployeeID=p.EmployeeID
inner join segundocte s
on e.EmployeeID=s.EmployeeID;

/*
Ejercicio 3 
A veces no queremos usar GROUP BY porque necesitamos el detalle de la fila, pero aún así queremos un cálculo agregado al lado. Muestra el ID del pedido (OrderID), la fecha del pedido (OrderDate) y una tercera columna llamada CantidadTotalArticulos que sume la cantidad de productos (Quantity) de ese pedido específico.
Regla: Debes lograr esto haciendo una subconsulta dentro de la misma cláusula SELECT, sin usar ningún JOIN en el bloque principal.
Tablas involucradas: Orders (tabla principal) y Order Details (en la subconsulta).
*/

select o.OrderID, o.OrderDate, (select SUM(od.Quantity) 
                                from [Order Details] od 
                                 where od.OrderID=o.OrderID) as 'CantidadTotalArticulos'
from Orders o

/*
Ejercicio 4
El equipo de ventas internacionales quiere saber qué productos no están teniendo tracción en el mercado estadounidense. Encuentra y muestra el nombre de los productos (ProductName) que nunca han sido comprados por un cliente ubicado en el país 'USA'.
Tablas involucradas: Products, Order Details, Orders y Customers.
*/

SELECT ProductName 
FROM Products 
WHERE ProductID NOT IN (
    -- Esta subconsulta genera la lista negra: Todos los IDs de productos que SÍ se han vendido a USA.
    SELECT od.ProductID 
    FROM [Order Details] od
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE c.Country = 'USA'
);

/*
Ejercicio 5 
Para entender la distribución de nuestro inventario, necesitamos saber qué peso tiene cada categoría. Muestra el nombre de la categoría (CategoryName), la cantidad de productos que tiene esa categoría, y una tercera columna que muestre el porcentaje que representan esos productos sobre el total absoluto de productos en la base de datos (Ejemplo: Si hay 10 productos en 'Beverages' y 100 productos en total, debe resultar en un 10%).
(Pista: Necesitarás multiplicar por 100.0 y dividir entre el recuento total obtenido de una subconsulta independiente).
Tablas involucradas: Categories y Products.
*/

select c.CategoryName,
COUNT(*) as 'cant prod', 
CAST((COUNT(*)*100.00)/(select COUNT(*) from Products) AS DECIMAL(10,2)) as '%Total'
from Products p
inner join Categories c
on p.CategoryID=c.CategoryID
group by c.CategoryName

/*
Ejercicio 6 
La tabla de empleados (Employees) tiene una columna llamada ReportsTo que contiene el ID del jefe de ese empleado. Escribe una consulta que devuelva dos columnas: El nombre completo del empleado (NombreEmpleado) y el nombre completo de su jefe directo (NombreJefe).
Tabla involucrada: Employees (tendrás que hacer un JOIN de la tabla consigo misma).
*/

select CONCAT(e.LastName,' ',e.FirstName) as 'nom emp',e.EmployeeID, 
CONCAT(em.LastName,' ',em.FirstName) as 'nom jefe', em.EmployeeID 
from Employees e
inner join Employees em
on em.EmployeeID=e.ReportsTo
/*
Ejercicio 7 
Recursos Humanos quiere una lista única de contactos. Escribe una consulta que devuelva el nombre de la compañía (CompanyName), el nombre del contacto (ContactName) y una tercera columna estática llamada TipoRelacion que diga 'Cliente' si viene de la tabla de clientes, y 'Proveedor' si viene de la tabla de proveedores.
Tablas involucradas: Customers y Suppliers.
*/

select c.CompanyName , c.ContactName, 'Customers' as 'TipoRelacion'
from Customers c
UNION
select s.CompanyName, s.ContactName, 'Suppliers' as 'TipoRelacion'
from Suppliers s

/*
Ejercicio 8 
El área financiera necesita ver la evolución de los ingresos. Crea un reporte que muestre el Año del pedido, el Mes del pedido, y el total de ingresos generados (UnitPrice * Quantity) en ese mes. Ordena cronológicamente desde el mes más antiguo al más reciente.
Tablas involucradas: Orders y Order Details.
*/

select YEAR(o.OrderDate) as 'Año', MONTH(o.OrderDate) as 'Mes',SUM((od.UnitPrice*od.Quantity)) as 'SUMA Total Ingresos'
from Orders o
inner join [Order Details] od
on o.OrderID=od.OrderID
group by YEAR(o.OrderDate), MONTH(o.OrderDate)
order by Año, Mes

/*
Ejercicio 9
Queremos lanzar una campaña de recuperación de clientes inactivos. Muestra el nombre de la empresa (CompanyName) de aquellos clientes que no realizaron ninguna compra en el año 1998.
Tablas involucradas: Customers y Orders.
*/

SELECT CompanyName 
FROM Customers 
WHERE CustomerID NOT IN (
    SELECT CustomerID FROM Orders WHERE YEAR(OrderDate) = 1998
);

/*
Ejercicio 10 
Las expresiones de tabla comunes (WITH ... AS) son como vistas temporales en tu consulta.
Crea un CTE que calcule el total de ventas (en dinero) por cada CustomerID. Luego, usando ese CTE, escribe una consulta principal que haga un JOIN con la tabla Customers para mostrar el CompanyName y el total de ventas, pero solo para los clientes cuyo total acumulado supere los $50,000.
Tablas involucradas: Customers, Orders, Order Details.
*/

WITH VentasTotales CTE AS (
    SELECT o.CustomerID, SUM(od.UnitPrice * od.Quantity) AS TotalAcumulado
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID
)

SELECT c.CompanyName, v.TotalAcumulado
FROM Customers c
INNER JOIN VentasTotales v ON c.CustomerID = v.CustomerID
WHERE v.TotalAcumulado > 50000;