#!/usr/bin/env python3
"""
VHDL Custom Syntax Highlighting Setup for Neovim (NvChad + TreeSitter)

Standalone script — run it from any directory. No external dependencies
beyond the Python standard library (3.6+).

This is the Neovim port of ~/.config/Code/User/setup_vhdl_colors.py and
follows the same color convention: hardcode as little as possible. Only one
naming convention gets a literal color. Everything else is captured under a
NATIVE TreeSitter group, so it inherits whatever colorscheme is active and
keeps working after a theme switch.

    f_*, pd_*                   functions        custom color

    s_*                         state machines   @number       (native)
    v_*                         variables        @number       (native)
    g_*                         generics         @number       (native)
    c_*                         constants        @number       (native)
    enum literals               enum values      @number       (native)
    t_*                         user types       @type.builtin (native)
    sl, slv                     type aliases     @type.builtin (native)
    to_*                        conversions      @type.builtin (native)
    *_lib, *_lib.entity_name    library refs     @type.builtin (native)

    *_i, *_o                    port signals     not captured — theme default
    local signals               architecture     not captured — theme default

@number is whatever the theme paints 1024 / '0' / true. @type.builtin is
whatever it paints std_logic / std_logic_vector. Nothing to re-tune when you
change colorscheme. s_* and v_* share the number color on purpose, as in the
VSCode script.

vhdl_ls semantic tokens stay off (NvChad's on_init drops the capability), the
same as "[vhdl]": {"editor.semanticHighlighting.enabled": false} on the VSCode
side, so the server cannot recolor some occurrences of a name and not others.

What this script modifies (two files inside ~/.config/nvim/):

    1. after/queries/vhdl/highlights.scm  — TreeSitter highlight queries
    2. lua/chadrc.lua                     — NvChad base46 hl_add table

The custom group lives in chadrc's hl_add rather than in options.lua:
base46 compiles hl_add into its highlight cache and regenerates it on every
theme change, so no ColorScheme autocmd is needed. Older versions of this
script wrote a block into lua/options.lua; it is removed on both apply and
revert.

Usage:
    python3 setup_vhdl_colors.py          # apply colors
    python3 setup_vhdl_colors.py --revert # remove all VHDL color customizations
"""

import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Color definitions  (Change your own custom colors here and run the script)
# ---------------------------------------------------------------------------
# Edit these to change colors. Format: (hex_color, font_style)
# font_style can be: "bold", "italic", "bold italic", or ""
#
# Only conventions that have no sensible native equivalent belong here. If you
# find yourself adding an entry, first check whether a native capture already
# means the right thing — see NATIVE_CAPTURES below.
COLORS = {
    "f_prefix": ("#00D9FA", ""),  # functions        f_decode, pd_enable
}

# Map from COLORS key -> TreeSitter capture name (used in highlights.scm)
CAPTURE_NAMES = {
    "f_prefix": "@function.vhdl",
}

# Documentation only — these need no color entry, that is the whole point.
# Kept here so the mapping is visible in one place next to COLORS.
NATIVE_CAPTURES = {
    "@number": "s_*, v_*, g_*, c_*, enum literals",
    "@type.builtin": "t_*, sl/slv, to_*, *_lib",
    "(none)": "port *_i/*_o and local signals — theme default identifier color",
}

# Capture names this script has written at some point. Used to purge stale
# entries from chadrc when a category moves onto a native capture.
LEGACY_CAPTURES = [
    "@state.vhdl",
    "@vprefix.vhdl",
    "@function.vhdl",
    "@constant.vhdl",
    "@generic.vhdl",
    "@port_signal.vhdl",
    "@local_signal.vhdl",
    "@type_prefix.vhdl",
]


