return {
  {
    "folke/tokyonight.nvim",
    lazy = false,      -- que cargue al inicio
    priority = 1000,   -- antes que otros plugins
    opts = {
      style = "night", -- ✅ night / storm / moon / day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
