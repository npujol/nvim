-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Pi (kitten panel) integration
local pi_panel_id = nil

local function get_project_root()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" or vim.bo[bufnr].buftype ~= "" then
    return vim.fn.expand "~"
  end
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients > 0 then
    for _, client in ipairs(clients) do
      if client.config.root_dir then
        return client.config.root_dir
      end
    end
  end
  local git_root = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(vim.fn.expand "%:p:h") .. " rev-parse --show-toplevel"
  )[1]
  if git_root and vim.v.shell_error == 0 then
    return git_root
  end
  if bufname ~= "" then
    return vim.fn.expand "%:p:h"
  else
    return vim.fn.expand "~"
  end
end

local function is_panel_alive()
  if not pi_panel_id then return false end
  local result = vim.system({ "kitten", "@", "ls" }):wait()
  if result.code ~= 0 then
    pi_panel_id = nil
    return false
  end
  local is_alive = string.find(result.stdout, "id:" .. pi_panel_id) ~= nil or string.find(result.stdout, pi_panel_id) ~= nil
  if not is_alive then pi_panel_id = nil end
  return is_alive
end

local function ensure_panel_exists()
  if is_panel_alive() then return true end
  local root_dir = get_project_root()
  local result = vim.system({ "kitten", "@", "launch", "--type=window", "--cwd=" .. root_dir, "/run/current-system/sw/bin/pi" }):wait()
  if result.code ~= 0 then
    vim.notify("Failed to create Kitty panel: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
    return false
  end
  pi_panel_id = result.stdout:match("id:(%d+)") or result.stdout:match("(%d+)")
  if not pi_panel_id then
    vim.notify("Failed to extract panel ID from: " .. result.stdout, vim.log.levels.ERROR)
    return false
  end
  return true
end

local function pi_send(text)
  if not ensure_panel_exists() then
    vim.notify("Failed to create or connect to Kitty panel", vim.log.levels.ERROR)
    return
  end
  vim.system({ "kitten", "@", "send-text", "--match", "id:" .. pi_panel_id, "--stdin" }, { stdin = text }):wait()
end

local function pi_send_range(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":p") or "[No Name]"
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype == "" then filetype = "text" end
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local content = table.concat(lines, "\n")
  local text = string.format(
    "Given this fragment of %s in the range from line %d to %d:\n\n```%s\n%s\n```\n",
    display_name, first_line, last_line, filetype, content
  )
  pi_send(text)
end

vim.keymap.set("v", "<leader><leader>r", function()
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."
  if start_line > end_line then start_line, end_line = end_line, start_line end
  pi_send_range(start_line, end_line)
end, { desc = "Send selection to Pi" })

vim.keymap.set("n", "<leader><leader>r", function()
  pi_send_range(vim.fn.line ".", vim.fn.line ".")
end, { desc = "Send current line to Pi" })

local function pi_send_diagnostics(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":p") or "[No Name]"
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = first_line - 1, end_lnum = last_line - 1 })
  if #diagnostics == 0 then
    vim.notify("No diagnostics in the specified range", vim.log.levels.INFO)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local content = table.concat(lines, "\n")
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype == "" then filetype = "text" end
  local diag_text = {}
  table.insert(diag_text, string.format("Diagnostics for %s (lines %d-%d):\n", display_name, first_line, last_line))
  for _, diag in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diag.severity]
    local line_num = diag.lnum + 1
    table.insert(diag_text, string.format("- Line %d [%s]: %s", line_num, severity, diag.message))
    if diag.source then
      table.insert(diag_text, string.format("  Source: %s", diag.source))
    end
  end
  table.insert(diag_text, string.format("\nCode:\n```%s\n%s\n```\n", filetype, content))
  pi_send(table.concat(diag_text, "\n"))
end

vim.keymap.set("v", "<leader><leader>d", function()
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."
  if start_line > end_line then start_line, end_line = end_line, start_line end
  pi_send_diagnostics(start_line, end_line)
end, { desc = "Send diagnostics for selection to Pi" })

