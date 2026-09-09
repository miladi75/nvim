# Neovim Keybindings Reference

This file is the single source of truth for keybindings in this config.

Legend:
- `<leader>` = `Space`
- `<C-...>` = `Ctrl`
- `<A-...>` = `Alt`
- `<S-...>` = `Shift`

## General

| Mode | Key | Action |
|------|-----|--------|
| `n` | `;` | Enter command mode |
| `i` | `jk` | Exit insert mode |
| `n` | `<Esc>` | Clear search highlights |
| `n` | `<C-c>` | Copy whole file to system clipboard |
| `v` | `<C-c>` | Copy selection to system clipboard |
| `n` | `<leader>fs` | Save file |
| `n,t` | `<leader>qq` | Quit Neovim without saving |
| `n` | `<leader>n` | Toggle line numbers |
| `n` | `<leader>rn` | Toggle relative line numbers |
| `n` | `<leader>ch` | Open NvChad cheatsheet |
| `n` | `<leader>wK` | Show all WhichKey mappings |
| `n` | `<leader>wk` | Query WhichKey mappings |

## Buffers and Windows

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<leader>b` | New buffer |
| `n` | `<leader>x` | Close current buffer |
| `n` | `<Tab>` | Next buffer |
| `n` | `<S-Tab>` | Previous buffer |
| `n` | `<C-h>` | Move to left window |
| `n` | `<C-j>` | Move to window below |
| `n` | `<C-k>` | Move to window above |
| `n` | `<C-l>` | Move to right window |

## Insert Mode Navigation

| Mode | Key | Action |
|------|-----|--------|
| `i` | `<C-b>` | Move to beginning of line |
| `i` | `<C-e>` | Move to end of line |
| `i` | `<C-h>` | Move left |
| `i` | `<C-j>` | Move down |
| `i` | `<C-k>` | Move up |
| `i` | `<C-l>` | Move right |

## File Explorer and Search

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<leader>e` | Toggle NvimTree |
| `n` | `<C-n>` | Toggle NvimTree |
| `n` | `<leader>ff` | Telescope find files |
| `n` | `<leader>fa` | Telescope find all files |
| `n` | `<leader>fw` | Telescope live grep |
| `n` | `<leader>fb` | Telescope buffers |
| `n` | `<leader>fo` | Telescope old files |
| `n` | `<leader>fz` | Telescope fuzzy find in current buffer |
| `n` | `<leader>fh` | Telescope help tags |
| `n` | `<leader>ma` | Telescope marks |
| `n` | `<leader>cm` | Telescope git commits |
| `n` | `<leader>gt` | Telescope git status |
| `n` | `<leader>pt` | Telescope terminal picker |
| `n` | `<leader>th` | Theme picker |

