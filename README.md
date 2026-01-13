# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Configuration Files

### .neoconf.json

The `.neoconf.json` file configures Neovim development support for plugin development:

```json
{
  "neodev": {
    "library": {
      "enabled": true,
      "plugins": true
    }
  },
  "neoconf": {
    "plugins": {
      "lua_ls": {
        "enabled": true
      }
    }
  }
}
```

**What it does:**

- **neodev.library.enabled**: Enables the Neovim standard library support, providing type definitions and documentation for Neovim APIs
- **neodev.library.plugins**: Enables type definitions for installed Neovim plugins, allowing autocomplete and type checking for plugin APIs
- **lua_ls**: Enables the Lua Language Server integration through neoconf, which provides:
  - Type hints and autocompletion for Neovim/Lua APIs
  - Inline documentation and symbol information
  - Linting and diagnostics for Lua code

This configuration is particularly useful when developing or modifying Neovim plugins and configurations within this repository.
