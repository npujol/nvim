# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Neovim configuration built on **LazyVim**, a modern Neovim starter template. The configuration uses **Lazy.nvim** as the plugin manager and follows a modular structure where custom plugins extend or override LazyVim defaults.

### Directory Structure

```
/
├── init.lua                      # Entry point - loads lazy.nvim
├── lazy-lock.json                # Locked plugin versions
├── lazyvim.json                  # LazyVim extras configuration
├── stylua.toml                   # Lua formatter config
├── lua/
│   ├── config/                   # Core Neovim configuration
│   │   ├── lazy.lua              # Plugin manager bootstrap
│   │   ├── options.lua           # Vim settings
│   │   ├── keymaps.lua           # Custom keybindings (currently empty)
│   │   └── autocmds.lua          # Autocommands (currently empty)
│   └── plugins/                  # Plugin specifications
│       ├── lspconfig.lua         # LSP server configs (ruff, basedpyright)
│       ├── conform.lua           # Formatter configs (alejandra, jq, goimports, gofmt)
│       ├── ai.lua                # CodeCompanion (Ollama integration)
│       ├── claude.lua            # Claude Code integration
│       ├── obsidian.lua          # Obsidian vault integration
│       ├── yaml.lua              # YAML schema validation
│       ├── tree.lua              # Neo-tree file explorer
│       ├── fugitive.lua          # Git wrapper
│       ├── pytest.lua            # Python test runner
│       └── ...
└── colors/
    └── nai.lua                   # Custom "nai" colorscheme
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

LazyVim plugins lazy-load by default; custom plugins load on startup unless specified otherwise.

## Development Workflows

### LazyVim Extras Management

LazyVim extras are configured in `lazyvim.json`. To modify:

```bash
# Edit lazyvim.json to add/remove extras
# Or use :LazyExtras command in Neovim
```

Current extras: docker, git, go, json, markdown, nix, python, toml, yaml, refactoring, prettier, eslint

### Tool Management

**Important**: Mason (LSP/tool installer) is explicitly disabled:
```lua
{ "mason-org/mason.nvim", enabled = false }
```

Tools are managed externally (system package manager or Nix). When adding LSP servers or formatters, install them system-wide first.

### Adding LSP Servers

Edit `lua/plugins/lspconfig.lua`:
```lua
opts = {
  servers = {
    new_server = {
      settings = {
        -- server-specific settings
      }
    }
  }
}
```

Current LSP servers: `ruff` (Python linter), `basedpyright` (Python type checker)

### Adding Formatters

Edit `lua/plugins/conform.lua`:
```lua
formatters_by_ft = {
  filetype = { "formatter_name" }
}
```

Current formatters: `alejandra` (Nix), `jq` (JSON), `goimports` and `gofmt` (Go), plus LazyVim defaults

Custom formatter definitions (like `golangci_lint`) can be added in the `formatters` section of `lua/plugins/conform.lua`.

### YAML Schema Configuration

`lua/plugins/yaml.lua` contains extensive schema mappings for Kubernetes, GitHub Actions, Ansible, Docker Compose, etc. Add new schemas by mapping file patterns to JSON schema URLs.

### Obsidian Integration

Workspace paths are configured in `lua/plugins/obsidian.lua`. The plugin dynamically validates workspace directories before loading. Add new vaults by extending the `potential_workspaces` table.

### AI Assistant Configuration

Two AI systems are configured:
- **CodeCompanion** (`lua/plugins/ai.lua`): Uses local Ollama instance for chat/inline suggestions
- **Claude Code** (`lua/plugins/claude.lua`): Anthropic's Claude integration

To switch AI providers, modify the adapter settings in `lua/plugins/ai.lua`.

## Code Formatting

Lua code is formatted with StyLua (configured in `stylua.toml`):
- 2-space indentation
- 120-column line width

Format manually with: `stylua .`

## Plugin Development

When adding plugins:
1. Create new file in `lua/plugins/` (e.g., `lua/plugins/myplugin.lua`)
2. Return a table with plugin spec:
   ```lua
   return {
     "author/plugin-name",
     opts = {},
     -- or config = function() ... end
   }
   ```
3. Restart Neovim or run `:Lazy sync`

When disabling LazyVim default plugins, explicitly set `enabled = false` in a plugin spec to avoid conflicts.

## Colorscheme System

Custom colorscheme "nai" is defined in `colors/nai.lua` using base16 color definitions. To modify:
- Edit `colors/nai.lua` for color values
- Change `colorscheme = "nai"` in `lua/plugins/color.lua` to switch themes

Fallback themes: tokyonight, habamax

## Git Workflow

Git integration via vim-fugitive (`lua/plugins/fugitive.lua`). Standard git commands work from the repository root:

```bash
git status
git add .
git commit -m "message"
git push
```

## Go Development

Go tooling configured via LazyVim's go extra:
- **LSP**: gopls (from LazyVim go extra)
- **Formatting**: goimports, gofmt (configured in `lua/plugins/conform.lua`)
- **Linting**: golangci-lint formatter available (run with `--fix` flag)

To use golangci-lint, ensure it's installed system-wide (via `go install` or package manager).

## Python Development

Python tooling configured for:
- **Type checking**: basedpyright LSP (standard mode)
- **Linting/formatting**: ruff LSP
- **Testing**: pytest.nvim with pip3
- **Virtual environments**: venv-selector.nvim (from LazyVim extras)

Python tests can be run from within Neovim using pytest.nvim keybindings.