# ---------------------------------------------------------------------------
# TreeSitter highlight queries (after/queries/vhdl/highlights.scm)
# ---------------------------------------------------------------------------
#
# Priority ordering (higher wins where two patterns match the same node):
#   120  custom-colored prefixes (f_, pd_)
#   115  native captures driven by a prefix (s_, v_, g_, c_, t_, sl/slv, to_*,
#        *_lib)
#   110  native capture driven by position (enum literals)
#
# Signals are matched by nothing at all, so they fall through to the parser's
# own @variable and render in the theme's default identifier color.
#
# #match? uses vim regex. \c = ignore case (VHDL is case-insensitive),
# \v = very magic, so ( ) | need no backslashes.
HIGHLIGHTS_SCM = r"""; extends
;
; Managed by setup_vhdl_colors.py — do not edit by hand.
;
; Only @function.vhdl carries a hardcoded color (defined in lua/chadrc.lua
; under base46.hl_add). Every other rule reuses a native capture so it follows
; the active colorscheme:
;
;   s_*, v_*, g_*, c_*, enums    -> @number       (theme's number color)
;   t_*, sl/slv, to_*, *_lib     -> @type.builtin (theme's std_logic color)
;   port *_i/*_o, local signals  -> not captured  (theme's identifier color)

; ── Custom-colored prefixes (priority 120) ──

; Functions and procedures: f_*, pd_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c\\v^(f|pd)_")
  (#set! priority 120))

; ── Native type color: same as std_logic / std_logic_vector (priority 115) ──

; User-defined types: t_*
((identifier) @type.builtin
  (#match? @type.builtin "\\c^t_")
  (#set! priority 115))

; Type aliases sl, slv and to_* conversions (to_slv, to_unsigned, to_int, ...)
((identifier) @type.builtin
  (#match? @type.builtin "\\c\\v^(sl|slv|to_\\w+)$")
  (#set! priority 115))

; ...and again as library_function: the parser heuristically reclassifies
; to_* call names, so to_slv(x) is not an (identifier) node at all. Without
; this it falls through to the parser's own @function.builtin.
((library_function) @type.builtin
  (#match? @type.builtin "\\c\\v^(sl|slv|to_\\w+)$")
  (#set! priority 115))

; Library references: common_lib, work_lib, ...
((identifier) @type.builtin
  (#match? @type.builtin "\\c_lib$")
  (#set! priority 115))

; ...and the unit selected off one: common_lib.thing
; @_lib is a helper capture (leading underscore = not highlighted), it only
; constrains the match to names whose first part is a library.
((name
   (identifier) @_lib
   (selection
     (identifier) @type.builtin))
  (#match? @_lib "\\c_lib$")
  (#set! priority 115))

; ...and the package in a use clause: use common_lib.common_pkg.all
((selected_name
   library: (identifier) @_lib
   package: (identifier) @type.builtin)
  (#match? @_lib "\\c_lib$")
  (#set! priority 115))

; ── Native number color: same as 1024 / '0' / true (priority 115) ──

; State machines s_*, variables v_*, generics g_*, constants c_*
((identifier) @number
  (#match? @number "\\c\\v^(s|v|g|c)_")
  (#set! priority 115))

; Enum literals: type t_state is (UNDEF, SOF, ...)
((enumeration_type_definition
   (enumeration_literal
     (identifier) @number))
  (#set! priority 110))
"""


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def find_nvim_config_dir():
    """Find the Neovim config directory (~/.config/nvim/)."""
    config_dir = Path.home() / ".config" / "nvim"
    if config_dir.is_dir():
        return config_dir
    return None


def normalize_color(color):
    """Return a #RRGGBB color that nvim_set_hl accepts.

    The VSCode copy of this script uses 8-digit #RRGGBBAA values, which
    Neovim rejects outright ("invalid highlight color") and which take the
    whole config down at startup. Drop the alpha channel if present.
    """
    if re.fullmatch(r"#[0-9a-fA-F]{8}", color):
        return color[:7]
    return color


def build_chadrc_hl_line(capture, color, style):
    """Build a single chadrc hl_add entry."""
    opts = ['fg = "{}"'.format(normalize_color(color))]
    if "bold" in style:
        opts.append("bold = true")
    if "italic" in style:
        opts.append("italic = true")
    return '        ["{}"] = {{ {} }},'.format(capture, ", ".join(opts))


# ---------------------------------------------------------------------------
# Step 1: Write highlights.scm
# ---------------------------------------------------------------------------