vim.keymap.set("n", "<leader><leader>d", function()
  pi_send_diagnostics(1, vim.api.nvim_buf_line_count(0))
end, { desc = "Send diagnostics for buffer to Pi" })

-- Claudito (kitten panel) integration
local claudito_panel_id = nil

local function is_claudito_panel_alive()
  if not claudito_panel_id then return false end
  local result = vim.system({ "kitten", "@", "ls" }):wait()
  if result.code ~= 0 then
    claudito_panel_id = nil
    return false
  end
  local is_alive = string.find(result.stdout, "id:" .. claudito_panel_id) ~= nil or string.find(result.stdout, claudito_panel_id) ~= nil
  if not is_alive then claudito_panel_id = nil end
  return is_alive
end

local function ensure_claudito_panel_exists()
  if is_claudito_panel_alive() then return true end
  local root_dir = get_project_root()
  local result = vim.system({
    "kitten", "@", "launch", "--type=window", "--cwd=" .. root_dir,
    "claude", "--model", "claude-haiku-4-5-20251001",
  }):wait()
  if result.code ~= 0 then
    vim.notify("Failed to create Kitty panel: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
    return false
  end
  claudito_panel_id = result.stdout:match("id:(%d+)") or result.stdout:match("(%d+)")
  if not claudito_panel_id then
    vim.notify("Failed to extract panel ID from: " .. result.stdout, vim.log.levels.ERROR)
    return false
  end
  return true
end

local function claudito_send(text)
  if not ensure_claudito_panel_exists() then
    vim.notify("Failed to create or connect to Kitty panel", vim.log.levels.ERROR)
    return
  end
  vim.system({ "kitten", "@", "send-text", "--match", "id:" .. claudito_panel_id, "--stdin" }, { stdin = text }):wait()
end

local function claudito_send_range(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":p") or "[No Name]"
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype == "" then filetype = "text" end
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local content = table.concat(lines, "\n")
  local text = string.format(
    "Be concret change only the minimum. KISS principle. Dont test it I'll do it. Given this fragment of %s in the range from line %d to %d:\n\n```%s\n%s\n```\n",
    display_name, first_line, last_line, filetype, content
  )
  claudito_send(text)
end

vim.keymap.set("v", "<leader><leader><leader>r", function()
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."
  if start_line > end_line then start_line, end_line = end_line, start_line end
  claudito_send_range(start_line, end_line)
end, { desc = "Send selection to Claudito" })

vim.keymap.set("n", "<leader><leader><leader>r", function()
  claudito_send_range(vim.fn.line ".", vim.fn.line ".")
end, { desc = "Send current line to Claudito" })

local function claudito_send_diagnostics(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":p") or "[No Name]"
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = first_line - 1, end_lnum = last_line - 1 })
  if #diagnostics == 0 then
    vim.notify("No diagnostics in the specified range", vim.log.levels.INFO)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local content = table.concat(lines, "\n")
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype == "" then filetype = "text" end
  local diag_text = {}
  table.insert(diag_text, string.format("Diagnostics for %s (lines %d-%d):\n", display_name, first_line, last_line))
  for _, diag in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diag.severity]
    local line_num = diag.lnum + 1
    table.insert(diag_text, string.format("- Line %d [%s]: %s", line_num, severity, diag.message))
    if diag.source then
      table.insert(diag_text, string.format("  Source: %s", diag.source))
    end
  end
  table.insert(diag_text, string.format("\nCode:\n```%s\n%s\n```\n", filetype, content))
  claudito_send(table.concat(diag_text, "\n"))
end

vim.keymap.set("v", "<leader><leader><leader>d", function()
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."
  if start_line > end_line then start_line, end_line = end_line, start_line end
  claudito_send_diagnostics(start_line, end_line)
end, { desc = "Send diagnostics for selection to Claudito" })

vim.keymap.set("n", "<leader><leader><leader>d", function()
  claudito_send_diagnostics(1, vim.api.nvim_buf_line_count(0))
end, { desc = "Send diagnostics for buffer to Claudito" })
