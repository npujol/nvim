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
├── .neoconf.json                 # Neodev/lua_ls config for plugin development
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
│       ├── color.lua             # Colorscheme + nvim-colorizer
│       └── ...
├── colors/
│   └── nai.lua                   # Custom "nai" colorscheme (base16-based)
└── file-examples/                # Ignored - example files for testing
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

**Loading strategy**: LazyVim plugins lazy-load by default. Custom user plugins load on startup (eager) by default unless `lazy = true` is set. Notable exception: Obsidian is configured with `lazy = true, ft = "markdown"` to defer loading until markdown files are opened.

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

### LazyVim Extras Management

LazyVim extras are configured in `lazyvim.json`. To modify:

```bash
# Edit lazyvim.json to add/remove extras
# Or use :LazyExtras command in Neovim
```

Current extras: docker, git, go, json, markdown, nix, python, toml, yaml, refactoring, prettier, eslint, `lazyvim.plugins.extras.ui.treesitter-context`

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

`lua/plugins/yaml.lua` contains extensive schema mappings for validation. Available schemas include:
- **Kubernetes** manifests (*.k8s.yaml, kube*.yaml)
- **GitHub Actions** (*.github/workflows/)
- **Ansible** playbooks and configurations
- **Docker Compose** (docker-compose.yml)
- **GitLab CI** (.gitlab-ci.yml)
- **OpenAPI** specifications
- **Argo Workflows** (argo-*.yaml)

Schemas are automatically applied based on file patterns. To add new schemas, map file patterns to JSON schema URLs in `lua/plugins/yaml.lua`.

### Obsidian Integration

Workspace paths are configured in `lua/plugins/obsidian.lua`. The plugin dynamically validates workspace directories before loading - only workspaces that exist on the filesystem are activated. Blink completion integration is enabled for vault references.

To add new vaults, extend the `potential_workspaces` table with new directory paths. The plugin will automatically detect and load them if the directories exist.

### AI Assistant Configuration

Three AI systems are configured:

**CodeCompanion** (`lua/plugins/ai.lua`):
- Uses local Ollama instance for chat and inline code suggestions
- Adapter can be switched to `llamaserver` or `gemini` providers
- Triggered via CodeCompanion keybindings (defined in plugin config)

**Claude Code** (`lua/plugins/claude.lua`):
- Anthropic's official Claude integration for Neovim
- Enables Claude Code commands and workflows within the editor
- Alternative plugin `coder/claudecode.nvim` available if needed

To change AI providers, modify the adapter configuration in `lua/plugins/ai.lua`. The Ollama adapter is set to use local instance, suitable for offline development.

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

Custom colorscheme "nai" is defined in `colors/nai.lua` using base16 color definitions. The colorscheme depends on **base16-nvim** plugin which must load with high priority (`priority = 1000`) before other UI plugins.

To modify the colorscheme:
- Edit `colors/nai.lua` to change the 16 base16 color values
- Change `colorscheme = "nai"` in `lua/plugins/color.lua` to switch themes

Fallback themes: tokyonight, habamax

Additional plugin **nvim-colorizer.lua** is also configured in `lua/plugins/color.lua` to show color previews inline for color codes in documents.

## Git Workflow

Git integration via vim-fugitive (`lua/plugins/fugitive.lua`). Standard git commands work from the repository root:

```bash
git status
git add .
git commit -m "message"
git push
```

## Performance Optimizations

Several performance optimizations are configured in `lua/config/lazy.lua`:

**Disabled RTP Plugins** (loaded by default in Vim, disabled here):
- `gzip`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`

These are rarely used in modern development workflows and are disabled to reduce startup time.

**Loading Strategy**:
- LazyVim's own plugins are lazy-loaded on-demand
- Custom user plugins load eagerly by default (fast startup, all features available)
- Obsidian is the exception: configured with `lazy = true` to defer loading until markdown files

**Plugin Priority**:
- `base16-nvim` has `priority = 1000` to ensure it loads before UI plugins that depend on colorschemes

## Neodev Configuration

`.neoconf.json` configures development support for Neovim plugin development:
- **neodev**: Enables Neovim-specific library support
- **lua_ls**: Configures the Lua language server for plugin development

This setup is useful when developing or modifying Neovim plugins and configurations. The lua_ls integration provides type hints and autocompletion for Neovim/Lua APIs.

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
- to memorize @CLAUDE.md
- to memorize @CLAUDE.md