def apply_highlights_scm(nvim_dir):
    """Write the TreeSitter highlight queries."""
    queries_dir = nvim_dir / "after" / "queries" / "vhdl"
    queries_dir.mkdir(parents=True, exist_ok=True)
    scm_path = queries_dir / "highlights.scm"

    # Backup original if it exists and no backup yet
    backup_path = queries_dir / "highlights.scm.original"
    if scm_path.is_file() and not backup_path.is_file():
        scm_path.rename(backup_path)
        print("  Saved backup: {}".format(backup_path))

    scm_path.write_text(HIGHLIGHTS_SCM, encoding="utf-8")
    print("  Wrote: {}".format(scm_path))
    return True


def revert_highlights_scm(nvim_dir):
    """Remove or restore highlights.scm."""
    queries_dir = nvim_dir / "after" / "queries" / "vhdl"
    scm_path = queries_dir / "highlights.scm"
    backup_path = queries_dir / "highlights.scm.original"

    if backup_path.is_file():
        if scm_path.is_file():
            scm_path.unlink()
        backup_path.rename(scm_path)
        print("  Restored from backup: {}".format(scm_path))
    elif scm_path.is_file():
        scm_path.unlink()
        print("  Removed: {}".format(scm_path))
        # Clean up empty directories
        try:
            queries_dir.rmdir()
            queries_dir.parent.rmdir()
        except OSError:
            pass
    else:
        print("  No highlights.scm to remove.")
    return True


# ---------------------------------------------------------------------------
# Step 2: Remove the legacy options.lua block
# ---------------------------------------------------------------------------
#
# Earlier versions defined the highlight groups with nvim_set_hl plus a
# ColorScheme autocmd in lua/options.lua. base46's hl_add does the same job
# and survives theme switches on its own, so the block is now purged rather
# than rewritten.

OPTIONS_BEGIN = (
    "-- VHDL_COLORS_BEGIN (managed by setup_vhdl_colors.py — do not edit)"
)
OPTIONS_END = "-- VHDL_COLORS_END"


def clean_options(nvim_dir):
    """Strip any VHDL highlight block left in options.lua by older runs."""
    options_path = nvim_dir / "lua" / "options.lua"
    if not options_path.is_file():
        return True

    content = options_path.read_text(encoding="utf-8")
    original = content

    if OPTIONS_BEGIN in content:
        content = re.sub(
            re.escape(OPTIONS_BEGIN) + r".*?" + re.escape(OPTIONS_END),
            "",
            content,
            flags=re.DOTALL,
        )
    else:
        # Hand-written block from before this script existed
        content = re.sub(
            r"\n*-- Force custom VHDL captures.*?"
            r'vim\.api\.nvim_create_autocmd\("ColorScheme".*?\}\)\n*',
            "\n",
            content,
            flags=re.DOTALL,
        )

    content = re.sub(r"\n{3,}", "\n\n", content).rstrip("\n") + "\n"

    if content != original:
        options_path.write_text(content, encoding="utf-8")
        print("  Removed legacy VHDL block: {}".format(options_path))
    else:
        print("  Nothing to clean: {}".format(options_path))
    return True


# ---------------------------------------------------------------------------
# Step 3: Patch chadrc.lua (NvChad base46 hl_add)
# ---------------------------------------------------------------------------

CHADRC_BEGIN = (
    "    -- VHDL_COLORS_BEGIN (managed by setup_vhdl_colors.py — do not edit)"
)
CHADRC_END = "    -- VHDL_COLORS_END"


def build_chadrc_block():
    """Build the managed hl_add block for chadrc.lua."""
    lines = [CHADRC_BEGIN]
    lines.append("    -- Only conventions with no native equivalent are listed.")
    lines.append("    -- s_*/v_*/g_*/c_*/enums use @number and t_*/sl/slv/to_*/*_lib use")
    lines.append("    -- @type.builtin, so they follow the active theme.")
    lines.append("    hl_add = {")
    for key, capture in CAPTURE_NAMES.items():
        color, style = COLORS[key]
        lines.append(build_chadrc_hl_line(capture, color, style))
    lines.append("    },")
    lines.append(CHADRC_END)
    return "\n".join(lines)


