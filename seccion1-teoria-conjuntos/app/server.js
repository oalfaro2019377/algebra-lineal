const express = require('express');
const path = require('path');
const os = require('os');
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.PGHOST || '/tmp',
  database: process.env.PGDATABASE || 'tienda_online',
  user: process.env.PGUSER || process.env.USER,
});

const app = express();
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

const page = (file) => (req, res) => res.sendFile(path.join(__dirname, 'public', file));
app.get('/', page('portada.html'));
app.get('/portada', page('portada.html'));
app.get('/agenda', page('agenda.html'));
app.get('/vista-1', page('vista-1.html'));
app.get('/vista-2', page('vista-2.html'));
app.get('/vista-3', page('vista-3.html'));
app.get('/vista-4', page('vista-4.html'));
app.get('/seccion-1', page('seccion1.html'));
app.get('/seccion-2', page('seccion2.html'));
app.get('/seccion-3', page('seccion3.html'));
app.get('/seccion-4', page('seccion4.html'));
app.get('/final', page('final.html'));
app.get('/control', page('control.html'));

// ---------------------------------------------------------------
// Control remoto: el teléfono (en /control) manda next/prev; todas
// las diapositivas/secciones abiertas en la laptop lo detectan
// sondeando este mismo estado en memoria (shared/slidenav.js).
// Un solo presentador a la vez, sin autenticación: pensado para una
// red Wi-Fi local durante la exposición, no para internet abierto.
// ---------------------------------------------------------------
let remoteState = { seq: 0, dir: null };
app.get('/api/remote/state', (req, res) => res.json(remoteState));
app.post('/api/remote/next', (req, res) => {
  remoteState = { seq: remoteState.seq + 1, dir: 'next' };
  res.json(remoteState);
});
app.post('/api/remote/prev', (req, res) => {
  remoteState = { seq: remoteState.seq + 1, dir: 'prev' };
  res.json(remoteState);
});
app.post('/api/remote/desmos', (req, res) => {
  remoteState = { seq: remoteState.seq + 1, dir: 'desmos' };
  res.json(remoteState);
});

function fmtSql(catA, catB) {
  return {
    union: `SELECT cliente_id, nombre FROM clientes_por_categoria('${catA}')\nUNION\nSELECT cliente_id, nombre FROM clientes_por_categoria('${catB}');`,
    interseccion: `SELECT cliente_id, nombre FROM clientes_por_categoria('${catA}')\nINTERSECT\nSELECT cliente_id, nombre FROM clientes_por_categoria('${catB}');`,
    diferenciaAB: `SELECT cliente_id, nombre FROM clientes_por_categoria('${catA}')\nEXCEPT\nSELECT cliente_id, nombre FROM clientes_por_categoria('${catB}');`,
    diferenciaBA: `SELECT cliente_id, nombre FROM clientes_por_categoria('${catB}')\nEXCEPT\nSELECT cliente_id, nombre FROM clientes_por_categoria('${catA}');`,
    diferenciaSimetrica: `(SELECT cliente_id, nombre FROM clientes_por_categoria('${catA}')\n EXCEPT\n SELECT cliente_id, nombre FROM clientes_por_categoria('${catB}'))\nUNION\n(SELECT cliente_id, nombre FROM clientes_por_categoria('${catB}')\n EXCEPT\n SELECT cliente_id, nombre FROM clientes_por_categoria('${catA}'));`,
  };
}

