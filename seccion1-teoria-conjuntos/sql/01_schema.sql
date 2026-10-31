-- ============================================================
-- Sección 1 - Teoría de Conjuntos
-- Escenario: Tienda en Línea "TecnoModa GT"
-- Base de datos: tienda_online
-- ============================================================

DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS cupones CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;

CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre       VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE clientes (
    cliente_id     SERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,
    ciudad         VARCHAR(50),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE productos (
    producto_id  SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria_id INT NOT NULL REFERENCES categorias(categoria_id),
    precio       NUMERIC(10,2) NOT NULL CHECK (precio > 0)
);

CREATE TABLE cupones (
    cupon_id    SERIAL PRIMARY KEY,
    codigo      VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(120) NOT NULL
);

CREATE TABLE pedidos (
    pedido_id    SERIAL PRIMARY KEY,
    cliente_id   INT NOT NULL REFERENCES clientes(cliente_id),
    fecha_pedido DATE NOT NULL
);

CREATE TABLE detalle_pedido (
    detalle_id      SERIAL PRIMARY KEY,
    pedido_id       INT NOT NULL REFERENCES pedidos(pedido_id),
    producto_id     INT NOT NULL REFERENCES productos(producto_id),
    cantidad        INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL
);

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_detalle_pedido ON detalle_pedido(pedido_id);
CREATE INDEX idx_detalle_producto ON detalle_pedido(producto_id);
