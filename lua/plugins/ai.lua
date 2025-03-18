return {
  "olimorris/codecompanion.nvim",
  config = function()
    require("codecompanion").setup({
      strategies = {
        -- Change the default chat adapter
        chat = {
          -- adapter = "llamaserver",
          adapter = "ollama",
        },
        inline = {
          -- adapter = "llamaserver",
          adapter = "ollama",
          -- adapter = "gemini",
        },
      },
      -- adapters = {
      --   llamaserver = function()
      --     return require("codecompanion.adapters").extend("openai_compatible", {
      --       name = "llamaserver",
      --       env = {
      --         url = "http://localhost:8080",
      --         api_key = "meh",
      --       },
      --     })
      --   end,
      -- },
    })
  end,
  -- dependencies = {
  --   "nvim-lua/plenary.nvim",
  --   "nvim-treesitter/nvim-treesitter",
  -- },
}
