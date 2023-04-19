USE game;

-- Consulta 1. Haz un listado de los empleados que trabajan en la tienda de Tomares.
SELECT e.*
FROM empleado e
INNER JOIN tienda t ON e.codigo_tienda = t.codigo
WHERE t.ciudad = 'Tomares';

-- Consulta 2. Devuelve un listado que muestre los productos que la cantidad en la tienda sea igual a 50
-- y el fabricante sea Nintendo.
SELECT pr.codigo, pr.nombre AS 'Nombre Producto', f.nombre AS 'Nombre Fabricante', pt.cantidad 
FROM producto pr 
  LEFT JOIN producto_tienda pt ON pr.codigo = pt.codigo_producto 
  LEFT JOIN fabricante f ON pr.codigo_fabricante = f.codigo 
WHERE pt.cantidad = 50 
  AND f.nombre = 'Nintendo';

-- Consulta 3. Devuelve todos los productos del fabricante Electronic Arts.
SELECT pr.* FROM producto pr 
WHERE pr.codigo_fabricante = 
  (SELECT f.codigo FROM fabricante f 
  WHERE f.nombre = 'Electronic Arts');

-- Consulta 4. Devuelve todos los datos de los productos que tienen el mismo precio
-- que el producto más caro del fabricante Electronic Arts.
SELECT * FROM producto pr 
  WHERE pr.precio = 
  (SELECT max(pr.precio) FROM producto pr WHERE pr.codigo_fabricante = 
  (SELECT f.codigo FROM fabricante f WHERE f.nombre = 'Electronic Arts'));

-- Consulta 5. Devuelve un listado con el nombre del producto más caro que tiene cada fabricante en orden ascendente.
SELECT pr.nombre, pr.precio, f.nombre 
FROM producto pr 
  INNER JOIN fabricante f ON pr.codigo_fabricante = f.codigo 
  WHERE pr.precio =
  (SELECT max(pr.precio) FROM producto pr WHERE pr.codigo_fabricante = f.codigo) 
ORDER BY f.nombre ASC;

-- Vista 1. Vista del listado de empleados de la tienda de Tomares.
CREATE VIEW listado_empleado AS
SELECT e.*
FROM empleado e
  INNER JOIN tienda t ON e.codigo_tienda = t.codigo
WHERE t.ciudad = 'Tomares';

SELECT * FROM listado_empleado;

-- Vista 2. Vista del listado de los productos mas caros de cada fabricante.
CREATE VIEW listado_productos_caros_fabricante AS
SELECT pr.nombre AS 'Producto', pr.precio, f.nombre AS 'Fabricante' 
FROM producto pr 
  INNER JOIN fabricante f ON pr.codigo_fabricante = f.codigo 
  WHERE pr.precio =
  (SELECT max(pr.precio) FROM producto pr WHERE pr.codigo_fabricante = f.codigo) 
ORDER BY f.nombre ASC;

SELECT * FROM listado_productos_caros_fabricante;

-- Procedimiento 1. Procedimiento que reciba los datos de una ciudad y muestre los clientes de dicha ciudad. 
DROP PROCEDURE IF EXISTS mostrar_cliente;
DELIMITER $$
CREATE PROCEDURE mostrar_cliente(p_ciudad varchar(50))
BEGIN
	SELECT * FROM cliente c
	WHERE c.ciudad = p_ciudad;
END $$
DELIMITER ;

CALL mostrar_cliente('Bollullos de la Mitación');

-- Procedimiento 2. Procedimiento que muestre el detalle de un pedido.
DROP PROCEDURE IF EXISTS detalle_pedido;
DELIMITER $$
CREATE PROCEDURE detalle_pedido(c_pedido int)
BEGIN 
	SELECT p.codigo, pr.nombre, pr.precio, pp.cantidad, (pr.precio * pp.cantidad) 
	FROM producto_pedido pp 
	INNER JOIN pedido p 
	INNER JOIN producto pr
	WHERE pp.codigo_pedido = c_pedido;
END $$
DELIMITER ;

CALL detalle_pedido(1);

-- Función 1. Función que muestre el producto más caro y el más barato que la media.
DROP FUNCTION IF EXISTS media_producto;
DELIMITER $$
CREATE FUNCTION media_producto(codigo_producto varchar(15))
RETURNS varchar(100)
BEGIN
	DECLARE precio_actual NUMERIC(15, 2);
	DECLARE precio_medio NUMERIC(15, 2);

	SELECT pr.precio 
		INTO precio_actual 
	FROM producto pr 
	WHERE pr.codigo = codigo_producto;

	SELECT AVG(pr.precio) 
		INTO precio_medio
	FROM producto pr;

	IF precio_actual > precio_medio THEN 
		RETURN CONCAT('Precio Actual: ', precio_actual, ' - PRODUCTO MÁS CARO QUE LA MEDIA');
	ELSE 
		RETURN CONCAT('Precio Actual: ', precio_actual, ' - PRODUCTO MÁS BARATO QUE LA MEDIA');
	END IF;
END $$
DELIMITER ;
SELECT media_producto(1);