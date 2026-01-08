# Neovim Keybindings Reference

## LSP Keybindings (for VHDL and all languages)

| Key | Action |
|-----|--------|
| `gd` | **Go to definition** - jumps to where symbol is defined |
| `gD` | **Go to declaration** - jumps to declaration |
| `gr` | **Go to references** - find all usages (built-in nvim 0.11) |
| `gi` | **Go to implementation** (built-in nvim 0.11) |
| `K` | **Hover** - shows documentation/info (built-in nvim 0.11) |
| `<leader>D` | Go to **type definition** |
| `<leader>ra` | **Rename** symbol across project |
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |
| `<leader>ds` | Show diagnostics in location list |
| `<leader>fm` | **Format** file |

## Navigation (Jump List)

| Key | Action |
|-----|--------|
| `<C-o>` | Jump **back** (after gd) |
| `<C-i>` | Jump **forward** |
| `<C-]>` | Jump to tag (alternative) |

## VHDL Library Navigation

For `gd` to work with IEEE/standard libraries, configure `vhdl_ls.toml` in your project root:

```toml
[libraries]
work.files = ["src/**/*.vhd"]

# Point to your VHDL standard library sources (if you have them)
ieee.files = ["/path/to/ieee/*.vhd"]
std.files = ["/path/to/std/*.vhd"]
```

## Telescope (Fuzzy Finding)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fa` | Find all files (including hidden) |
| `<leader>fw` | **Live grep** (search text in project) |
| `<leader>fg` | Live grep (custom) |
| `<leader>fb` | Find buffers |
| `<leader>fo` | Find old/recent files |
| `<leader>fz` | Fuzzy find in current buffer |
| `<leader>fh` | Help tags |
| `<leader>ma` | Find marks |
| `<leader>cm` | Git commits |
| `<leader>gt` | Git status |
| `<leader>pt` | Pick hidden terminal |

## File Explorer (NvimTree)

| Key | Action |
|-----|--------|
| `<C-n>` | Toggle NvimTree |
| `<leader>e` | Focus NvimTree |

## Buffers/Tabs

| Key | Action |
|-----|--------|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<leader>x` | Close buffer |
| `<leader>b` | New buffer |

## Terminal

| Key | Action |
|-----|--------|
| `<leader>h` | New horizontal terminal |
| `<leader>v` | New vertical terminal |
| `<A-i>` | Toggle floating terminal |
| `<A-h>` | Toggle horizontal terminal |
| `<A-v>` | Toggle vertical terminal |
| `<C-x>` | Escape terminal mode |

## Comments

| Key | Action |
|-----|--------|
| `<leader>/` | Toggle comment (normal mode) |
| `<leader>/` | Toggle comment (visual mode) |

## Window Navigation

| Key | Action |
|-----|--------|
| `<C-h>` | Move to left split |
| `<C-j>` | Move to split below |
| `<C-k>` | Move to split above |
| `<C-l>` | Move to right split |

## Insert Mode Navigation

| Key | Action |
|-----|--------|
| `<C-b>` | Move to beginning of line |
| `<C-e>` | Move to end of line |
| `<C-h>` | Move left |
| `<C-l>` | Move right |
| `<C-j>` | Move down |
| `<C-k>` | Move up |

## General

| Key | Action |
|-----|--------|
| `;` | Enter command mode (custom) |
| `jk` | Escape (insert mode, custom) |
| `<C-s>` | Save file |
| `<C-c>` | Copy whole file |
| `<Esc>` | Clear search highlights |
| `<leader>n` | Toggle line numbers |
| `<leader>rn` | Toggle relative line numbers |

## Help & Discovery

| Key | Action |
|-----|--------|
| `<leader>ch` | **NvChad cheatsheet** |
| `<leader>th` | Theme picker |
| `<leader>wK` | Show all WhichKey keymaps |
| `<leader>wk` | WhichKey query lookup |

## Useful Commands

| Command | Action |
|---------|--------|
| `:LspInfo` | Show attached LSP servers |
| `:Mason` | Open Mason (LSP/tool installer) |
| `:Lazy` | Open Lazy plugin manager |
| `:TSInstall <lang>` | Install treesitter parser |
| `:checkhealth` | Check Neovim health |
