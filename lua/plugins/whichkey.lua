return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "helix",
    defaults = {},
    spec = {
      {
        mode = { "n", "x" },

        { "<leader><tab>", group = "pestañas" },
        { "<leader>c", group = "código" },
        { "<leader>d", group = "depuración" },
        { "<leader>dp", group = "perfilador" },
        { "<leader>f", group = "archivos / buscar" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "cambios (hunks)" },
        { "<leader>q", group = "salir / sesión" },
        { "<leader>s", group = "buscar" },
        { "<leader>u", group = "interfaz (UI)" },
        { "<leader>x", group = "diagnósticos / quickfix" },

        { "[", group = "anterior" },
        { "]", group = "siguiente" },
        { "g", group = "ir a" },
        { "gs", group = "rodear (surround)" },
        { "z", group = "plegado (fold)" },

        {
          "<leader>b",
          group = "buffers",
          expand = function()
            return require("which-key.extras").expand.buf()
          end,
        },
        {
          "<leader>w",
          group = "ventanas",
          proxy = "<c-w>",
          expand = function()
            return require("which-key.extras").expand.win()
          end,
        },

        -- mejores descripciones
        { "gx", desc = "Abrir con la app del sistema" },
      },
    },
  },

  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Atajos del buffer (which-key)",
    },
    {
      "<c-w><space>",
      function()
        require("which-key").show({ keys = "<c-w>", loop = true })
      end,
      desc = "Modo Hydra de ventanas (which-key)",
    },
  },

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    if not vim.tbl_isempty(opts.defaults) then
      LazyVim.warn("which-key: opts.defaults is deprecated. Please use opts.spec instead.")
      wk.register(opts.defaults)
    end
  end,
}
