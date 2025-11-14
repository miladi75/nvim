# NvChad Keybindings Cheatsheet

Complete guide to all keybindings in your NvChad configuration.

**Legend:**
- `<leader>` = Space
- `<C>` = Ctrl
- `<A>` = Alt
- `<S>` = Shift

---

## General

| Mode | Keybinding | Action | Description |
|------|------------|--------|-------------|
| n | `;` | `:` | Enter command mode |
| i | `jk` | `<ESC>` | Exit insert mode (custom) |
| n | `<Esc>` | Clear highlights | Remove search highlights |
| n | `<C-s>` | Save file | Write current buffer |
| n | `<C-c>` | Copy whole file | Yank entire file to clipboard |
| n | `<leader>n` | Toggle line numbers | Show/hide line numbers |
| n | `<leader>rn` | Toggle relative numbers | Show/hide relative line numbers |
| n | `<leader>ch` | Open NvCheatsheet | Display keybinding cheatsheet |

---

## Navigation (Insert Mode)

| Mode | Keybinding | Action |
|------|------------|--------|
| i | `<C-b>` | Move to beginning of line |
| i | `<C-e>` | Move to end of line |
| i | `<C-h>` | Move left |
| i | `<C-l>` | Move right |
| i | `<C-j>` | Move down |
| i | `<C-k>` | Move up |

---

## Window Management

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<C-h>` | Switch to left window |
| n | `<C-l>` | Switch to right window |
| n | `<C-j>` | Switch to window below |
| n | `<C-k>` | Switch to window above |

---

## Buffer Management

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<leader>b` | New buffer |
| n | `<Tab>` | Go to next buffer |
| n | `<S-Tab>` | Go to previous buffer |
| n | `<leader>x` | Close current buffer |

---

## File Explorer (nvim-tree)

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<C-n>` | Toggle file tree |
| n | `<leader>e` | Toggle file tree (custom) |

**Within nvim-tree:**
- `a` - Create new file/folder
- `d` - Delete file/folder
- `r` - Rename file/folder
- `x` - Cut file/folder
- `c` - Copy file/folder
- `p` - Paste file/folder
- `y` - Copy filename
- `Y` - Copy relative path
- `gy` - Copy absolute path
- `q` - Close tree
- `R` - Refresh tree
- `H` - Toggle hidden files
- `<CR>` - Open file

---

## Telescope (Fuzzy Finder)

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<leader>ff` | Find files |
| n | `<leader>fa` | Find all files (including hidden) |
| n | `<leader>fw` | Live grep (search in files) |
| n | `<leader>fb` | Find buffers |
| n | `<leader>fh` | Help tags |
| n | `<leader>fo` | Find old files (recent) |
| n | `<leader>fz` | Fuzzy find in current buffer |
| n | `<leader>ma` | Find marks |
| n | `<leader>cm` | Git commits |
| n | `<leader>gt` | Git status |
| n | `<leader>pt` | Pick hidden terminal |
| n | `<leader>th` | NvChad themes picker |

**Within Telescope:**
- `<C-n>` / `<Down>` - Next item
- `<C-p>` / `<Up>` - Previous item
- `<C-c>` / `<Esc>` - Close Telescope
- `<CR>` - Select item
- `<C-x>` - Open in horizontal split
- `<C-v>` - Open in vertical split
- `<C-t>` - Open in new tab
- `<C-u>` - Scroll preview up
- `<C-d>` - Scroll preview down

---

## Comments

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<leader>/` | Toggle comment on current line |
| v | `<leader>/` | Toggle comment on selection |

---

## Code Formatting

| Mode | Keybinding | Action |
|------|------------|--------|
| n, v | `<leader>fm` | Format file/selection |

---

## LSP (Language Server Protocol)

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<leader>ds` | Show diagnostics in location list |
| n | `gD` | Go to declaration |
| n | `gd` | Go to definition |
| n | `K` | Hover documentation |
| n | `gi` | Go to implementation |
| n | `<leader>sh` | Signature help |
| n | `<leader>D` | Type definition |
| n | `<leader>ra` | Rename symbol |
| n | `<leader>ca` | Code actions |
| n | `gr` | Show references |
| n | `<leader>lf` | Format buffer |
| n | `[d` | Previous diagnostic |
| n | `]d` | Next diagnostic |
| n | `<leader>q` | Set location list |
| n | `<leader>wa` | Add workspace folder |
| n | `<leader>wr` | Remove workspace folder |
| n | `<leader>wl` | List workspace folders |

---

## Terminal

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<leader>h` | New horizontal terminal |
| n | `<leader>v` | New vertical terminal |
| n, t | `<A-h>` | Toggle horizontal terminal |
| n, t | `<A-v>` | Toggle vertical terminal |
| n, t | `<A-i>` | Toggle floating terminal |
| t | `<C-x>` | Exit terminal mode (to normal) |

---

## WhichKey

| Mode | Keybinding | Action |
|------|------------|--------|
| n | `<leader>wK` | Show all keymaps |
| n | `<leader>wk` | Query specific keymap |

---

## Tips & Tricks

### Essential Workflows

**Opening Files:**
1. `<leader>ff` - Find files by name
2. `<leader>fw` - Search file contents
3. `<leader>fo` - Open recent files

**Working with Code:**
1. `gd` - Jump to definition
2. `K` - View documentation
3. `<leader>ca` - Quick fixes/refactoring
4. `<leader>fm` - Format code

**Buffer Navigation:**
1. `<Tab>` / `<S-Tab>` - Cycle through open files
2. `<leader>x` - Close current buffer
3. `<leader>b` - Open new buffer

**Terminal Usage:**
1. `<A-i>` - Quick floating terminal
2. `<C-x>` - Exit terminal mode
3. `<A-i>` again - Hide terminal (toggleable)

### Vim Basics (Still Important!)

- `i` - Insert mode
- `v` - Visual mode
- `V` - Visual line mode
- `<C-v>` - Visual block mode
- `:w` - Save
- `:q` - Quit
- `:wq` - Save and quit
- `u` - Undo
- `<C-r>` - Redo
- `dd` - Delete line
- `yy` - Yank (copy) line
- `p` - Paste
- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

---

## Customization

To add your own keybindings, edit: `~/.config/nvim/lua/mappings.lua`

Example:
```lua
local map = vim.keymap.set

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
map("i", "jj", "<ESC>", { desc = "Alternative escape" })
```

---

## Need Help?

- Press `<leader>ch` to open NvChad's built-in cheatsheet
- Press `<leader>wK` to see all available keymaps
- Visit: https://nvchad.com/docs/config/mappings

---

**Last Updated:** November 14, 2025
**NvChad Version:** v2.5
