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

-- Procedimiento 2. Procedimiento que muestre el pedido de un cliente.
DROP PROCEDURE IF EXISTS detalle_pedido;
DELIMITER $$
CREATE PROCEDURE detalle_pedido(c_pedido int)
BEGIN 
	SELECT p.codigo, c.codigo, c.nif, CONCAT(c.nombre, c.apellido1, c.apellido2), total_producto_pedido(c_pedido) 
	FROM pedido p 
	INNER JOIN cliente c ON p.codigo_cliente = c.codigo
	INNER JOIN producto_pedido pp ON p.codigo = pp.codigo_pedido
	WHERE p.codigo = c_pedido;
END $$
DELIMITER ;

CALL detalle_pedido(7);

-- Procedimiento 3. Muestra las estadisticas de las tienda y los pedidos.
delimiter &&
DROP PROCEDURE IF EXISTS mostrar_estadisticas&&
CREATE PROCEDURE mostrar_estadisticas()
BEGIN
  DECLARE salida varchar(10000) DEFAULT '========ESTADISTICAS=======\n-----------Totales-------\nCantidades Totales: ';
  DECLARE total decimal(15,2);
  DECLARE done bool DEFAULT FALSE;
  DECLARE tienda integer;
  DECLARE n integer DEFAULT 1;
  DECLARE pedido varchar(20) DEFAULT '';
  -- CURSOR DE TIENDAS
  DECLARE c1 CURSOR FOR
             SELECT t.codigo, sum(pr.precio * pt.cantidad)
             FROM producto_tienda pt
             INNER JOIN tienda t ON pt.codigo_tienda = t.codigo
             INNER JOIN producto pr ON pt.codigo_producto = pr.codigo
             GROUP BY t.codigo;

  -- CURSOR DE PEDIDOS
  DECLARE c2 CURSOR FOR 
			SELECT p.codigo, pr.nombre, sum(pp.cantidad * pr.precio) 
			FROM producto_pedido pp
            INNER JOIN pedido p ON pp.codigo_pedido = p.codigo
            INNER JOIN producto pr ON pp.codigo_producto = pr.codigo
			GROUP BY p.codigo;
			ORDER BY pr.nombre;
  -- para salir del bucle del cursor
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  SELECT sum(pr.precio * pt.cantidad) into total
  FROM producto_tienda pt
  set salida=concat(salida,total,'€\n');
  -- recorremos el cursor de tiendas
  OPEN c1;
  WHILE (NOT done) do
    FETCH c1 INTO tienda, total;
    IF (NOT done) THEN
         set salida=concat(salida,'En ',tienda,': ',total,'€\n');
    END IF;
  END WHILE;
  CLOSE c1;
 -- SET n=1; --
  OPEN c2;
  set salida = concat(salida, '==========LISTADOS=======\n');
  set salida = concat(salida, '-----Valor de las pedidos-----\n');
  set done = FALSE;
  WHILE (NOT done) do
    FETCH c2 INTO pedido, total;
    IF (NOT done) THEN
         set salida=concat(salida, pedido, ': ', total, '€\n');
    END IF;
  END WHILE;
  CLOSE c2;
  SELECT salida;
END &&
  
delimiter ;

CALL mostrar_estadisticas();

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
SELECT media_producto(3);

-- Función 2. Función que muestre el total de un pedido.
DROP FUNCTION IF EXISTS total_producto_pedido;
DELIMITER $$
CREATE FUNCTION total_producto_pedido(pp_id int)
RETURNS varchar(50)
DETERMINISTIC
BEGIN
    DECLARE total varchar(50) DEFAULT '';
    SELECT CONCAT('El total del pedido ', pp_id, ' es ', pr.precio * pp.cantidad)
    INTO total
    FROM producto_pedido pp
    INNER JOIN producto pr ON pp.codigo_producto = pr.codigo
    WHERE pp.codigo_producto = pp_id;
    
    IF (total IS NULL) THEN 
        SET total = 'El producto no está en el pedido';
    END IF;
    
    RETURN total;
END $$
DELIMITER ;

SELECT total_producto_pedido(21);

-- Trigger 1. Crear el trigger "trigger_insertar_tienda"
DELIMITER $$
CREATE TRIGGER trigger_insertar_tienda
BEFORE UPDATE ON empleado
FOR EACH ROW
BEGIN
  IF NEW.codigo <> OLD.codigo THEN
    INSERT INTO tienda (codigo, ciudad, direccion)
    VALUES (NEW.codigo, 'Alcalá de Guadaíra', 'A-92, 41500 Alcalá de Guadaíra, Sevilla');
  END IF;
END$$
DELIMITER ;

SELECT t.* FROM tienda t;

-- Trigger 2. Crear el trigger "trigger_update_empleado"
DELIMITER $$
CREATE TRIGGER trigger_update_empleado
AFTER INSERT ON tienda
FOR EACH ROW
BEGIN
  UPDATE empleado e
  SET e.codigo_tienda = NEW.codigo_tienda;
END$$
DELIMITER ;

UPDATE empleado SET NEW.codigo_tienda = 6 WHERE e.codigo = 5;
UPDATE empleado SET NEW.codigo_tienda = 7 WHERE e.codigo = 7;
UPDATE empleado SET NEW.codigo_tienda = 5 WHERE e.codigo = 6;

SELECT * FROM empleado e;