#!/usr/bin/env python3
"""
VHDL Custom Syntax Highlighting Setup for Neovim (NvChad + TreeSitter)

Standalone script — run it from any directory. No external dependencies
beyond the Python standard library (3.6+).

Patches the Neovim configuration to add custom colors for VHDL naming
conventions using TreeSitter highlight queries:

    s_*        State machines   #02710C  dark green, bold
    v_*        Variables        #F0E806  yellow
    f_*, pd_*  Functions        #CCDDF5  blue, bold
    c_*        Constants        #FFFFFF  white
    g_*        Generics         #FFFFFF  white
    t_*        User types       same color as native std_logic (@type.builtin)
    *_i, *_o   Port signals     #00C2B5  teal    (entity port signals, everywhere)
    local sig  Local signals    #FFFFFF   orange  (architecture signals, non-_i/_o)

What this script modifies (three files inside ~/.config/nvim/):

    1. after/queries/vhdl/highlights.scm  — TreeSitter highlight queries
    2. lua/options.lua                    — vim.api highlight colors + autocmd
    3. lua/chadrc.lua                     — NvChad hl_override table

Usage:
    python3 setup_vhdl_colors.py          # apply colors
    python3 setup_vhdl_colors.py --revert # remove all VHDL color customizations
"""

import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Color definitions  (Change your own custom colors here and run the script)
# ---------------------------------------------------------------------------
# Edit these to change colors. Format: (hex_color, font_style)
# font_style can be: "bold", "italic", "bold italic", or ""
COLORS = {
    "s_prefix": ("#02FF41", ""),  # state machines   s_idle, s_running
    "v_prefix": ("#FF9100", ""),  # variables        v_counter, v_temp
    "f_prefix": ("#00D9FA", ""),  # functions        f_decode, pd_enable
    "c_prefix": ("#FFFFFF", ""),  # constants        c_max_width
    "g_prefix": ("#FFFFFF", ""),  # generics         g_width
    # NOTE: t_* user types are intentionally NOT listed here. They are
    # captured directly as @type.builtin in highlights.scm so they inherit
    # the theme's native type color (same as std_logic / std_logic_vector).
    "port_signal": (
        "#FFFFFF",
        "",
    ),  # port signals     clk_i, data_o (*_i/*_o everywhere)
    "local_signal": (
        "#FFFFFF",
        "",
    ),  # local signals    signal sreset (non-_i/_o, everywhere)
}

# Map from COLORS key -> TreeSitter capture name (used in highlights.scm)
CAPTURE_NAMES = {
    "s_prefix": "@state.vhdl",
    "v_prefix": "@vprefix.vhdl",
    "f_prefix": "@function.vhdl",
    "c_prefix": "@constant.vhdl",
    "g_prefix": "@generic.vhdl",
    "port_signal": "@port_signal.vhdl",
    "local_signal": "@local_signal.vhdl",
}


