DROP DATABASE IF EXISTS game;
CREATE DATABASE game CHARACTER SET utf8mb4;
USE game;

CREATE TABLE tienda (
  codigo INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ciudad VARCHAR(100) NOT NULL,
  direccion VARCHAR(100) NOT NULL
);

CREATE TABLE empleado (
  codigo INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nif VARCHAR(9) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  apellido1 VARCHAR(100) NOT NULL,
  apellido2 VARCHAR(100),
  codigo_tienda INT UNSIGNED,
  FOREIGN KEY (codigo_tienda) REFERENCES tienda(codigo)
);

CREATE TABLE fabricante (
  codigo INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL
);

CREATE TABLE producto (
  codigo INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  edad_min VARCHAR(2),
  precio DECIMAL NOT NULL,
  puntos_game INT(30),
  codigo_fabricante INT UNSIGNED NOT NULL,
  FOREIGN KEY (codigo_fabricante) REFERENCES fabricante(codigo)
);

CREATE TABLE cliente (
  codigo INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nif VARCHAR(9) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  apellido1 VARCHAR(100) NOT NULL,
  apellido2 VARCHAR(100),
  ciudad VARCHAR(100) NOT NULL,
  domicilio VARCHAR(100) NOT NULL,
  fecha_nac DATE NOT NULL,
  vip BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE pedido (
  codigo INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  codigo_cliente INT UNSIGNED NOT NULL,
  codigo_tienda INT UNSIGNED NOT NULL,
  FOREIGN KEY (codigo_cliente) REFERENCES cliente(codigo),
  FOREIGN KEY (codigo_tienda) REFERENCES tienda(codigo)
);

DROP TABLE IF EXISTS producto_tienda;
CREATE TABLE producto_tienda (
  codigo_producto INT UNSIGNED,
  codigo_tienda INT UNSIGNED,
  cantidad INT(4),
  PRIMARY KEY (codigo_producto, codigo_tienda),
  FOREIGN KEY (codigo_producto) REFERENCES producto(codigo),
  FOREIGN KEY (codigo_tienda) REFERENCES tienda(codigo)
);

DROP TABLE IF EXISTS producto_pedido;
CREATE TABLE producto_pedido (
  codigo_producto INT UNSIGNED NOT NULL,
  codigo_pedido INT UNSIGNED NOT NULL,
  cantidad INT(3),
  PRIMARY KEY (codigo_producto, codigo_pedido),
  FOREIGN KEY (codigo_producto) REFERENCES producto(codigo),
  FOREIGN KEY (codigo_pedido) REFERENCES pedido(codigo)
);
