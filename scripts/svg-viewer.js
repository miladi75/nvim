// yEd-style navigation for the SVG preview window (see preview.sh):
//   wheel        zoom in/out around the pointer
//   drag         pan (any mouse button; right-drag works like yEd)
//   double-click fit to window
//   f / 0        fit to window          1  100%
//   + / -        zoom step              q / Esc  close the window
//
// Loaded by the generated preview page, which provides #nvp-stage (viewport),
// #nvp-wrap (transformed container holding the SVG) and #nvp-hud.
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

  addEventListener('keydown', (e) => {
    const mid = { x: innerWidth / 2, y: innerHeight / 2 };

    switch (e.key) {
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
  say('wheel zoom · drag pan · f fit · q close');

  // Exposed so the preview can be checked without a human driving the mouse.
  window.__nvpView = () => ({ scale, tx, ty, natural });
})();