# ---------------------------------------------------------------------------
# TreeSitter highlight queries (after/queries/vhdl/highlights.scm)
# ---------------------------------------------------------------------------
HIGHLIGHTS_SCM = """\
; extends

; ── Prefix patterns (highest priority) ──

; Functions: f_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\\\c^f_")
  (#set! priority 120))

; Functions: pd_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\\\c^pd_")
  (#set! priority 120))

; Constants: c_*
((identifier) @constant.vhdl
  (#match? @constant.vhdl "\\\\c^c_")
  (#set! priority 120))

; Variables: v_*
((identifier) @vprefix.vhdl
  (#match? @vprefix.vhdl "\\\\c^v_")
  (#set! priority 120))

; Generics: g_*
((identifier) @generic.vhdl
  (#match? @generic.vhdl "\\\\c^g_")
  (#set! priority 120))

; State-machine names/signals: s_*
((identifier) @state.vhdl
  (#match? @state.vhdl "\\\\c^s_")
  (#set! priority 120))

; User-defined types: t_*  → capture as @type.builtin so they render in the
; exact same color as native types (std_logic, std_logic_vector, ...).
((identifier) @type.builtin
  (#match? @type.builtin "\\\\c^t_")
  (#set! priority 120))

; ── Port signals: identifiers ending with _i or _o (everywhere) ──
((identifier) @port_signal.vhdl
  (#match? @port_signal.vhdl "\\\\c_[io]$")
  (#set! priority 110))

; ── Broad catch-all: every identifier that isn't prefixed or a port ──
; Priority 105 beats base @variable (100); prefix rules (120) and
; port rule (110) still win where they match.
((identifier) @local_signal.vhdl
  (#not-match? @local_signal.vhdl "\\\\c^(s_|v_|f_|pd_|c_|g_|t_)")
  (#not-match? @local_signal.vhdl "\\\\c_[io]$")
  (#set! priority 105))

; ── Local signals (non-_i/_o, various contexts) ──

; Signal declarations
((signal_declaration
   (identifier_list
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Simple waveform assignment LHS
((simple_waveform_assignment
   (name
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Concurrent simple signal assignment LHS
((concurrent_simple_signal_assignment
   (name
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Port declarations inside entity (interface_declaration)
((interface_declaration
   (identifier_list
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

((interface_signal_declaration
   (identifier_list
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Entity instantiation port map – actual part (right of =>)
((port_map_aspect
   (association_list
     (association_element
       (conditional_expression
         (simple_expression
           (name
             (identifier) @local_signal.vhdl))))))
  (#set! priority 100))

; Generic map – actual part (right of =>)
((generic_map_aspect
   (association_list
     (association_element
       (conditional_expression
         (simple_expression
           (name
             (identifier) @local_signal.vhdl))))))
  (#set! priority 100))
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


def build_hl_lua_line(capture, color, style):
    """Build a single nvim_set_hl() Lua line."""
    opts = [f'fg = "{color}"']
    if "bold" in style:
        opts.append("bold = true")
    if "italic" in style:
        opts.append("italic = true")
    return f'    vim.api.nvim_set_hl(0, "{capture}", {{ {", ".join(opts)} }})'


def build_chadrc_hl_line(capture, color, style):
    """Build a single chadrc hl_override entry."""
    opts = [f'fg = "{color}"']
    if "bold" in style:
        opts.append("bold = true")
    if "italic" in style:
        opts.append("italic = true")
    return f'        ["{capture}"] = {{ {", ".join(opts)} }},'


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
        print(f"  Saved backup: {backup_path}")

    scm_path.write_text(HIGHLIGHTS_SCM, encoding="utf-8")
    print(f"  Wrote: {scm_path}")
    return True


def revert_highlights_scm(nvim_dir):
    """Remove or restore highlights.scm."""
    queries_dir = nvim_dir / "after" / "queries" / "vhdl"
    scm_path = queries_dir / "highlights.scm"
    backup_path = queries_dir / "highlights.scm.original"

    if backup_path.is_file():
        backup_path.rename(scm_path)
        print(f"  Restored from backup: {scm_path}")
    elif scm_path.is_file():
        scm_path.unlink()
        print(f"  Removed: {scm_path}")
        # Clean up empty directories
        try:
            (queries_dir).rmdir()
            (queries_dir.parent).rmdir()
        except OSError:
            pass
    else:
        print("  No highlights.scm to remove.")
    return True


# ---------------------------------------------------------------------------
# Step 2: Patch options.lua (highlight colors + autocmd)
# ---------------------------------------------------------------------------

# Markers used to identify managed block
OPTIONS_BEGIN = (
    "-- VHDL_COLORS_BEGIN (managed by setup_vhdl_colors.py — do not edit)"
)
OPTIONS_END = "-- VHDL_COLORS_END"


def build_options_block():
    """Build the Lua block for options.lua."""
    lines = [OPTIONS_BEGIN]
    lines.append("local function apply_vhdl_custom_highlights()")
    for key, capture in CAPTURE_NAMES.items():
        color, style = COLORS[key]
        lines.append(build_hl_lua_line(capture, color, style))
    lines.append("end")
    lines.append("")
    lines.append("apply_vhdl_custom_highlights()")
    lines.append("")
    lines.append('vim.api.nvim_create_autocmd("ColorScheme", {')
    lines.append("    callback = apply_vhdl_custom_highlights,")
    lines.append("})")
    lines.append(OPTIONS_END)
    return "\n".join(lines)


def apply_options(nvim_dir):
    """Patch options.lua with VHDL highlight colors."""
    options_path = nvim_dir / "lua" / "options.lua"
    if not options_path.is_file():
        print(f"  ERROR: {options_path} not found.")
        return False

    content = options_path.read_text(encoding="utf-8")

    # Remove existing managed block if present
    if OPTIONS_BEGIN in content:
        content = re.sub(
            re.escape(OPTIONS_BEGIN) + r".*?" + re.escape(OPTIONS_END),
            "",
            content,
            flags=re.DOTALL,
        )
        content = content.rstrip("\n") + "\n"
    else:
        # Remove old hand-written VHDL highlights (from before this script)
        # Match the apply_vhdl_custom_highlights function + autocmd block
        content = re.sub(
            r"\n*-- Force custom VHDL captures.*?"
            r'vim\.api\.nvim_create_autocmd\("ColorScheme".*?\}\)\n*',
            "\n",
            content,
            flags=re.DOTALL,
        )

    # Append managed block
    content = content.rstrip("\n") + "\n\n" + build_options_block() + "\n"
    options_path.write_text(content, encoding="utf-8")
    print(f"  Patched: {options_path}")
    return True


def revert_options(nvim_dir):
    """Remove VHDL highlights from options.lua."""
    options_path = nvim_dir / "lua" / "options.lua"
    if not options_path.is_file():
        return True

    content = options_path.read_text(encoding="utf-8")

    # Remove managed block
    if OPTIONS_BEGIN in content:
        content = re.sub(
            re.escape(OPTIONS_BEGIN) + r".*?" + re.escape(OPTIONS_END),
            "",
            content,
            flags=re.DOTALL,
        )
    else:
        # Remove old hand-written block
        content = re.sub(
            r"\n*-- Force custom VHDL captures.*?"
            r'vim\.api\.nvim_create_autocmd\("ColorScheme".*?\}\)\n*',
            "\n",
            content,
            flags=re.DOTALL,
        )

    content = content.rstrip("\n") + "\n"
    options_path.write_text(content, encoding="utf-8")
    print(f"  Reverted: {options_path}")
    return True


# ---------------------------------------------------------------------------
# Step 3: Patch chadrc.lua (NvChad hl_override)
# ---------------------------------------------------------------------------


def apply_chadrc(nvim_dir):
    """Patch chadrc.lua with VHDL hl_override entries."""
    chadrc_path = nvim_dir / "lua" / "chadrc.lua"
    if not chadrc_path.is_file():
        print(f"  ERROR: {chadrc_path} not found.")
        return False

    content = chadrc_path.read_text(encoding="utf-8")

    # Build new hl_override entries
    hl_lines = []
    for key, capture in CAPTURE_NAMES.items():
        color, style = COLORS[key]
        hl_lines.append(build_chadrc_hl_line(capture, color, style))
    new_entries = "\n".join(hl_lines)

    # Check if hl_override block exists
    if "hl_override" in content:
        # Remove all existing VHDL capture lines from hl_override
        for capture in CAPTURE_NAMES.values():
            pattern = rf'\s*\["{re.escape(capture)}"\]\s*=\s*\{{[^}}]*\}},?\n?'
            content = re.sub(pattern, "\n", content)

        # Also remove old captures that may not be in CAPTURE_NAMES anymore
        old_captures = [
            "@function.vhdl",
            "@generic.vhdl",
            "@constant.vhdl",
            "@vprefix.vhdl",
            "@port_signal.vhdl",
            "@local_signal.vhdl",
            "@state.vhdl",
            "@type_prefix.vhdl",
        ]
        for cap in old_captures:
            pattern = rf'\s*\["{re.escape(cap)}"\]\s*=\s*\{{[^}}]*\}},?\n?'
            content = re.sub(pattern, "\n", content)

        # Clean up multiple blank lines inside hl_override
        content = re.sub(r"(hl_override\s*=\s*\{)\n+", r"\1\n", content)

        # Insert new entries after hl_override = {
        content = re.sub(
            r"(hl_override\s*=\s*\{)\n",
            r"\1\n" + new_entries + "\n",
            content,
        )
    else:
        # No hl_override — add one inside M.base46
        hl_block = f"    hl_override = {{\n{new_entries}\n    }},"
        content = re.sub(
            r"(M\.base46\s*=\s*\{[^\n]*\n)",
            r"\1" + hl_block + "\n",
            content,
        )

    chadrc_path.write_text(content, encoding="utf-8")
    print(f"  Patched: {chadrc_path}")
    return True


def revert_chadrc(nvim_dir):
    """Remove VHDL entries from chadrc.lua hl_override."""
    chadrc_path = nvim_dir / "lua" / "chadrc.lua"
    if not chadrc_path.is_file():
        return True

    content = chadrc_path.read_text(encoding="utf-8")

    # Remove all VHDL capture lines
    all_captures = list(CAPTURE_NAMES.values()) + [
        "@function.vhdl",
        "@generic.vhdl",
        "@constant.vhdl",
        "@vprefix.vhdl",
        "@port_signal.vhdl",
        "@local_signal.vhdl",
        "@state.vhdl",
        "@type_prefix.vhdl",
    ]
    for cap in set(all_captures):
        pattern = rf'\s*\["{re.escape(cap)}"\]\s*=\s*\{{[^}}]*\}},?\n?'
        content = re.sub(pattern, "\n", content)

    # Clean up empty hl_override block
    content = re.sub(
        r"\s*hl_override\s*=\s*\{\s*\},?\n?",
        "\n",
        content,
    )

    # Clean up multiple blank lines
    content = re.sub(r"\n{3,}", "\n\n", content)

    chadrc_path.write_text(content, encoding="utf-8")
    print(f"  Reverted: {chadrc_path}")
    return True


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    revert = "--revert" in sys.argv

    print("=" * 60)
    if revert:
        print("VHDL Custom Syntax Highlighting for Neovim - REVERT")
    else:
        print("VHDL Custom Syntax Highlighting Setup for Neovim")
    print("=" * 60)
    print()

    nvim_dir = find_nvim_config_dir()
    if nvim_dir is None:
        print("ERROR: Could not find Neovim config directory.")
        print("Expected: ~/.config/nvim/")
        sys.exit(1)

    print(f"Neovim config: {nvim_dir}")
    print()

    # Step 1: highlights.scm
    print("[1/3] TreeSitter queries (highlights.scm)")
    if revert:
        revert_highlights_scm(nvim_dir)
    else:
        apply_highlights_scm(nvim_dir)
    print()

    # Step 2: options.lua
    print("[2/3] Highlight colors (options.lua)")
    if revert:
        revert_options(nvim_dir)
    else:
        apply_options(nvim_dir)
    print()

    # Step 3: chadrc.lua
    print("[3/3] NvChad overrides (chadrc.lua)")
    if revert:
        revert_chadrc(nvim_dir)
    else:
        apply_chadrc(nvim_dir)
    print()

    print("=" * 60)
    if revert:
        print("Reverted! Restart Neovim to see changes.")
    else:
        print("Done! Restart Neovim to see changes.")
        print()
        print("Color scheme applied:")
        for key, capture in CAPTURE_NAMES.items():
            color, style = COLORS[key]
            style_str = f"  {style}" if style else ""
            comment = COLORS[key]  # reuse comment from dict
            print(f"  {capture:24s} {color}{style_str}")
    print("=" * 60)


if __name__ == "__main__":
    main()