def strip_chadrc_block(content):
    """Remove the managed block and any stale VHDL hl entries."""
    # Managed block
    content = re.sub(
        re.escape(CHADRC_BEGIN) + r".*?" + re.escape(CHADRC_END) + r"\n?",
        "",
        content,
        flags=re.DOTALL,
    )

    # Loose entries written by older versions into hl_override / hl_add
    for capture in LEGACY_CAPTURES:
        content = re.sub(
            r'[ \t]*\["{}"\]\s*=\s*\{{[^}}]*\}},?[ \t]*\n?'.format(re.escape(capture)),
            "",
            content,
        )

    # Drop hl_override / hl_add tables left empty by the purge above
    content = re.sub(
        r"[ \t]*hl_(?:override|add)\s*=\s*\{\s*\},?[ \t]*\n?",
        "",
        content,
    )

    return re.sub(r"\n{3,}", "\n\n", content)


def apply_chadrc(nvim_dir):
    """Patch chadrc.lua with the VHDL hl_add block."""
    chadrc_path = nvim_dir / "lua" / "chadrc.lua"
    if not chadrc_path.is_file():
        print("  ERROR: {} not found.".format(chadrc_path))
        return False

    content = strip_chadrc_block(chadrc_path.read_text(encoding="utf-8"))

    # Insert the managed block as the first entry of M.base46. Spliced by hand
    # rather than through re.sub so backslashes in colors/comments stay literal.
    match = re.search(r"M\.base46\s*=\s*\{[ \t]*\n", content)
    if match is None:
        print("  ERROR: no 'M.base46 = {' table in {}.".format(chadrc_path))
        return False

    block = build_chadrc_block() + "\n"
    content = content[: match.end()] + block + content[match.end() :]

    chadrc_path.write_text(content, encoding="utf-8")
    print("  Patched: {}".format(chadrc_path))
    return True


def revert_chadrc(nvim_dir):
    """Remove VHDL entries from chadrc.lua."""
    chadrc_path = nvim_dir / "lua" / "chadrc.lua"
    if not chadrc_path.is_file():
        return True

    chadrc_path.write_text(
        strip_chadrc_block(chadrc_path.read_text(encoding="utf-8")), encoding="utf-8"
    )
    print("  Reverted: {}".format(chadrc_path))
    return True


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    revert = "--revert" in sys.argv

    print("=" * 68)
    if revert:
        print("VHDL Custom Syntax Highlighting for Neovim - REVERT")
    else:
        print("VHDL Custom Syntax Highlighting Setup for Neovim")
    print("=" * 68)
    print()

    nvim_dir = find_nvim_config_dir()
    if nvim_dir is None:
        print("ERROR: Could not find Neovim config directory.")
        print("Expected: ~/.config/nvim/")
        sys.exit(1)

    print("Neovim config: {}".format(nvim_dir))
    print()

    print("[1/3] TreeSitter queries (highlights.scm)")
    if revert:
        revert_highlights_scm(nvim_dir)
    else:
        apply_highlights_scm(nvim_dir)
    print()

    print("[2/3] Legacy block cleanup (options.lua)")
    clean_options(nvim_dir)
    print()

    print("[3/3] NvChad highlight groups (chadrc.lua)")
    if revert:
        revert_chadrc(nvim_dir)
    else:
        apply_chadrc(nvim_dir)
    print()

    print("=" * 68)
    if revert:
        print("Reverted! Restart Neovim to see changes.")
    else:
        print("Done! Restart Neovim to see changes.")
        print()
        print("Hardcoded colors (chadrc.lua hl_add):")
        for key, capture in CAPTURE_NAMES.items():
            color, style = COLORS[key]
            style_str = "  {}".format(style) if style else ""
            print("  {:24s} {}{}".format(capture, normalize_color(color), style_str))
        print()
        print("Follows the active colorscheme (no color to maintain):")
        for capture, what in NATIVE_CAPTURES.items():
            print("  {:24s} {}".format(capture, what))
    print("=" * 68)


if __name__ == "__main__":
    main()
