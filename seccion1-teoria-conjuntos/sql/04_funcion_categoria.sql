-- ============================================================
-- Función SQL parametrizada: dado el nombre de una categoría,
-- devuelve el conjunto de clientes que compraron en ella.
-- Permite construir los conjuntos A y B dinámicamente desde la
-- aplicación (cualquier categoría, no solo Electrónica/Ropa).
-- ============================================================
CREATE OR REPLACE FUNCTION clientes_por_categoria(p_categoria TEXT)
RETURNS TABLE(cliente_id INT, nombre VARCHAR) AS $$
  SELECT DISTINCT c.cliente_id, c.nombre
  FROM clientes c
  JOIN pedidos p         ON p.cliente_id = c.cliente_id
  JOIN detalle_pedido dp ON dp.pedido_id = p.pedido_id
  JOIN productos pr      ON pr.producto_id = dp.producto_id
  JOIN categorias cat    ON cat.categoria_id = pr.categoria_id
  WHERE cat.nombre = p_categoria;
$$ LANGUAGE sql STABLE;
