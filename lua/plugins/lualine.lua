
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",

  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,

  opts = function()
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    local function has(mod)
      return package.loaded[mod] or pcall(require, mod)
    end

    local Snacks
    pcall(function()
      Snacks = require("snacks")
    end)

    local icons = {
      diagnostics = { Error = " ", Warn = " ", Info = " ", Hint = " " },
      git = { added = " ", modified = " ", removed = " " },
    }

    vim.o.laststatus = vim.g.lualine_laststatus

    local function root_dir()
      local name = vim.api.nvim_buf_get_name(0)
      if name == "" then return "" end
      local dir = vim.fs.dirname(name)
      local root = vim.fs.root(dir, { ".git" })
      if not root then return "" end
      return " " .. vim.fs.basename(root)
    end

    local function pretty_path()
      local name = vim.api.nvim_buf_get_name(0)
      if name == "" then return "[Sin nombre]" end
      return vim.fn.fnamemodify(name, ":~:.")
    end

    local opts = {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = {
            "dashboard",
            "alpha",
            "ministarter",
            "snacks_dashboard",
            -- opcional: si quieres ocultar lualine dentro del explorer de snacks
            -- "snacks_explorer",
          },
        },
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },

        lualine_c = {
          root_dir,
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { pretty_path },
        },

        lualine_x = {
          function()
            if Snacks and Snacks.profiler and Snacks.profiler.status then
              return Snacks.profiler.status()
            end
            return ""
          end,

          {
            function() return require("noice").api.status.command.get() end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = function()
              if Snacks and Snacks.util and Snacks.util.color then
                return { fg = Snacks.util.color("Statement") }
              end
            end,
          },
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = function()
              if Snacks and Snacks.util and Snacks.util.color then
                return { fg = Snacks.util.color("Constant") }
              end
            end,
          },

          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function()
              if Snacks and Snacks.util and Snacks.util.color then
                return { fg = Snacks.util.color("Debug") }
              end
            end,
          },

          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function()
              if Snacks and Snacks.util and Snacks.util.color then
                return { fg = Snacks.util.color("Special") }
              end
            end,
          },

          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local g = vim.b.gitsigns_status_dict
              if g then
                return { added = g.added, modified = g.changed, removed = g.removed }
              end
            end,
          },
        },

        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },

        lualine_z = {
          function() return " " .. os.date("%R") end,
        },
      },

      -- ✅ solo lo que sí usas
      extensions = { "lazy" },
    }

    -- Trouble symbols (si existe)
    if vim.g.trouble_lualine and has("trouble") then
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
      table.insert(opts.sections.lualine_c, {
        symbols and symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end

    return opts
  end,
}
