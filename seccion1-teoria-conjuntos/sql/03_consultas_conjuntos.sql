-- ============================================================
-- Sección 1 - Teoría de Conjuntos aplicada a la Tienda en Línea
--
-- Conjunto A = Clientes que compraron en la categoría "Electrónica"
-- Conjunto B = Clientes que compraron en la categoría "Ropa"
--
-- Cada operación de conjuntos se resuelve con el operador nativo
-- de PostgreSQL que le corresponde: UNION, INTERSECT, EXCEPT y
-- CROSS JOIN (producto cartesiano).
-- ============================================================

-- ------------------------------------------------------------
-- Vistas base: definen los conjuntos A y B y el universo VIP
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_clientes_electronica AS   -- Conjunto A
SELECT DISTINCT c.cliente_id, c.nombre
FROM clientes c
JOIN pedidos p        ON p.cliente_id = c.cliente_id
JOIN detalle_pedido dp ON dp.pedido_id = p.pedido_id
JOIN productos pr      ON pr.producto_id = dp.producto_id
JOIN categorias cat    ON cat.categoria_id = pr.categoria_id
WHERE cat.nombre = 'Electrónica';

CREATE OR REPLACE VIEW v_clientes_ropa AS          -- Conjunto B
SELECT DISTINCT c.cliente_id, c.nombre
FROM clientes c
JOIN pedidos p        ON p.cliente_id = c.cliente_id
JOIN detalle_pedido dp ON dp.pedido_id = p.pedido_id
JOIN productos pr      ON pr.producto_id = dp.producto_id
JOIN categorias cat    ON cat.categoria_id = pr.categoria_id
WHERE cat.nombre = 'Ropa';

CREATE OR REPLACE VIEW v_clientes_vip AS            -- Conjunto usado en el producto cartesiano
SELECT c.cliente_id, c.nombre, SUM(dp.cantidad * dp.precio_unitario) AS gasto_total
FROM clientes c
JOIN pedidos p        ON p.cliente_id = c.cliente_id
JOIN detalle_pedido dp ON dp.pedido_id = p.pedido_id
GROUP BY c.cliente_id, c.nombre
HAVING SUM(dp.cantidad * dp.precio_unitario) > 1500
ORDER BY gasto_total DESC;

-- ============================================================
-- 1) UNIÓN  (A ∪ B)
-- Clientes que compraron Electrónica O Ropa (o ambas).
-- Uso de negocio: público objetivo de una campaña general.
-- ============================================================
SELECT cliente_id, nombre FROM v_clientes_electronica
UNION
SELECT cliente_id, nombre FROM v_clientes_ropa
ORDER BY cliente_id;

-- ============================================================
-- 2) INTERSECCIÓN  (A ∩ B)
-- Clientes que compraron Electrónica Y Ropa (en ambas categorías).
-- Uso de negocio: candidatos al programa "Cliente Cross-Category VIP".
-- ============================================================
SELECT cliente_id, nombre FROM v_clientes_electronica
INTERSECT
SELECT cliente_id, nombre FROM v_clientes_ropa
ORDER BY cliente_id;

-- ============================================================
-- 3) DIFERENCIA  (A - B)
-- Clientes que compraron Electrónica pero NUNCA Ropa.
-- Uso de negocio: segmento para cross-selling de Ropa.
-- ============================================================
SELECT cliente_id, nombre FROM v_clientes_electronica
EXCEPT
SELECT cliente_id, nombre FROM v_clientes_ropa
ORDER BY cliente_id;

-- 3b) DIFERENCIA  (B - A)  -- la diferencia no es conmutativa
-- Clientes que compraron Ropa pero NUNCA Electrónica.
SELECT cliente_id, nombre FROM v_clientes_ropa
EXCEPT
SELECT cliente_id, nombre FROM v_clientes_electronica
ORDER BY cliente_id;

-- ============================================================
-- 4) DIFERENCIA SIMÉTRICA  (A Δ B) = (A - B) ∪ (B - A)
-- Clientes "mono-categoría": compraron solo una de las dos
-- categorías, nunca ambas.
-- Uso de negocio: segmento a incentivar para diversificar su compra.
-- ============================================================
(SELECT cliente_id, nombre FROM v_clientes_electronica
 EXCEPT
 SELECT cliente_id, nombre FROM v_clientes_ropa)
UNION
(SELECT cliente_id, nombre FROM v_clientes_ropa
 EXCEPT
 SELECT cliente_id, nombre FROM v_clientes_electronica)
ORDER BY cliente_id;

-- ============================================================
-- 5) PRODUCTO CARTESIANO  (VIP × Cupones)
-- Conjunto VIP = clientes con gasto total > Q1,500.00
-- Conjunto Cupones = cupones de descuento activos
-- Genera TODAS las combinaciones posibles cliente-cupón, insumo
-- para la campaña de asignación personalizada de cupones.
-- |VIP x Cupones| = |VIP| * |Cupones|
-- ============================================================
SELECT v.cliente_id, v.nombre, v.gasto_total, cu.codigo, cu.descripcion
FROM v_clientes_vip v
CROSS JOIN cupones cu
ORDER BY v.cliente_id, cu.cupon_id;

-- ------------------------------------------------------------
-- Resumen de cardinalidades (para el dashboard / diagrama de Venn)
-- ------------------------------------------------------------
SELECT
  (SELECT COUNT(*) FROM clientes)                                              AS total_clientes,
  (SELECT COUNT(*) FROM v_clientes_electronica)                                AS total_A_electronica,
  (SELECT COUNT(*) FROM v_clientes_ropa)                                       AS total_B_ropa,
  (SELECT COUNT(*) FROM (SELECT cliente_id FROM v_clientes_electronica
                          INTERSECT
                          SELECT cliente_id FROM v_clientes_ropa) t)           AS total_interseccion,
  (SELECT COUNT(*) FROM (SELECT cliente_id FROM v_clientes_electronica
                          UNION
                          SELECT cliente_id FROM v_clientes_ropa) t)           AS total_union,
  (SELECT COUNT(*) FROM (SELECT cliente_id FROM v_clientes_electronica
                          EXCEPT
                          SELECT cliente_id FROM v_clientes_ropa) t)           AS total_diferencia_A_B,
  (SELECT COUNT(*) FROM (SELECT cliente_id FROM v_clientes_ropa
                          EXCEPT
                          SELECT cliente_id FROM v_clientes_electronica) t)    AS total_diferencia_B_A,
  (SELECT COUNT(*) FROM v_clientes_vip)                                       AS total_vip,
  (SELECT COUNT(*) FROM cupones)                                              AS total_cupones,
  (SELECT COUNT(*) FROM v_clientes_vip) * (SELECT COUNT(*) FROM cupones)      AS total_producto_cartesiano;
