<claude-mem-context>
# Memory Context

# [nvim] recent context, 2026-06-09 10:10am GMT+2

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 28 obs (9,644t read) | 318,307t work | 97% savings

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
### Jun 8, 2026
387 2:12p ✅ Neovim Visual Mode Ctrl+C Clipboard Yank Keybinding
389 " 🟣 Added Ctrl+C Clipboard Keybindings for Normal and Visual Mode
390 " 🟣 Neovim Ctrl+C clipboard mappings added for normal and visual modes
388 " 🔵 Neovim Config Structure and Existing Ctrl+C Clipboard Mapping
391 2:14p ✅ Neovim Ctrl+C clipboard mappings added for normal and visual modes

Access 318k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>