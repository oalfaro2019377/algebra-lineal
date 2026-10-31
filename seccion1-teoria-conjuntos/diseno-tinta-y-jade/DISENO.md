# Diseño «Tinta y Jade»: especificación para aplicar al sitio

Proyecto: Álgebra Lineal · Universidad Mariano Gálvez · Grupo 1 · Tienda ficticia TecnoModa GT.
Objetivo: cambiar **solo la capa visual** del sitio que ya existe para que coincida exactamente con este diseño. La lógica, las consultas, los endpoints, la conexión a PostgreSQL y los embeds de GeoGebra se quedan como están.

## 0. Archivos de esta carpeta

| Archivo | Qué es |
|---|---|
| `tokens.css` | Variables de color (claro y oscuro), tipografía, espaciado y radios. **Copiar tal cual, sin cambiar valores.** |
| `components.css` | Todas las clases de componentes. **Copiar tal cual.** Si algo no encaja, se agregan reglas en un archivo aparte (`site.css`), nunca editando estos dos. |
| `referencia/*.dc.html` | Las 6 maquetas originales. Son la **fuente de verdad visual**: cada elemento tiene sus estilos inline exactos. Si hay duda sobre un tamaño, color o espaciado, se mira aquí. (Usan sintaxis de plantilla `{{...}}`, `<sc-for>`, `<x-dc>` que se ignora: solo importan la estructura y los estilos.) |

Orden de carga en el `<head>`:

```html
<link rel="stylesheet" href="css/tokens.css">
<link rel="stylesheet" href="css/components.css">
<link rel="stylesheet" href="css/site.css"> <!-- solo si hace falta -->
```

Hay que **eliminar o desactivar** el CSS viejo que choque (frameworks, resets, colores, sombras, gradientes). Si el sitio usa Bootstrap/Tailwind solo para estilos, se quita; si lo usa para comportamiento (por ejemplo, las pestañas), se conserva el JS y se quitan sus clases visuales.

## 1. Reglas que no se negocian

1. **Un solo acento**: `--accent` (verde jade). Solo para lo activo, lo calculado o la respuesta final. Nada de azul, morado ni gradientes.
2. **Sin sombras** (`box-shadow: none` en todo). La jerarquía se marca con borde de 1px, superficie y tipografía.
3. **Radios**: 0 en tablas y en el banner de resultado; 3px en botones, inputs y código; 6px en tarjetas y visores; píldora **solo** en chips y puntos.
4. **Sin emojis ni iconos de stock.** Las únicas flechas son SVG de trazo (ver maquetas).
5. **Alineado a la izquierda.** Nada centrado por inercia. Cada encabezado de pestaña usa dos columnas: etiqueta a la izquierda y título a la derecha (`.page-head`).
6. **Fuentes**: Fraunces (títulos, fórmulas, cifras grandes), Instrument Sans (texto e interfaz), JetBrains Mono (SQL, matrices, etiquetas). Se cargan desde `tokens.css`.
7. **Legible proyectado**: cuerpo de 20px, h1 de 96px, cifras con `tabular-nums`.
8. **Claro y oscuro** con los mismos tokens. El modo sigue al sistema y se puede forzar con `<html data-theme="dark">` o `data-theme="light"`.
9. Todos los colores salen de `var(--…)`. **Ningún hex suelto** en HTML ni en CSS nuevo.

## 2. Estructura global

```html
<body>
  <header class="topbar">
    <div class="topbar__inner">
      <a class="brand" href="#">
        <span class="brand__name">TecnoModa</span><span class="brand__tag">GT</span>
      </a>
      <nav class="tabs" role="tablist" aria-label="Secciones">
        <button class="tab" role="tab" aria-selected="true"  aria-controls="tab-conjuntos"><span class="tab__num">01</span>Conjuntos</button>
        <button class="tab" role="tab" aria-selected="false" aria-controls="tab-matrices"><span class="tab__num">02</span>Matrices</button>
        <button class="tab" role="tab" aria-selected="false" aria-controls="tab-sistemas"><span class="tab__num">03</span>Sistemas de ecuaciones</button>
        <button class="tab" role="tab" aria-selected="false" aria-controls="tab-vectores"><span class="tab__num">04</span>Espacios vectoriales</button>
      </nav>
      <div class="topbar__meta">UMG · Grupo 1</div>
    </div>
  </header>

  <main>
    <section id="tab-conjuntos" role="tabpanel" class="container page">…</section>
    <section id="tab-matrices"  role="tabpanel" class="container" hidden>…</section>
    …
  </main>
</body>
```

