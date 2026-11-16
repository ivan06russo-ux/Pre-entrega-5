USE Ventas_Tech_DB

--CONSULTA 1 Vista base del proyecto (INNER JOIN)

SELECT
v.fecha_venta,
c.nombre,
c.ciudad,
p.nombre_producto,
cat.nombre_categoria,
v.cantidad,
v.precio_unitario,
(v.cantidad * p.precio) AS total_venta
FROM dbo.Ventas AS v
INNER JOIN dbo.Clientes AS c
ON v.id_cliente = c.id_clientes
INNER JOIN Productos p
ON v.id_producto = p.id_producto
INNER JOIN Categoria cat
ON p.id_categoria = cat.id_categoria

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.

SELECT
c.nombre,
c.email,
c.fecha_registro
FROM Clientes c
LEFT JOIN Ventas v
ON c.id_clientes = v.id_cliente
WHERE v.id_cliente IS NULL

--CONSULTA 3: Productos sin ventas 

SELECT
p.nombre_producto,
c.nombre_categoria,
p.precio
FROM Productos p
LEFT JOIN Ventas v
ON v.id_producto = p.id_producto
INNER JOIN Categoria c
ON p.id_categoria = c.id_categoria
WHERE v.id_producto IS NULL

-- Consulta 4: Consolidado por segmento de compra (UNION ALL)
-- Propósito: comparar los ingresos generados por compras minoristas frente a compras por volumen (mayoristas) para definir estrategias comerciales.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Minorista' AS canal
    FROM ventas WHERE cantidad < 3
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Mayorista' AS canal
    FROM ventas WHERE cantidad >= 3
) AS consolidado
GROUP BY canal;

-- Hallazgo: El canal minorista concentra la mayor parte de los ingresos con $5.310,00 (82,4% del total), superando ampliamente al segmento mayorista que facturó $1.134,00




-- Consulta 4: Consolidado por período de venta (UNION ALL)
-- Propósito: comparar la facturación entre la primer y segunda semana de la primera quincena para evaluar la evolución de las ventas y detectar picos de demanda.


SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'primeros 5 dias' AS canal
    FROM ventas WHERE fecha_venta < '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'ultimos 5 dias' AS canal
    FROM ventas WHERE fecha_venta >= '2024-03-10'
) AS consolidado
GROUP BY canal;



-- Hallazgo: La facturación se mantuvo prácticamente equilibrada entre ambos períodos, con una leve ventaja de los primeros 5 días ($3.230,00) frente a los últimos 5 días ($3.214,00), lo que demuestra una demanda estable