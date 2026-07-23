return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "lua", "c", "cpp", "python" },
        auto_install = true,

        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
