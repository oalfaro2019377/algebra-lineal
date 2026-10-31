-- ============================================================
-- Datos de prueba - Tienda en Línea "TecnoModa GT"
--
-- Diseño intencional de los datos para que los conjuntos
-- resultantes sean claros y no triviales:
--   Clientes 1-6   -> solo compran Electrónica          (A - B)
--   Clientes 7-12  -> solo compran Ropa                 (B - A)
--   Clientes 13-17 -> compran Electrónica Y Ropa         (A ∩ B)
--   Clientes 18-20 -> solo compran Hogar (fuera de A ∪ B)
-- ============================================================

-- Categorías
INSERT INTO categorias (categoria_id, nombre) VALUES
(1, 'Electrónica'),
(2, 'Ropa'),
(3, 'Hogar');

-- Clientes
INSERT INTO clientes (cliente_id, nombre, email, ciudad, fecha_registro) VALUES
(1,  'Juan Pérez',       'juan.perez@mail.com',       'Guatemala',       '2025-01-10'),
(2,  'María López',      'maria.lopez@mail.com',      'Antigua',         '2025-01-12'),
(3,  'Carlos Méndez',    'carlos.mendez@mail.com',    'Guatemala',       '2025-01-15'),
(4,  'Ana Gómez',        'ana.gomez@mail.com',        'Mixco',           '2025-01-18'),
(5,  'Luis Ramírez',     'luis.ramirez@mail.com',     'Guatemala',       '2025-01-20'),
(6,  'Sofía Castillo',   'sofia.castillo@mail.com',   'Quetzaltenango',  '2025-01-22'),
(7,  'Pedro Herrera',    'pedro.herrera@mail.com',    'Guatemala',       '2025-02-01'),
(8,  'Lucía Torres',     'lucia.torres@mail.com',     'Escuintla',       '2025-02-03'),
(9,  'Diego Morales',    'diego.morales@mail.com',    'Guatemala',       '2025-02-05'),
(10, 'Valeria Cruz',     'valeria.cruz@mail.com',     'Antigua',         '2025-02-08'),
(11, 'Andrés Fuentes',   'andres.fuentes@mail.com',   'Guatemala',       '2025-02-10'),
(12, 'Camila Rodríguez', 'camila.rodriguez@mail.com', 'Mixco',           '2025-02-12'),
(13, 'Daniela Ortiz',    'daniela.ortiz@mail.com',    'Guatemala',       '2025-03-01'),
(14, 'Roberto Jiménez',  'roberto.jimenez@mail.com',  'Villa Nueva',     '2025-03-03'),
(15, 'Patricia Vásquez', 'patricia.vasquez@mail.com', 'Guatemala',       '2025-03-05'),
(16, 'Fernando Castro',  'fernando.castro@mail.com',  'Amatitlán',       '2025-03-08'),
(17, 'Gabriela Soto',    'gabriela.soto@mail.com',    'Guatemala',       '2025-03-10'),
(18, 'Mariana Luna',     'mariana.luna@mail.com',     'Guatemala',       '2025-04-01'),
(19, 'Jorge Paredes',    'jorge.paredes@mail.com',    'Antigua',         '2025-04-03'),
(20, 'Isabel Rojas',     'isabel.rojas@mail.com',     'Mixco',           '2025-04-05');

-- Productos
-- Electrónica (categoria_id = 1)
INSERT INTO productos (producto_id, nombre, categoria_id, precio) VALUES
(1, 'Audífonos Bluetooth',  1, 250.00),
(2, 'Smartwatch',           1, 650.00),
(3, 'Cargador Rápido',      1, 120.00),
(4, 'Mouse Inalámbrico',    1,  90.00),
(5, 'Parlante Portátil',    1, 310.00),
(6, 'Teclado Mecánico',     1, 380.00);

-- Ropa (categoria_id = 2)
INSERT INTO productos (producto_id, nombre, categoria_id, precio) VALUES
(7,  'Camisa Casual',       2, 180.00),
(8,  'Pantalón Jeans',      2, 220.00),
(9,  'Chaqueta de Cuero',   2, 450.00),
(10, 'Vestido Elegante',    2, 380.00),
(11, 'Tenis Urbanos',       2, 420.00),
(12, 'Gorra Deportiva',     2,  90.00);

-- Hogar (categoria_id = 3)
INSERT INTO productos (producto_id, nombre, categoria_id, precio) VALUES
(13, 'Lámpara LED',             3, 150.00),
(14, 'Set de Toallas',          3, 130.00),
(15, 'Organizador Multiusos',   3,  95.00);

-- Cupones (para el ejemplo de Producto Cartesiano)
INSERT INTO cupones (cupon_id, codigo, descripcion) VALUES
(1, 'DESC10',      '10% de descuento en la próxima compra'),
(2, 'DESC20-ELEC', '20% de descuento en categoría Electrónica'),
(3, 'ENVIOGRATIS',  'Envío gratis en el siguiente pedido'),
(4, 'REGALO2X1',    'Promoción 2x1 en accesorios seleccionados');

