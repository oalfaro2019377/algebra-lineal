// Injects the shared top tab navigation ("Tinta y Jade" — .topbar/.tab) into
// every page of the site. Each page sets <body data-active-section="1|2|3|4">
// to mark its own tab with aria-current="page".
(function () {
  const TABS = [
    { id: '1', num: '01', label: 'Conjuntos', href: 'seccion1.html' },
    { id: '2', num: '02', label: 'Matrices', href: 'seccion2.html' },
    { id: '3', num: '03', label: 'Sistemas de ecuaciones', href: 'seccion3.html' },
    { id: '4', num: '04', label: 'Espacios vectoriales', href: 'seccion4.html' },
  ];

  function renderNav() {
    const active = document.body.dataset.activeSection;

    const header = document.createElement('header');
    header.className = 'topbar';

    const inner = document.createElement('div');
    inner.className = 'topbar__inner';

    const brand = document.createElement('a');
    brand.className = 'brand';
    brand.href = 'portada.html';
    brand.innerHTML = '<span class="brand__name">Álgebra Lineal</span>';
    inner.appendChild(brand);

    const nav = document.createElement('nav');
    nav.className = 'tabs';
    nav.setAttribute('aria-label', 'Secciones');

    TABS.forEach((t) => {
      const a = document.createElement('a');
      a.className = 'tab';
      a.href = t.href;
      if (t.id === active) a.setAttribute('aria-current', 'page');
      a.innerHTML = '<span class="tab__num">' + t.num + '</span>' + t.label;
      nav.appendChild(a);
    });
    inner.appendChild(nav);

    const meta = document.createElement('div');
    meta.className = 'topbar__meta';
    meta.textContent = 'UMG · Grupo 1';
    inner.appendChild(meta);

    header.appendChild(inner);
    document.body.insertBefore(header, document.body.firstChild);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderNav);
  } else {
    renderNav();
  }
})();
