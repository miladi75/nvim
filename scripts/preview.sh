#!/usr/bin/env bash
# Open one file in its own Brave window. Bound to <leader>mp in mappings.lua.
#
# Markdown is rendered to a temp HTML file first; anything the browser already
# draws (svg, html, pdf, png, ...) is handed over untouched. No preview server,
# no websocket, no live reload — read it, Ctrl-w, done.
#
# NVIM_PREVIEW_DRY=1 prints the file that would be opened instead of opening it.
set -euo pipefail

PATH=$PATH:$HOME/.deno/bin

src=$(realpath "${1:?no file given}")
scripts=$(dirname "$(realpath "$0")")
target=$src

# Sweep previews from earlier sessions; an hour old means the window is long gone.
find "${TMPDIR:-/tmp}" -maxdepth 1 -name 'nvim-preview-*.html' -mmin +60 -delete 2>/dev/null || true

case ${src,,} in
*.svg)
    # Wrapped in a pan/zoom viewer with text search (ctrl+f or /) rather than
    # handed to the browser bare, where the wheel only scrolls. The SVG is inlined so it scales as vector
    # geometry and reports a real intrinsic size to fit-to-window.
    # An <?xml?> prolog or <!DOCTYPE> ahead of it is ignored by the HTML parser,
    # so the file goes in as it is.
    target=$(mktemp --tmpdir --suffix=.html nvim-preview-XXXXXX)

    cat >"$target" <<HTML
<!doctype html>
<meta charset="utf-8">
<title>$(basename "$src")</title>
<base href="file://$(dirname "$src")/">
<style>
  html, body { margin: 0; height: 100%; overflow: hidden; background: #1e2030; }
  body { font: 12px/1.4 monospace; color: #a9b8e8; }
  #nvp-stage { position: absolute; inset: 0; cursor: grab; }
  #nvp-stage.panning { cursor: grabbing; }
  #nvp-wrap { position: absolute; top: 0; left: 0; transform-origin: 0 0; }
  #nvp-wrap > svg { display: block; }
  #nvp-hud {
    position: fixed; left: 12px; bottom: 12px; padding: 5px 9px;
    background: #11131ccc; border: 1px solid #2f334d; border-radius: 5px;
    pointer-events: none; opacity: 0; transition: opacity .25s;
  }
  #nvp-hud.show { opacity: 1; }
  #nvp-marks { position: fixed; inset: 0; pointer-events: none; }
  #nvp-marks > div {
    position: absolute; background: #ffc66d44; outline: 1px solid #ffc66daa;
    border-radius: 2px;
  }
  #nvp-marks > div.cur { background: #ff910066; outline: 2px solid #ff9100; }
  #nvp-find {
    position: fixed; top: 10px; right: 14px; display: none; gap: 6px;
    align-items: center; padding: 5px 7px; background: #11131cee;
    border: 1px solid #2f334d; border-radius: 5px;
  }
  #nvp-find.show { display: flex; }
  #nvp-find input {
    width: 220px; padding: 3px 6px; font: inherit; color: #c8d3f5;
    background: #1e2030; border: 1px solid #3b4261; border-radius: 3px;
    outline: none;
  }
  #nvp-find input:focus { border-color: #82aaff; }
  #nvp-find.miss input { border-color: #ff757f; }
  #nvp-count { min-width: 56px; text-align: right; }
</style>
<div id="nvp-stage"><div id="nvp-wrap">
$(<"$src")
</div></div>
<div id="nvp-marks"></div>
<div id="nvp-find"><input id="nvp-find-input" placeholder="Find in SVG" spellcheck="false" autocomplete="off"><span id="nvp-count"></span></div>
<div id="nvp-hud"></div>
<script src="file://$scripts/svg-viewer.js"></script>
HTML
    ;;
*.md | *.markdown)
    css=$HOME/.local/share/nvim/lazy/peek.nvim/public
    target=$(mktemp --tmpdir --suffix=.html nvim-preview-XXXXXX)

    body=$(deno run --quiet --allow-read --allow-net --allow-env --allow-import \
        "$scripts/render-markdown.ts" "$src")

    # <base> makes relative image links in the document resolve against the
    # markdown file's own directory rather than /tmp.
    cat >"$target" <<HTML
<!doctype html>
<meta charset="utf-8">
<title>$(basename "$src")</title>
<base href="file://$(dirname "$src")/">
<link rel="stylesheet" href="file://$css/github-markdown.min.css">
<link rel="stylesheet" href="file://$css/katex.min.css">
<style>
  html { color-scheme: dark; }
  body { margin: 0; background: #0d1117; }
  .markdown-body { max-width: 60rem; margin: 0 auto; padding: 3rem 2rem; }
</style>
<article class="markdown-body">
$body
</article>
HTML
    ;;
esac

if [[ ${NVIM_PREVIEW_DRY:-} == 1 ]]; then
    echo "$target"
    exit 0
fi

# --app gives a chromeless window of its own on the current workspace instead of
# a tab in whatever Brave window happens to be open on another one.
#
# --user-data-dir is what makes --start-maximized work. Without it this command
# just hands the URL to the already-running Brave, which ignores every
# window-sizing flag and opens at whatever size it feels like (~1018x721) — so
# the window had to be maximized by hand every time. A separate profile means a
# separate browser process, which does honour the flags. Swap --start-maximized
# for --start-fullscreen if you want it borderless.
profile=${XDG_CACHE_HOME:-$HOME/.cache}/nvim-preview-brave

for browser in brave-browser brave-browser-stable brave; do
    if command -v "$browser" >/dev/null 2>&1; then
        exec "$browser" \
            --user-data-dir="$profile" \
            --no-first-run \
            --no-default-browser-check \
            --start-maximized \
            --app="file://$target"
    fi
done

exec xdg-open "$target"
