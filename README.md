# dotfiles

Neovim config managed with [chezmoi](https://chezmoi.io). Installs nvim + all dependencies automatically on any Linux VM.

## Bootstrap a new VM

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply whymindswhyminds/dotfiles
```

This installs:
- `nvim` (stable binary)
- `ripgrep`, `fd` — telescope search
- `gcc`, `make`, `g++` — tree-sitter + fzf-native compilation
- `nodejs`, `npm` — pyright LSP
- `python3`, `pip`, `debugpy` — Python LSP + DAP debugging
- `lazygit` — git UI (`<leader>gg`)
- `unzip`, `wget`, `curl`, `git`

## First launch

```bash
nvim
```

lazy.nvim auto-installs all plugins on first open. Then run:

```
:TSUpdate
```

## Keeping VMs in sync

After changing your nvim config locally on Mac:

```bash
chezmoi add ~/.config/nvim
cd ~/.local/share/chezmoi && git add -A && git commit -m "update nvim config" && git push
```

On the VM:

```bash
chezmoi update
```

## Installed tools at a glance

| Tool | Purpose |
|------|---------|
| `nvim` | Editor |
| `ripgrep` | `<leader>sg` live grep |
| `fd` | `<leader>sf` file search |
| `lazygit` | `<leader>gg` git UI |
| `nodejs` | pyright LSP server |
| `debugpy` | Python DAP debugging |
| `gcc/make` | tree-sitter parser builds |