## Markdown / SVG Preview

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<leader>mp` | Open current file in its own Brave window |
| `n` | `<leader>mv` | Toggle in-editor rich preview (markview + diagrams/math) |

`<leader>mp` opens a plain Brave window on the current workspace — not a tab in
some window elsewhere. Close it with `Ctrl-w`. Markdown is converted to HTML
first (`scripts/preview.sh`); `.svg`, `.html`, `.pdf` and images are handed to
the browser as they are. Unsaved changes are previewed too.

No live reload: press `<leader>mp` again for a fresh window. For markdown
rendered inside the editor — mermaid diagrams, math — use `<leader>mv`.

SVG files open in a pan/zoom viewer (`scripts/svg-viewer.js`), navigated like
yEd:

| Input | Action |
|-------|--------|
| Wheel | Zoom around the pointer (trackpad pinch works too) |
| Drag (any button) | Pan |
| Double-click, `f`, `0` | Fit to window |
| `1` | Zoom to 100% |
| `+` / `-` | Zoom step |
| `q`, `Esc` | Close the window |

`:PeekOpen` / `:PeekClose` still exist (peek.nvim, live reload, opens a tab).

## Git

Hunk and blame keys come from gitsigns and exist only in buffers tracked by git.
Diffview does repo-wide diffs, file history and merges; the snacks pickers give
a fast commit/status browser with a diff preview.

| Mode | Key | Action |
|------|-----|--------|
| `n` | `]h` / `[h` | Next / previous hunk (also works inside a diff window) |
| `n` | `<leader>gh` | Preview hunk inline (old text shown in the buffer) |
| `n` | `<leader>gH` | Preview hunk in a popup |
| `n`, `v` | `<leader>gs` | Stage hunk / selected lines (again on a staged hunk unstages) |
| `n`, `v` | `<leader>gr` | Reset hunk / selected lines |
| `n` | `<leader>gu` | Undo the last stage |
| `n` | `<leader>gS` / `<leader>gR` | Stage / reset the whole buffer |
| `n` | `<leader>gq` | All hunks in all buffers to the quickfix list |
| `n` | `<leader>gb` | Blame current line with the full commit message |
| `n` | `<leader>gB` | Blame the whole file in a scroll-bound side window (`<CR>` for actions) |
| `n` | `<leader>gl` | Toggle the inline current-line blame |
| `n` | `<leader>gd` / `<leader>gD` | Two-pane diff of this file against the index / `HEAD~` |
| `n` | `<leader>gw` | Toggle word-level diff highlighting |
| `n` | `<leader>gx` | Toggle showing deleted lines inline |
| `o`, `x` | `ih` | Hunk text object (`dih`, `yih`, `vih`) |
| `n` | `<leader>gv` | Toggle Diffview (working tree vs index; `q` also closes) |
| `n` | `<leader>gV` | Diffview file history for current file |
| `n` | `<leader>gc` / `<leader>gC` | Commits picker: repo / current file |
| `n` | `<leader>gG` | Git status picker |
| `n` | `<leader>cm` / `<leader>gt` | Telescope commits / status (NvChad defaults) |

## Terminal

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<leader>h` | New horizontal terminal |
| `n` | `<leader>v` | New vertical terminal |
| `n,t` | `<A-h>` | Toggle horizontal terminal |
| `n,t` | `<A-v>` | Toggle vertical terminal |
| `n,t` | `<A-i>` | Toggle floating terminal |
| `t` | `<Esc><Esc>` | Exit terminal mode |
| `n,t` | `<leader>tq` | Close terminal buffer |

## Formatting and Comments

| Mode | Key | Action |
|------|-----|--------|
| `n,x` | `<leader>fm` | Format file or selection |
| `n` | `<leader>/` | Toggle comment |
| `v` | `<leader>/` | Toggle comment |

## LSP Mappings

These are explicit mappings from the active config. Most of them only exist after an LSP attaches to the current buffer.

| Mode | Key | Action |
|------|-----|--------|
| `n` | `gd` | Go to definition |
| `n` | `gD` | Go to declaration |
| `n` | `<leader>D` | Go to type definition |
| `n` | `<leader>ra` | Rename symbol |
| `n` | `<leader>wa` | Add workspace folder |
| `n` | `<leader>wr` | Remove workspace folder |
| `n` | `<leader>wl` | List workspace folders |
| `n` | `<leader>ds` | Put diagnostics into location list |

## FPGA Tasks

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<F5>` | VHDL compile |
| `n` | `<F6>` | VHDL simulate (GUI) |
| `n` | `<F7>` | VHDL run batch |
| `n` | `<leader>vc` | Task: VHDL compile |
| `n` | `<leader>vr` | Task: VHDL run (batch) |
| `n` | `<leader>vg` | Task: VHDL simulate (GUI) |
| `n` | `<leader>vv` | Task: generate `vhdl_ls.toml` |
| `n` | `<leader>vot` | Open associated testbench |
| `n` | `<leader>vos` | Open associated syntest |
| `n` | `<leader>vsc` | Run `vsg-check` |
| `n` | `<leader>vsf` | Run `vsg-fix` |
| `n` | `<leader>fm` | Format buffer with conform (VHDL: vsg `--fix` with the repo rule file; other filetypes also format on save) |
| `n` | `<leader>vqo` | Open fwlibs Quartus project |

## Jumps (flash.nvim)

| Mode | Key | Action |
|------|-----|--------|
| `n`, `x`, `o` | `s` + chars | Type 1–2 characters, then the label shown at the match to jump there |
| `n`, `x`, `o` | `S` | Select a treesitter node (function, block, …); repeat to grow |
| `o` | `r` | Remote: run the operator at a jump target, e.g. `yr` + label + `iw` yanks a word elsewhere |
| `o`, `x` | `R` | Treesitter search: operator on a node picked by search |
| `n` | `f` `F` `t` `T` | As in Vim, with labels on further matches |
| `n` | `zc` `zo` `zM` `zR` | Fold / unfold (folds come from treesitter, everything open on load) |

## Built-in Vim Motions

These are not custom mappings, but they are useful defaults that remain available:

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<C-o>` | Jump back |
| `n` | `<C-i>` | Jump forward |
| `n` | `<C-]>` | Jump to tag |

Notes:
- `<C-i>` is commonly indistinguishable from `<Tab>` in terminal Neovim.
- `<C-s>` was removed in favor of `<leader>fs` because terminal flow control often makes `Ctrl+s` unreliable.

## Useful Commands

| Command | Action |
|---------|--------|
| `:PeekOpen` | Markdown preview with live reload (browser tab) |
| `:PeekClose` | Close that preview |
| `:LspInfo` | Show attached LSP servers |
| `:Mason` | Open Mason |
| `:Lazy` | Open Lazy plugin manager |
| `:checkhealth` | Run Neovim health checks |

## The Nvim Tutorial (built-in training course)

Interactive course from total basics to power user, integrated with
the native `:Tutor` command. Files live in `tutor/` (usage guide:
`tutor/README.md`); exercises show ✓/✗ signs live as you solve them.
Buffers are unwritable — break anything, `:Tutorial` resets.

Quick start: `:Tutorial` opens the overview, `:Tutorial 01-basics`
jumps to a chapter. Note that bare `:Tutor` without an argument opens
Neovim's stock beginner tutorial instead — that is stock behavior.

| Command | Chapter |
|---------|---------|
| `:Tutorial` | Course overview and training rules |
| `:Tutorial 01-basics` | Modes, movement, edits, search, NvChad keys |
| `:Tutorial 02-motions` | Precision motions (f/t, word/WORD, counts, %) |
| `:Tutorial 03-operators` | Operators + text objects, the dot command |
| `:Tutorial 04-registers` | Registers, yank register, expression register |
| `:Tutorial 05-search` | Search, cgn, :substitute, :global |
| `:Tutorial 06-macros` | Macros: record, edit, apply via :g |
| `:Tutorial 07-navigation` | Marks, jumplist, buffers, windows, quickfix |
| `:Tutorial 08-visualblock` | Visual block, increment, g Ctrl-a sequences |
| `:Tutorial 09-ide` | LSP, Telescope, gitsigns on this exact config |

After editing a chapter's text, regenerate the check files:
`python3 tutor/build_expects.py`
