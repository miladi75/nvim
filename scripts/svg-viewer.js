// yEd-style navigation for the SVG preview window (see preview.sh):
//   wheel          zoom in/out around the pointer
//   drag           pan (any mouse button; right-drag works like yEd)
//   double-click   fit to window
//   f / 0          fit to window          1  100%
//   + / -          zoom step              q / Esc  close the window
//   ctrl+f  or  /  search text: Enter / F3 next, shift+Enter / shift+F3
//                  previous, Esc closes the search box
//
// Loaded by the generated preview page, which provides #nvp-stage (viewport),
// #nvp-wrap (transformed container holding the SVG), #nvp-marks, #nvp-find
// and #nvp-hud. Kept in step with VIEWER_JS in
// ~/.config/Code/User/vscode_svg_preview.py.
(() => {
  const stage = document.getElementById('nvp-stage');
  const wrap = document.getElementById('nvp-wrap');
  const hud = document.getElementById('nvp-hud');

  const MIN = 0.02;
  const MAX = 64;

  let scale = 1;
  let tx = 0;
  let ty = 0;

  // A viewBox with no width/height leaves the SVG without a dependable
  // intrinsic size, so borrow the viewBox's dimensions before measuring.
  const svg = wrap.querySelector('svg');
  if (svg && (!svg.getAttribute('width') || !svg.getAttribute('height'))) {
    const box = svg.viewBox?.baseVal;
    if (box?.width && box?.height) {
      svg.setAttribute('width', box.width);
      svg.setAttribute('height', box.height);
    }
  }

  // Natural size, measured once with no transform applied — every fit() after
  // this is arithmetic, so repeated fits can't drift.
  const natural = (() => {
    wrap.style.transform = 'none';
    const r = wrap.getBoundingClientRect();
    return { w: r.width, h: r.height };
  })();

  const clamp = (k) => Math.min(Math.max(k, MIN), MAX);

  function apply() {
    wrap.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
    placeMarks();
  }

  let hudTimer;
  function say(text) {
    hud.textContent = text;
    hud.classList.add('show');
    clearTimeout(hudTimer);
    hudTimer = setTimeout(() => hud.classList.remove('show'), 1400);
  }

  function fit(quiet) {
    if (!natural.w || !natural.h) return;
    const margin = 32;
    scale = clamp(Math.min(
      (innerWidth - margin) / natural.w,
      (innerHeight - margin) / natural.h,
    ));
    tx = (innerWidth - natural.w * scale) / 2;
    ty = (innerHeight - natural.h * scale) / 2;
    apply();
    if (!quiet) say(`fit · ${Math.round(scale * 100)}%`);
  }

  // Zoom about a fixed point: the content under (x, y) stays under (x, y).
  function zoomAt(x, y, factor) {
    const next = clamp(scale * factor);
    if (next === scale) return;
    tx = x - (x - tx) * (next / scale);
    ty = y - (y - ty) * (next / scale);
    scale = next;
    apply();
    say(`${Math.round(scale * 100)}%`);
  }

  stage.addEventListener('wheel', (e) => {
    e.preventDefault();
    // Trackpad pinch arrives as ctrl+wheel; both mean "zoom" here.
    zoomAt(e.clientX, e.clientY, Math.exp(-e.deltaY * 0.002));
  }, { passive: false });

  // Pan with any button held. Right-drag needs the context menu suppressed.
  let panning = null;
  stage.addEventListener('contextmenu', (e) => e.preventDefault());

  stage.addEventListener('pointerdown', (e) => {
    panning = { x: e.clientX, y: e.clientY };
    stage.classList.add('panning');
    stage.setPointerCapture?.(e.pointerId);
    e.preventDefault();
  });

  stage.addEventListener('pointermove', (e) => {
    if (!panning) return;
    tx += e.clientX - panning.x;
    ty += e.clientY - panning.y;
    panning = { x: e.clientX, y: e.clientY };
    apply();
  });

  const endPan = () => {
    panning = null;
    stage.classList.remove('panning');
  };
  stage.addEventListener('pointerup', endPan);
  stage.addEventListener('pointercancel', endPan);

  stage.addEventListener('dblclick', () => fit());

  // ---- Text search -------------------------------------------------------
  // Matches are highlighted by boxes in a fixed overlay rather than inside the
  // transformed wrapper, so outlines stay crisp at any zoom. Boxes are stored
  // in the SVG's untransformed coordinates and re-projected on every apply().
  const findBox = document.getElementById('nvp-find');
  const findInput = document.getElementById('nvp-find-input');
  const findCount = document.getElementById('nvp-count');
  const marks = document.getElementById('nvp-marks');
  let hits = [];     // { box: {x, y, w, h} in natural coords, el: <div> }
  let cur = -1;

  // Elements whose text is searchable. Text split over <tspan>s (or spans
  // inside a draw.io <foreignObject>) belongs to one owner, so a phrase that
  // spans pieces still matches.
  const owners = (() => {
    if (!svg) return [];
    const skip = new Set(['style', 'script', 'title', 'desc', 'metadata']);
    const seen = new Set();
    const out = [];
    const walker = document.createTreeWalker(svg, NodeFilter.SHOW_TEXT);
    for (let n = walker.nextNode(); n; n = walker.nextNode()) {
      if (!n.nodeValue.trim()) continue;
      const p = n.parentElement;
      if (!p || skip.has(p.localName) || p.closest('style,script,title,desc,metadata')) continue;
      const owner = p.closest('text') || p;
      if (!seen.has(owner)) { seen.add(owner); out.push(owner); }
    }
    return out;
  })();

  function toNatural(r) {
    return {
      x: (r.left - tx) / scale, y: (r.top - ty) / scale,
      w: r.width / scale, h: r.height / scale,
    };
  }

  function placeMarks() {
    const pad = 2;
    for (const h of hits) {
      const s = h.el.style;
      s.left = `${tx + h.box.x * scale - pad}px`;
      s.top = `${ty + h.box.y * scale - pad}px`;
      s.width = `${h.box.w * scale + 2 * pad}px`;
      s.height = `${h.box.h * scale + 2 * pad}px`;
    }
  }

  function runSearch() {
    const q = findInput.value.trim().toLowerCase();
    marks.replaceChildren();
    hits = [];
    cur = -1;
    if (q) {
      for (const o of owners) {
        if (!o.textContent.replace(/\s+/g, ' ').toLowerCase().includes(q)) continue;
        const r = o.getBoundingClientRect();
        if (!r.width && !r.height) continue;  // hidden / display:none
        const el = document.createElement('div');
        marks.appendChild(el);
        hits.push({ box: toNatural(r), el });
      }
      // Reading order: top to bottom, then left to right.
      hits.sort((a, b) => (a.box.y - b.box.y) || (a.box.x - b.box.x));
      placeMarks();
    }
    findBox.classList.toggle('miss', Boolean(q) && !hits.length);
    if (hits.length) go(0); else updateCount();
  }

  function updateCount() {
    findCount.textContent = hits.length ? `${cur + 1}/${hits.length}`
      : (findInput.value.trim() ? '0/0' : '');
  }

  // Bring match i to the centre, zooming in only when it is too small to read.
  function go(i) {
    if (!hits.length) return;
    if (cur >= 0) hits[cur].el.classList.remove('cur');
    cur = (i + hits.length) % hits.length;
    const h = hits[cur];
    h.el.classList.add('cur');
    const minPx = 18;
    if (h.box.h * scale < minPx) {
      scale = clamp(Math.min(minPx * 1.5 / h.box.h, (innerWidth * 0.8) / h.box.w));
    }
    tx = innerWidth / 2 - (h.box.x + h.box.w / 2) * scale;
    ty = innerHeight / 2 - (h.box.y + h.box.h / 2) * scale;
    apply();
    updateCount();
  }

  function openFind() {
    findBox.classList.add('show');
    findInput.focus();
    findInput.select();
  }

  function closeFind() {
    findBox.classList.remove('show');
    findInput.blur();
    marks.replaceChildren();
    hits = [];
    cur = -1;
  }

  findInput.addEventListener('input', runSearch);
  findInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === 'F3') go(cur + (e.shiftKey ? -1 : 1));
    else if (e.key === 'Escape') closeFind();
    else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'f') findInput.select();
    else { e.stopPropagation(); return; }  // ordinary typing: not a viewer key
    e.preventDefault();
    e.stopPropagation();
  });

  addEventListener('keydown', (e) => {
    const mid = { x: innerWidth / 2, y: innerHeight / 2 };

    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'f') {
      e.preventDefault();  // keep the browser's own find bar away
      openFind();
      return;
    }
    if (e.ctrlKey || e.metaKey || e.altKey) return;

    switch (e.key) {
      case '/': openFind(); break;
      case 'F3': go(cur + (e.shiftKey ? -1 : 1)); break;
      case 'f': case 'F': case '0': fit(); break;
      case '1':
        scale = 1;
        tx = (innerWidth - natural.w) / 2;
        ty = (innerHeight - natural.h) / 2;
        apply();
        say('100%');
        break;
      case '+': case '=': zoomAt(mid.x, mid.y, 1.25); break;
      case '-': case '_': zoomAt(mid.x, mid.y, 0.8); break;
      case 'q': case 'Escape': window.close(); break;
      default: return;
    }

    e.preventDefault();
  });

  fit(true);
  say('wheel zoom · drag pan · f fit · ctrl+f search · q close');

  // Exposed so the preview can be checked without a human driving the mouse.
  window.__nvpView = () => ({ scale, tx, ty, natural, hits: hits.length, cur });
})();
