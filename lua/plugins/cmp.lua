return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    version = false,
    dependencies = {
      -- LSP completion
      "hrsh7th/cmp-nvim-lsp",
      -- sources
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- snippets engine (simple y estable)
      "L3MON4D3/LuaSnip",
      -- snippets list
      "rafamadriz/friendly-snippets",
      -- cmp <-> luasnip
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- carga snippets de friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),

          -- Enter confirma (sin LazyVim)
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- Tab navega / snippets
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
      })

      -- ✅ Importante: capabilities para LSP (sin LazyVim)
      local caps = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      vim.lsp.config("*", { capabilities = caps })
    end,
  },
}
