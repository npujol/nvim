-- markdownlint-cli2 only discovers config in the file's dir/ancestors, no $HOME
-- fallback, so pin the global config explicitly for repos without their own.
return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function()
      local linter = require("lint").linters["markdownlint-cli2"]
      linter.args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "-" }
    end,
  },
}
