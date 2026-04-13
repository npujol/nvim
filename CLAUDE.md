# CLAUDE.md

## Architecture Overview

This is a Neovim configuration built on **LazyVim**, a modern Neovim starter template. The configuration uses **Lazy.nvim** as the plugin manager and follows a modular structure where custom plugins extend or override LazyVim defaults.

### Directory Structure

```bash
tree
```

### Initialization Flow

1. `init.lua` → requires `config.lazy`
2. `lua/config/lazy.lua` → bootstraps Lazy.nvim, loads LazyVim + extras
3. Custom plugins in `lua/plugins/*.lua` → load and override defaults
4. `lua/config/options.lua` → applies Vim settings
5. Keymaps and autocmds load (currently using LazyVim defaults)

### Configuration Override Pattern

Plugins in `lua/plugins/*.lua` follow this pattern:

- **Disable unwanted plugins**: `{ "plugin-name", enabled = false }`
- **Extend existing configs**: `{ "plugin-name", opts = { ... } }`
- **Add new plugins**: `{ "plugin-name", config = function() ... end }`

## Development Workflows

### Plugin Commands Reference

Essential Lazy.nvim and LazyVim commands:

```vim
:Lazy sync        " Install/update all plugins
:Lazy update      " Update all plugins to latest versions
:Lazy clean       " Remove unused plugin directories
:Lazy check       " Check for available updates (runs auto, notifications disabled)
:LazyExtras       " Interactive UI for managing LazyVim extras
```

## Code Formatting

Lua code is formatted with StyLua (configured in `stylua.toml`):

Format manually with: `stylua .`

