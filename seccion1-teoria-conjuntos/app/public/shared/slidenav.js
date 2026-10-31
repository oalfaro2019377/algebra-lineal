// Navegación anterior/siguiente para toda la secuencia de la exposición
// (diapositivas Y secciones de contenido). Se incluye con una sola línea
// <script src="shared/slidenav.js"></script> en cada página.
//
// - Botones flotantes (.slidenav-controls) siempre visibles, abajo a la
//   derecha, en todas las páginas.
// - PageUp / PageDown: anterior/siguiente en CUALQUIER página — estas
//   teclas no las usa ningún control de formulario del sitio, así que
//   son seguras incluso dentro de las Secciones (y son justo lo que
//   mandan la mayoría de "clickers"/controles remotos de presentación).
// - Flecha ← / → , Espacio, Enter: igual, pero SOLO cuando el foco no
//   está en un <select>/<input>/<textarea> — así no interfieren con el
//   selector de categorías o el slider de la Sección 1.
(function () {
  const SEQUENCE = [
    'portada.html',
    'agenda.html',
    'vista-1.html', 'vista-2.html', 'vista-3.html', 'vista-4.html',
    'seccion1.html', 'seccion2.html', 'seccion3.html', 'seccion4.html',
    'final.html',
  ];

  // Nombre de archivo de la página actual, venga la URL como la sirve
  // GitHub Pages / un enlace normal (".../vista-1.html") o como la
  // serví­a antes la ruta "limpia" de Express en local (".../vista-1",
  // ".../seccion-1", o "/" para la portada) — ambos formatos deben
  // encontrar la misma posición en SEQUENCE.
  function currentFile() {
    let last = location.pathname.split('/').filter(Boolean).pop() || '';
    if (!last) return 'portada.html';
    if (!last.endsWith('.html')) last += '.html';
    return last.replace(/^seccion-(\d)\.html$/, 'seccion$1.html');
  }

  const path = currentFile();
  const idx = SEQUENCE.indexOf(path);
  if (idx === -1) return;

  const prevUrl = idx > 0 ? SEQUENCE[idx - 1] : null;
  const nextUrl = idx < SEQUENCE.length - 1 ? SEQUENCE[idx + 1] : null;

  function go(url) {
    if (url) window.location.href = url;
  }

  function isFormField(el) {
    if (!el) return false;
    const tag = el.tagName;
    return tag === 'SELECT' || tag === 'INPUT' || tag === 'TEXTAREA' || el.isContentEditable;
  }

  document.addEventListener('keydown', (e) => {
    if (e.key === 'PageDown') { e.preventDefault(); go(nextUrl); return; }
    if (e.key === 'PageUp') { e.preventDefault(); go(prevUrl); return; }
    if (isFormField(document.activeElement)) return;
    if (e.key === 'ArrowRight' || e.key === ' ' || e.key === 'Enter') { e.preventDefault(); go(nextUrl); }
    if (e.key === 'ArrowLeft') { e.preventDefault(); go(prevUrl); }
  });

  function renderControls() {
    const wrap = document.createElement('div');
    wrap.className = 'slidenav-controls';

    if (prevUrl) {
      const a = document.createElement('a');
      a.href = prevUrl;
      a.className = 'btn btn--icon slidenav-btn';
      a.setAttribute('aria-label', 'Anterior');
      a.innerHTML = '<svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M11 3L5 9l6 6"/></svg>';
      wrap.appendChild(a);
    }
    if (nextUrl) {
      const a = document.createElement('a');
      a.href = nextUrl;
      a.className = 'btn btn--primary btn--icon slidenav-btn';
      a.setAttribute('aria-label', 'Siguiente');
      a.innerHTML = '<svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true"><path d="M7 3l6 6-6 6"/></svg>';
      wrap.appendChild(a);
    }
    document.body.appendChild(wrap);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderControls);
  } else {
    renderControls();
  }

  // Control remoto (/control, típicamente abierto en el teléfono):
  // sondea el mismo estado en memoria del servidor cada 400ms. Al
  // cargar, primero lee el seq actual sin actuar sobre él (si no,
  // cada página reproduciría el último comando que la trajo aquí);
  // solo navega cuando ve un seq MÁS NUEVO que ese punto de partida.
  (function pollRemote() {
    let lastSeq = null;
    let stopped = false;

    async function tick() {
      if (stopped) return;
      try {
        const res = await fetch('api/remote/state', { cache: 'no-store' });
        const data = await res.json();
        if (lastSeq === null) {
          lastSeq = data.seq;
        } else if (data.seq !== lastSeq) {
          lastSeq = data.seq;
          stopped = true; // la navegación va a destruir esta página de todos modos
          if (data.dir === 'next') go(nextUrl);
          else if (data.dir === 'prev') go(prevUrl);
          return;
        }
      } catch (e) {
        // Sin servidor de control alcanzable (p. ej. abierto como archivo
        // local): no pasa nada, simplemente no hay control remoto activo.
      }
      setTimeout(tick, 400);
    }
    tick();
  })();
})();