- La pestaña activa lleva `aria-selected="true"` (o `.is-active` si el JS actual usa clases). Así se ve: texto `--ink` en 600, número en `--accent` y raya inferior de 2px `--accent`.
- Inactiva: texto `--ink-2` y número `--ink-3`. Hover: fondo `--surface-2` y raya `--line-strong`. Foco: contorno de 2px `--accent`.
- Si el JS actual ya cambia de pestaña, **solo hay que mapear sus clases** a estos atributos. Extra opcional: flechas ← → para moverse entre pestañas.

Patrón de encabezado (igual en las 4 pestañas):

```html
<div class="page-head">
  <div class="page-head__meta">
    <span class="label">Pestaña 01 / 04</span>
    <span class="badge-live"><span class="dot"></span>PostgreSQL · en vivo</span> <!-- solo en la 01 -->
  </div>
  <div class="page-head__main">
    <h1 class="t-display">Teoría de conjuntos</h1>
    <p class="t-lead">Dos grupos de clientes de TecnoModa GT. Cada operación se traduce a SQL y se ejecuta contra la base de datos en el momento en que la eliges.</p>
  </div>
</div>
```

Patrón de sección numerada:

```html
<section class="section">
  <div class="section-head">
    <div class="section-head__title">
      <span class="label">1 — Definir</span>
      <h2 class="t-h2">Los conjuntos</h2>
    </div>
    <!-- controles opcionales a la derecha (p. ej. el stepper de la 03) -->
  </div>
  …
</section>
```

## 3. Pestaña 01: Teoría de conjuntos (`referencia/Conjuntos.dc.html`)

Orden: encabezado → **1 Definir** → **2 Operar** → **3 Combinar** → pie.

**1 Definir**: dos `.card` en `.grid-auto` (`--min: 420px`). Cada una lleva:
- `.field` con `.field__label`: una muestra de línea continua para A (`.line-sample`) y punteada para B (`.line-sample--dashed`), más el texto «Conjunto A» o «Conjunto B»
- el `<select class="select">` que ya existe
- a la derecha, `.stat` con `|A|` y el conteo
- abajo, la definición en `.t-math`: `A = { c ∈ Clientes | c compró en Electrónica }`

**2 Operar**:
- `.op-group` con 5 `<button class="op-btn" aria-pressed>`. Cada botón tiene `<span class="op-btn__sym">A ∪ B</span><span class="op-btn__name">Unión</span>`. Los símbolos son ∪, ∩, A − B, B − A, A △ B. El activo lleva `aria-pressed="true"`.
- Debajo, `.split` con dos columnas:
  - **Izquierda**: `<figure class="card">` con la etiqueta «Diagrama de Venn» y el SVG siguiente. El JS existente solo debe poner o quitar `.is-active` en las tres regiones y en los tres conteos.
  - **Derecha**:
    - `.result-head`: etiqueta «Resultado», nombre de la operación y conteo grande
    - la definición formal en `.t-math` y la cardinalidad en mono (`|A ∪ B| = |A| + |B| − |A ∩ B| = …`)
    - `.code` con el SQL **que devuelve el backend**, con cabecera «postgres · tecnomoda · SQL ejecutado» y «N filas · T ms» reales
    - `.chips` con los clientes. Usar `.chip--a`, `.chip--b` o `.chip--both`, y `.chip__tag` con «A», «B» o «A·B» según de dónde venga el cliente.

