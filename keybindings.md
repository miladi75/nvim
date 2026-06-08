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

## Markdown Preview

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<leader>mp` | Open Markdown preview in browser |
| `n` | `<leader>po` | Open Markdown preview in browser |
| `n` | `<leader>mc` | Close Markdown preview |

Commands:
- `:PeekOpen`
- `:PeekClose`

## Git

| Mode | Key | Action |
|------|-----|--------|
| `n` | `<leader>gb` | Git blame line |
| `n` | `<leader>gB` | Toggle current line blame |
| `n` | `<leader>gh` | Preview hunk |
| `n` | `<leader>gs` | Stage hunk |
| `n` | `<leader>gr` | Reset hunk |
| `n` | `<leader>gv` | Open Diffview |
| `n` | `<leader>gV` | Diffview file history for current file |

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
| `n` | `<leader>vs` | Task: VHDL simulate |
| `n` | `<leader>vv` | Task: generate `vhdl_ls.toml` |
| `n` | `<leader>vot` | Open associated testbench |
| `n` | `<leader>vos` | Open associated syntest |
| `n` | `<leader>vsc` | Run `vsg-check` |
| `n` | `<leader>vsf` | Run `vsg-fix` |
| `n` | `<leader>vqo` | Open fwlibs Quartus project |

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
| `:PeekOpen` | Open Markdown preview |
| `:PeekClose` | Close Markdown preview |
| `:LspInfo` | Show attached LSP servers |
| `:Mason` | Open Mason |
| `:Lazy` | Open Lazy plugin manager |
| `:checkhealth` | Run Neovim health checks |