-- Pedidos
INSERT INTO pedidos (pedido_id, cliente_id, fecha_pedido) VALUES
(1,  1,  '2025-05-02'),
(2,  2,  '2025-05-03'),
(3,  3,  '2025-05-04'),
(4,  4,  '2025-05-05'),
(5,  5,  '2025-05-06'),
(6,  6,  '2025-05-07'),
(7,  7,  '2025-05-08'),
(8,  8,  '2025-05-09'),
(9,  9,  '2025-05-10'),
(10, 10, '2025-05-11'),
(11, 11, '2025-05-12'),
(12, 12, '2025-05-13'),
(13, 13, '2025-05-14'),
(14, 13, '2025-05-20'),
(15, 14, '2025-05-15'),
(16, 14, '2025-05-21'),
(17, 15, '2025-05-16'),
(18, 15, '2025-05-22'),
(19, 16, '2025-05-17'),
(20, 16, '2025-05-23'),
(21, 17, '2025-05-18'),
(22, 17, '2025-05-24'),
(23, 18, '2025-06-01'),
(24, 19, '2025-06-02'),
(25, 20, '2025-06-03');

-- Detalle de pedidos
-- Clientes 1-6: solo Electrónica
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 2, 1, 650.00), (1, 1, 1, 250.00),                      -- Juan Pérez       -> 900.00
(2, 6, 1, 380.00), (2, 4, 1,  90.00),                      -- María López      -> 470.00
(3, 2, 2, 650.00), (3, 3, 1, 120.00),                      -- Carlos Méndez    -> 1420.00
(4, 5, 1, 310.00), (4, 1, 1, 250.00),                      -- Ana Gómez        -> 560.00
(5, 2, 1, 650.00), (5, 6, 1, 380.00), (5, 5, 1, 310.00),   -- Luis Ramírez     -> 1340.00
(6, 2, 2, 650.00), (6, 4, 1,  90.00), (6, 3, 1, 120.00);   -- Sofía Castillo   -> 1510.00 (VIP)

-- Clientes 7-12: solo Ropa
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(7,  7, 1, 180.00), (7,  8, 1, 220.00),                    -- Pedro Herrera    -> 400.00
(8,  9, 1, 450.00), (8, 11, 1, 420.00),                    -- Lucía Torres     -> 870.00
(9, 10, 1, 380.00), (9, 12, 1,  90.00),                    -- Diego Morales    -> 470.00
(10, 9, 1, 450.00), (10, 8, 1, 220.00), (10, 7, 1, 180.00),-- Valeria Cruz     -> 850.00
(11,11, 2, 420.00), (11, 9, 1, 450.00),                    -- Andrés Fuentes   -> 1290.00
(12, 9, 2, 450.00), (12,11, 1, 420.00), (12,10, 1, 380.00);-- Camila Rodríguez -> 1700.00 (VIP)

-- Clientes 13-17: Electrónica Y Ropa (pedido separado por categoría)
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(13, 1, 1, 250.00),                                         -- Daniela Ortiz (Electrónica) -> 250.00
(14, 10, 1, 380.00),                                         -- Daniela Ortiz (Ropa)        -> 380.00  => total 630.00
(15, 2, 1, 650.00),                                           -- Roberto Jiménez (Electrónica) -> 650.00
(16, 9, 1, 450.00),                                           -- Roberto Jiménez (Ropa)        -> 450.00 => total 1100.00
(17, 6, 1, 380.00), (17, 4, 1, 90.00),                         -- Patricia Vásquez (Electrónica) -> 470.00
(18, 11, 1, 420.00), (18, 7, 1, 180.00),                       -- Patricia Vásquez (Ropa)        -> 600.00 => total 1070.00
(19, 5, 1, 310.00),                                            -- Fernando Castro (Electrónica) -> 310.00
(20, 8, 1, 220.00),                                            -- Fernando Castro (Ropa)        -> 220.00 => total 530.00
(21, 2, 1, 650.00), (21, 3, 1, 120.00),                        -- Gabriela Soto (Electrónica) -> 770.00
(22, 9, 1, 450.00), (22, 12, 1, 90.00), (22, 11, 1, 420.00);   -- Gabriela Soto (Ropa)        -> 960.00 => total 1730.00 (VIP)

-- Clientes 18-20: solo Hogar (fuera de A ∪ B)
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(23, 13, 1, 150.00), (23, 14, 1, 130.00),                      -- Mariana Luna  -> 280.00
(24, 15, 1,  95.00), (24, 13, 1, 150.00),                      -- Jorge Paredes -> 245.00
(25, 14, 1, 130.00), (25, 15, 1,  95.00), (25, 13, 1, 150.00); -- Isabel Rojas  -> 375.00