```html
<svg class="venn" viewBox="0 0 560 380" role="img" aria-label="Diagrama de Venn">
  <defs>
    <clipPath id="clipA"><circle cx="210" cy="200" r="150"/></clipPath>
    <mask id="notB"><rect width="560" height="380" fill="#fff"/><circle cx="350" cy="200" r="150" fill="#000"/></mask>
    <mask id="notA"><rect width="560" height="380" fill="#fff"/><circle cx="210" cy="200" r="150" fill="#000"/></mask>
  </defs>
  <circle id="reg-a" class="venn__region" cx="210" cy="200" r="150" mask="url(#notB)"/>
  <circle id="reg-b" class="venn__region" cx="350" cy="200" r="150" mask="url(#notA)"/>
  <circle id="reg-i" class="venn__region is-active" cx="350" cy="200" r="150" clip-path="url(#clipA)"/>
  <circle class="venn__outline" cx="210" cy="200" r="150"/>
  <circle class="venn__outline venn__outline--b" cx="350" cy="200" r="150"/>
  <text class="venn__setname" x="120" y="38">A · Electrónica</text>
  <text class="venn__setname" x="440" y="38" text-anchor="end">B · Ropa</text>
  <text id="cnt-a" class="venn__count" x="140" y="218">5</text>
  <text id="cnt-i" class="venn__count is-active" x="280" y="218">4</text>
  <text id="cnt-b" class="venn__count" x="420" y="218">6</text>
</svg>
```

Regiones activas según la operación: ∪ = a, i, b · ∩ = i · A−B = a · B−A = b · △ = a, b.
Los nombres de categoría y los conteos del SVG se llenan con los datos reales.

**3 Combinar (producto cartesiano)**: `.split` con dos columnas.
- **Izquierda**:
  - un texto breve
  - la fórmula `V × C = { (v, c) | v ∈ V, c ∈ C }` en `.t-math` a 26px
  - una `.card` con el slider del umbral: label «Umbral VIP · gasto ≥» y el valor en Fraunces a 32px
  - `.stats-row` con |V|, |C| y |V × C| (este último con `.stat--accent`)
  - `.code` con el `CROSS JOIN` real
- **Derecha**: `.table-wrap` > `table.table` con caption «Pares (v, c) devueltos». Columnas: `#` (`.is-index`), Cliente VIP, Gasto (`.is-num`) y Cupón (en `<span class="tag-code">`).

## 4. Pestaña 02: Matrices (`referencia/Matrices.dc.html`)

Estado vacío elegante, nada de «404». Contenedor `.container.empty`:
- `.empty__main`:
  - etiqueta «Pestaña 02 / 04 · se presenta fuera del sitio»
  - h1 `.t-display`: «Matrices y <em>operaciones</em>»
  - `.t-lead` que explica que se hace en Desmos Matrix Calculator
  - `.empty__actions` con `a.btn.btn--primary` «Abrir Desmos Matrix ↗» (`https://www.desmos.com/matrix`, `target="_blank"`) y `a.btn` «Ir a 03 Sistemas»
- `.empty__figure`: «A =» más `.matrix` con la matriz de coeficientes de la pestaña 03 (tercera fila en `--ink-3`) y un figcaption.
- `.numbered-list` con 3 pasos: «Abrir la calculadora», «Operar en vivo», «Volver al sitio».

## 5. Pestaña 03: Sistemas de ecuaciones (`referencia/Sistemas.dc.html`)

Orden: encabezado → **1 Datos** → **2 Plantear** → **3 Resolver** → **4 Verificar** → banner → **5 Ver** → pie.

- **1 Datos**:
  - `.grid-auto` con 4 tarjetas. Hay una `.card` por nodo (Tipo A, B, C): `.card__head` lleva el h3 y la incógnita (`x`, `y` o `z`) en itálica `--accent`, y debajo va `dl.specs` con Cores, VRAM y Amperios.
  - La cuarta es `.card--muted` «Demanda · vector b».
  - Usar **los valores que ya tiene el sitio**.
- **2 Plantear**: dos columnas. A la izquierda va la sección con «Una ecuación por recurso · A·x = b». A la derecha va `.equations` con 8 columnas por fila: coeficiente con `<i>x</i>`, `+`, …, `=`, término independiente y unidad. Los signos van en `.op` y la unidad en `.unit`.
- **3 Resolver**:
  - A la derecha del `.section-head` va `.stepper`: botón `.btn.btn--icon` anterior, el texto «Paso N / 5» y el botón siguiente `.btn--primary`.
  - Debajo, `ol.steps` con los 5 `li.step`. Cada uno lleva `.step__lead`, `.step__num` (01–05), `.step__title`, `.step__desc` y `pre.step__math` con la matriz. El paso actual lleva `.is-active`.
  - Si el sitio no tiene stepper, se agrega con ~10 líneas de JS. Si ya muestra los pasos de otra forma, se conserva el contenido y solo se aplica el estilo.
