return {
  -- Mason (UI + instalar herramientas)
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    opts = {
      ui = { border = "rounded" },
      ensure_installed = {
        -- herramientas (no LSP)
        "stylua",
        "shfmt",

        -- Java extras (opcionales pero útiles con nvim-jdtls)
        "java-test",
        "java-debug-adapter",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      -- instalar automáticamente lo de ensure_installed
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, name in ipairs(opts.ensure_installed or {}) do
          local ok, pkg = pcall(mr.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },

  -- Mason-lspconfig (instalar LSP servers)
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "bashls",
        "dockerls",
        "graphql",
        "jdtls",
        "jsonls",
        "lua_ls",
        "marksman",
        "pyright",
        "sqlls",
        "yamlls",
        -- ✅ Java LSP
      },
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },
}

