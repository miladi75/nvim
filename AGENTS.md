<claude-mem-context>
# Memory Context

# [nvim] recent context, 2026-06-08 2:12pm GMT+2

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 23 obs (8,113t read) | 271,053t work | 97% savings

### May 15, 2026
167 1:27p 🔵 Neovim + Kitty Keymap Landscape Mapped for Quit Shortcut
168 1:28p 🟣 Neovim Quick Quit Shortcut Added: `<leader>qq`
169 1:30p ✅ Neovim keybindings.md Updated to Document `<leader>qq`
170 " 🔵 Headless Neovim Keymap Verification Returns `nil` — Not a Reliable Test
171 " 🔵 NvChad Mappings Load via `vim.schedule` — Explains Headless Test Failure
172 " 🔵 Headless Neovim Trick: `+sleep 100m` Fires `vim.schedule` Callbacks
173 1:32p 🟣 Neovim `<leader>qq` Quit Shortcut Verified Working in Both Modes
### May 20, 2026
198 8:31p 🔵 VHDL Syntax Color Port: VSCode → Neovim
199 " 🔵 Neovim VHDL Color Setup Script Structure Mapped
200 " 🔵 VSCode VHDL Color Palette Differs Significantly from Neovim Version
201 8:32p ✅ Neovim VHDL COLORS Dict Updated to Match VSCode Palette
S51 Fix inconsistent VHDL signal coloring: stream_nd orange at declaration but white in if-conditions (May 20, 8:32 PM)
S50 Port VHDL syntax highlight colors from VSCode to Neovim by updating setup_vhdl_colors.py (May 20, 8:32 PM)
202 8:38p 🔵 VHDL Local Signal Color Inconsistent in If-Condition Expressions
203 " 🔵 Three VHDL TreeSitter highlights.scm Files Found on System
205 " 🔴 Fixed Inconsistent VHDL Signal Colors via Broad Catch-All TreeSitter Pattern
204 8:55p 🔵 Base VHDL Grammar Catch-All: (identifier) @variable Causes White Fallback
### Jun 4, 2026
357 4:21p 🔵 VHDL Syntax Coloring: Custom Types Use Different Color Than Native Types
358 " 🔵 setup_vhdl_colors.py: Architecture and Color Configuration
359 4:22p 🔵 Native VHDL Types Use @type.builtin; User Type Refs Use @type
360 4:23p ✅ setup_vhdl_colors.py Docstring Updated for t_* Color Intent
362 " ✅ t_prefix Removed from CAPTURE_NAMES; t_* Now Routes to @type.builtin
363 4:25p 🟣 t_* VHDL Types Now Rendered via @type.builtin — Matches Native Type Color
361 " ✅ Removed t_prefix from COLORS Dict in setup_vhdl_colors.py
364 4:26p 🟣 VHDL t_* Type Color Unification Deployed and Verified
S129 Unify VHDL t_* custom type color with native types (std_logic, std_logic_vector) in Neovim setup script (Jun 4, 4:26 PM)
**Investigated**: - Read `setup_vhdl_colors.py` in full: Python script managing VHDL syntax highlighting across 3 Neovim config files via COLORS dict, CAPTURE_NAMES dict, and HIGHLIGHTS_SCM string
    - Read `lua/chadrc.lua`: NvChad config showing `@type_prefix.vhdl` was hardcoded to `#02FF41` (green) in `hl_override`
    - Read `after/queries/vhdl/highlights.scm`: the live TreeSitter query file showing `t_*` captured as `@type_prefix.vhdl`
    - Read upstream nvim-treesitter VHDL grammar at `/home/milad/.local/share/nvim/lazy/nvim-treesitter/queries/vhdl/highlights.scm`: discovered native types use `(library_type) @type.builtin` and type references use `(_ type: (_) @type)`

**Learned**: - `std_logic`, `std_logic_vector` etc. are colored by `@type.builtin` in the nvim-treesitter VHDL grammar
    - The old `@type_prefix.vhdl` capture was a fully custom group with no link to any standard TreeSitter highlight — it only worked because `chadrc.lua` forced a hex color on it
    - To unify with native type color, `t_*` must be captured as `@type.builtin` (not `@type`, which covers type-position references) so the theme's native type color is inherited
    - NvChad theme in use is `github_dark`; `@type.builtin` color comes from this theme and changes automatically if theme switches
    - `setup_vhdl_colors.py` is idempotent: running it multiple times replaces the managed block cleanly

**Completed**: - Updated `setup_vhdl_colors.py` docstring: `t_*` color comment changed from `#04F792 green/aqua` to `same color as native std_logic (@type.builtin)`
    - Removed `"t_prefix": ("#02FF41", "")` from `COLORS` dict; replaced with explanatory comment
    - Removed `"t_prefix": "@type_prefix.vhdl"` from `CAPTURE_NAMES` dict
    - Updated `HIGHLIGHTS_SCM` string: `t_*` rule changed from `@type_prefix.vhdl` to `@type.builtin` (priority 120 preserved)
    - Ran `python3 setup_vhdl_colors.py` successfully — all 3 files patched
    - Verified: `after/queries/vhdl/highlights.scm` uses `@type.builtin` for `t_*`; zero occurrences of `type_prefix` remain in `after/` or `lua/`; `chadrc.lua` hl_override has 7 entries with no `@type_prefix.vhdl`

**Next Steps**: Work is complete. User needs to restart Neovim to see the change. Optionally: wire up the `[CAVEMAN]` statusline badge by adding a `statusLine` entry to `~/.claude/settings.json` (Claude offered this as an optional follow-up).


Access 271k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>