// Lista de categorías disponibles (para poblar los selectores del frontend)
app.get('/api/categorias', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT categoria_id, nombre FROM categorias ORDER BY nombre');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Total de clientes (universo U)
app.get('/api/universo', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT cliente_id, nombre FROM clientes ORDER BY cliente_id');
    res.json({ total: rows.length, clientes: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Ejecuta en vivo las 5 operaciones de conjuntos para dos categorías elegidas por el usuario,
// usando la función clientes_por_categoria(texto) definida en 04_funcion_categoria.sql.
app.get('/api/conjuntos', async (req, res) => {
  const catA = req.query.catA;
  const catB = req.query.catB;
  if (!catA || !catB) return res.status(400).json({ error: 'catA y catB son requeridos' });
  if (catA === catB) return res.status(400).json({ error: 'catA y catB deben ser distintas' });

  try {
    const [a, b, union, interseccion, diferenciaAB, diferenciaBA, diferenciaSimetrica, totalClientes] = await Promise.all([
      pool.query(`SELECT * FROM clientes_por_categoria($1) ORDER BY cliente_id`, [catA]),
      pool.query(`SELECT * FROM clientes_por_categoria($1) ORDER BY cliente_id`, [catB]),
      pool.query(
        `SELECT * FROM clientes_por_categoria($1)
         UNION
         SELECT * FROM clientes_por_categoria($2)
         ORDER BY cliente_id`,
        [catA, catB]
      ),
      pool.query(
        `SELECT * FROM clientes_por_categoria($1)
         INTERSECT
         SELECT * FROM clientes_por_categoria($2)
         ORDER BY cliente_id`,
        [catA, catB]
      ),
      pool.query(
        `SELECT * FROM clientes_por_categoria($1)
         EXCEPT
         SELECT * FROM clientes_por_categoria($2)
         ORDER BY cliente_id`,
        [catA, catB]
      ),
      pool.query(
        `SELECT * FROM clientes_por_categoria($1)
         EXCEPT
         SELECT * FROM clientes_por_categoria($2)
         ORDER BY cliente_id`,
        [catB, catA]
      ),
      pool.query(
        `(SELECT * FROM clientes_por_categoria($1)
          EXCEPT
          SELECT * FROM clientes_por_categoria($2))
         UNION
         (SELECT * FROM clientes_por_categoria($2)
          EXCEPT
          SELECT * FROM clientes_por_categoria($1))
         ORDER BY cliente_id`,
        [catA, catB]
      ),
      pool.query('SELECT COUNT(*)::int AS n FROM clientes'),
    ]);

    res.json({
      catA, catB,
      a: a.rows,
      b: b.rows,
      union: union.rows,
      interseccion: interseccion.rows,
      diferenciaAB: diferenciaAB.rows,
      diferenciaBA: diferenciaBA.rows,
      diferenciaSimetrica: diferenciaSimetrica.rows,
      totalClientes: totalClientes.rows[0].n,
      sql: fmtSql(catA, catB),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Producto cartesiano VIP x Cupones, con umbral de gasto dinámico
app.get('/api/cartesiano', async (req, res) => {
  const minGasto = Number(req.query.minGasto);
  if (!Number.isFinite(minGasto) || minGasto < 0) {
    return res.status(400).json({ error: 'minGasto debe ser un número >= 0' });
  }
  try {
    const vipQuery = `
      SELECT c.cliente_id, c.nombre, SUM(dp.cantidad * dp.precio_unitario) AS gasto_total
      FROM clientes c
      JOIN pedidos p         ON p.cliente_id = c.cliente_id
      JOIN detalle_pedido dp ON dp.pedido_id = p.pedido_id
      GROUP BY c.cliente_id, c.nombre
      HAVING SUM(dp.cantidad * dp.precio_unitario) > $1
      ORDER BY gasto_total DESC`;
    const [vip, cupones, pares] = await Promise.all([
      pool.query(vipQuery, [minGasto]),
      pool.query('SELECT cupon_id, codigo, descripcion FROM cupones ORDER BY cupon_id'),
      pool.query(
        `SELECT v.cliente_id, v.nombre, v.gasto_total, cu.cupon_id, cu.codigo
         FROM (${vipQuery}) v
         CROSS JOIN cupones cu
         ORDER BY v.cliente_id, cu.cupon_id`,
        [minGasto]
      ),
    ]);

    res.json({
      minGasto,
      vip: vip.rows,
      cupones: cupones.rows,
      pares: pares.rows,
      sql: `SELECT v.cliente_id, v.nombre, v.gasto_total, cu.codigo\nFROM v_clientes_vip v   -- gasto_total > ${minGasto}\nCROSS JOIN cupones cu\nORDER BY v.cliente_id, cu.cupon_id;`,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

function getLanIP() {
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name] || []) {
      if (net.family === 'IPv4' && !net.internal) return net.address;
    }
  }
  return null;
}

const PORT = process.env.PORT || 4010;
app.listen(PORT, () => {
  console.log(`Dashboard de conjuntos escuchando en http://localhost:${PORT}`);
  const ip = getLanIP();
  if (ip) {
    console.log(`Control remoto desde el teléfono (mismo Wi-Fi): http://${ip}:${PORT}/control`);
  } else {
    console.log('No se detectó una IP de red local; conecta la laptop al Wi-Fi para usar el control remoto.');
  }
});
