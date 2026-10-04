#!/usr/bin/env bash
# Build a patched tree-sitter markdown parser into ~/.config/nvim/parser/.
#
# Upstream tree-sitter-markdown treats an all-empty table row (`|  |  |  |`)
# as a delimiter row, so the row above it looks like the header of a new
# table and the real table falls apart into ERROR nodes. markview then draws
# broken borders. The fwcom block docs use such spacer rows everywhere.
# markdown-empty-row.patch makes the scanner require a '-' in every
# delimiter cell.
#
# The config dir comes first on 'runtimepath', so parser/markdown.so here
# shadows the one nvim-treesitter installs and survives :TSUpdate. Re-run
# after nvim-treesitter bumps the markdown revision.
set -euo pipefail

config=$(dirname "$(dirname "$(realpath "$0")")")
parsers=$HOME/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/parsers.lua
rev=$(awk '/^  markdown = \{/{f=1} f && /revision/{gsub(/[^0-9a-f]/,"",$3); print $3; exit}' "$parsers")
[[ -n $rev ]] || { echo "markdown revision not found in $parsers" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

git -C "$work" init -q
git -C "$work" fetch -q --depth 1 https://github.com/tree-sitter-grammars/tree-sitter-markdown "$rev"
git -C "$work" checkout -q FETCH_HEAD
git -C "$work" apply "$config/scripts/markdown-empty-row.patch"

mkdir -p "$config/parser"
(cd "$work/tree-sitter-markdown" && tree-sitter build -o "$config/parser/markdown.so")
echo "built parser/markdown.so from tree-sitter-markdown@${rev:0:7} (patched)"
