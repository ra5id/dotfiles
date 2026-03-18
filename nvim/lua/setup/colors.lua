
-- ==============================
-- Colors & Theme Configuration
-- ==============================

-- Enable true color support
vim.opt.termguicolors = true

-- ------------------------------
-- One Dark base configuration
-- ------------------------------
require("onedark").setup({
  style = "dark",        -- options: dark, darker, cool, deep, warm
  transparent = false,   -- set true if you want transparent bg

  code_style = {
    comments = "italic",
    functions = "bold",
    keywords = "none",
    strings = "none",
    variables = "none",
  },

  diagnostics = {
    darker = true,
    undercurl = true,
    background = true,
  },
})

-- Apply the colorscheme
vim.cmd.colorscheme("onedark")

-- ------------------------------
-- Custom highlight overrides
-- (ALWAYS after colorscheme)
-- ------------------------------

-- Comments
vim.api.nvim_set_hl(0, "Comment", {
  fg = "#7f848e",
  italic = true,
})

-- Functions
vim.api.nvim_set_hl(0, "Function", {
  fg = "#61afef",
  bold = true,
})

-- Types (int, float, class, struct, vec3, etc.)
vim.api.nvim_set_hl(0, "Type", {
  fg = "#56b6c2",
})

-- Strings
vim.api.nvim_set_hl(0, "String", {
  fg = "#98c379",
})

-- Numbers
vim.api.nvim_set_hl(0, "Number", {
  fg = "#d19a66",
})

-- Keywords (if you want them slightly clearer)
vim.api.nvim_set_hl(0, "Keyword", {
  fg = "#c678dd",
})

-- Constants / macros
vim.api.nvim_set_hl(0, "Constant", {
  fg = "#e5c07b",
})

-- ------------------------------
-- UI tweaks (safe & minimal)
-- ------------------------------

-- Line numbers
vim.api.nvim_set_hl(0, "LineNr", {
  fg = "#5c6370",
})

vim.api.nvim_set_hl(0, "CursorLineNr", {
  fg = "#abb2bf",
  bold = true,
})

-- Cursor line
vim.api.nvim_set_hl(0, "CursorLine", {
  bg = "#2c313a",
})

-- Visual selection
vim.api.nvim_set_hl(0, "Visual", {
  bg = "#3e4452",
})

-- Search highlight
vim.api.nvim_set_hl(0, "Search", {
  fg = "#1e222a",
  bg = "#e5c07b",
})

vim.api.nvim_set_hl(0, "IncSearch", {
  fg = "#1e222a",
  bg = "#61afef",
})