- **4 Verificar**: `.grid-auto` con 4 tarjetas. La primera es `.card--muted` con D = det(A) y «D ≠ 0 → solución única». Las otras 3 son `.card` con Dx, Dy, Dz y la división resultante en `.t-math` color `--accent`.
- **Banner**: `div.result[role=status]` con:
  - `.result__kicker`: «Resultado final · Gauss = Cramer»
  - `.result__sentence`: la frase en lenguaje natural
  - `.result__values`: `<span><i>x</i> = 1</span><span><i>y</i> = 0.8</span><span><i>z</i> = 3.4</span>`
- **5 Ver**: `figure.viewer`. `.viewer__bar` dice «GeoGebra 3D» a la izquierda e «Arrastrar para rotar · rueda para acercar» a la derecha. Luego va **el iframe de GeoGebra existente** y después `.viewer__caption` con la leyenda de los 3 planos.

## 6. Pestaña 04: Espacios vectoriales (`referencia/Vectores.dc.html`)

La maqueta está en modo oscuro para mostrarlo; el sitio usa el modo que esté activo, igual que las otras pestañas.

- Encabezado: h1 «Espacios vectoriales <em class="accent">R² y R³</em>».
- **1 Operaciones**: `.grid-auto` (`--min: 380px`) con 5 `.card`. Cada una lleva:
  - etiqueta «01 · Suma»
  - la fórmula en `.t-math` a 32px
  - una línea de uso en el juego
  - `.card__foot` con la API: «Unity · Vector3.Dot / Unreal · FVector::DotProduct»
  - La quinta (Normalización) es `.card--accent`.
- **2 Movimiento** y **3 Rebote**: grid de 2 columnas (`--min: 520px`). Cada columna lleva su `.section-head`, un `.formula` con `r(t) = r₀ + v₀t + ½ a t²` o `r = v − 2(v · n̂) n̂`, y debajo:
  - en Movimiento, un `dl` con los términos en `--accent`
  - en Rebote, el pequeño SVG de reflexión (copiar de la maqueta y cambiar los hex por `currentColor`/`var(--…)`)
- **4 Ver**: `figure.viewer.viewer--tall` con **el iframe de GeoGebra existente** de la trayectoria y una leyenda «antes / después del rebote».

## 7. Cómo debe trabajar quien aplique el diseño

1. Leer el sitio actual completo y hacer un inventario: archivos, IDs y clases que usa el JS, endpoints y embeds.
2. Copiar `tokens.css` y `components.css` a la carpeta de estilos y enlazarlos.
3. Rehacer el HTML de cada pestaña con la estructura de arriba, **conservando todos los `id`, `name`, `data-*` y handlers que usa el JS**. Si el JS selecciona por clase vieja, se deja la clase vieja junto a la nueva o se actualiza el selector en el JS. **Nunca** se cambia lo que hace el JS.
4. Quitar el CSS viejo que choque.
5. Dibujar el Venn con el SVG de arriba y conectar las clases `.is-active` al estado actual.
6. Revisar cada pestaña en 1440px y en 390px, en claro y en oscuro, y comparar contra la maqueta de `referencia/`.

## 8. Lista de verificación final

- [ ] Ningún `box-shadow`, gradiente, emoji ni hex fuera de `tokens.css`
- [ ] Las 4 pestañas cambian igual que antes y la activa muestra la raya jade
- [ ] El SQL mostrado y los chips vienen de la respuesta real de PostgreSQL
- [ ] El Venn resalta la región correcta en las 5 operaciones
- [ ] El slider recalcula la tabla de pares
- [ ] Banner x = 1, y = 0.8, z = 3.4 visible en la 03
- [ ] Los dos GeoGebra siguen funcionando dentro de `.viewer`
- [ ] `data-theme="dark"` en `<html>` cambia todo el sitio sin colores rotos
- [ ] Sin scroll horizontal a 390px (tablas y código hacen scroll dentro de su caja)
- [ ] Ningún error nuevo en la consola
