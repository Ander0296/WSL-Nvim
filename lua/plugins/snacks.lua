
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,

  ---@type snacks.Config
  opts = {
    -- ANIMATE CONFIG
    animate = {
      enable = true,
      fps = 60,
      resize = { timing = 0.2, damping = 1.0 },
      omen = { timing = 0.3, damping = 1.0 },
      close = { timing = 0.2, damping = 1.0 },
    },
    dim = {enable = true},
    bigfile = { enabled = true },

    -- ✅ habilitar módulo de toggles (integración con which-key)
    toggle = { enabled = true },

    -- CONFIG DASHBOARD
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },

        -- {
        --   pane = 2,
        --   section = "terminal",
        --   cmd = "colorscript -e square",
        --   height = 5,
        --   padding = 1,
        -- },

        {
          pane = 2,
          icon = " ",
          desc = "Browse Repo",
          padding = 1,
          key = "b",
          action = function()
            Snacks.gitbrowse()
          end,
        },

        function()
          local in_git = Snacks.git.get_root() ~= nil
          return {
            vim.tbl_extend("force", {
              pane = 2,
              section = "terminal",
              enabled = in_git,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            }, {
              title = "Notifications",
              cmd = "gh notify -s -a -n5",
              action = function()
                vim.ui.open("https://github.com/notifications")
              end,
              key = "n",
              icon = " ",
              height = 5,
            }),
          }
        end,

        { section = "keys", gap = 1, padding = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },

        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },

        { section = "startup" },
      },
    },

    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },

    notifier = {
      enabled = true,
      timeout = 3000,
    },

    picker = { enabled = true },

    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },

    styles = {
      notification = {},
    },
  },
  --

  --
  config = function(_, opts)
    local Snacks = require("snacks")
    _G.Snacks = Snacks -- 👈 para que tus mappings en `keys = { ... }` funcionen
    Snacks.setup(opts)

  -- ✅ activar DIM siempre al iniciar Neovim
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      pcall(function()
        Snacks.dim.enable()
      end)
    end,
  })

    -- helper: detectar si existe un plugin (sin LazyVim)
    local function has(mod)
      return pcall(require, mod)
    end

    -- helper: root simple (git) para toggle_cwd
    local function get_root(buf)
      local name = vim.api.nvim_buf_get_name(buf or 0)
      local dir = (name ~= "" and vim.fs.dirname(name)) or (vim.uv and vim.uv.cwd()) or "."
      local root = vim.fs.root(dir, { ".git" })
      return vim.fs.normalize(root or ((vim.uv and vim.uv.cwd()) or "."))
    end

    -- =========================
    -- Terminal: navegación entre ventanas (modo terminal)
    -- =========================
    Snacks.config.terminal = Snacks.config.terminal or {}
    Snacks.config.terminal.win = Snacks.config.terminal.win or {}
    Snacks.config.terminal.win.keys = Snacks.config.terminal.win.keys or {}

    local function term_nav(dir)
      return function()
        local key = "<C-\\><C-n><C-w>" .. dir
        return vim.api.nvim_replace_termcodes(key, true, false, true)
      end
    end

    Snacks.config.terminal.win.keys.nav_h =
      { "<C-h>", term_nav("h"), desc = "Ir a la ventana izquierda", expr = true, mode = "t" }
    Snacks.config.terminal.win.keys.nav_j =
      { "<C-j>", term_nav("j"), desc = "Ir a la ventana inferior", expr = true, mode = "t" }
    Snacks.config.terminal.win.keys.nav_k =
      { "<C-k>", term_nav("k"), desc = "Ir a la ventana superior", expr = true, mode = "t" }
    Snacks.config.terminal.win.keys.nav_l =
      { "<C-l>", term_nav("l"), desc = "Ir a la ventana derecha", expr = true, mode = "t" }

    -- =========================
    -- Picker: teclas y acciones
    -- =========================
    Snacks.config.picker = Snacks.config.picker or {}
    Snacks.config.picker.win = Snacks.config.picker.win or {}
    Snacks.config.picker.win.input = Snacks.config.picker.win.input or {}
    Snacks.config.picker.win.input.keys = Snacks.config.picker.win.input.keys or {}
    Snacks.config.picker.actions = Snacks.config.picker.actions or {}

    -- Alt+c: alternar cwd entre root y cwd real
    Snacks.config.picker.win.input.keys["<a-c>"] = { "toggle_cwd", mode = { "n", "i" } }
    Snacks.config.picker.actions.toggle_cwd = function(p)
      local root = get_root(p.input.filter.current_buf)
      local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
      local current = p:cwd()
      p:set_cwd(current == root and cwd or root)
      p:find()
    end

    -- Flash (si tienes flash.nvim)
    if has("flash") then
      Snacks.config.picker.win.input.keys["<a-s>"] = { "flash", mode = { "n", "i" } }
      Snacks.config.picker.win.input.keys["s"] = { "flash" }
      Snacks.config.picker.actions.flash = function(picker)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
              end,
            },
          },
          action = function(match)
            local idx = picker.list:row2idx(match.pos[1])
            picker.list:_move(idx, true, true)
          end,
        })
      end
    end

    -- Trouble (si tienes trouble.nvim)
    if has("trouble") then
      Snacks.config.picker.win.input.keys["<a-t>"] = { "trouble_open", mode = { "n", "i" } }
      Snacks.config.picker.actions.trouble_open = function(...)
        return require("trouble.sources.snacks").actions.trouble_open.action(...)
      end
    end

    -- =========================
    -- ✅ TOGGLES (en español) + adaptación de los 2 de LazyVim.format
    -- =========================
    local T = Snacks.toggle

    -- 1) Formateo automático (adaptado sin LazyVim)
    -- <leader>uf => global
    T.new({
      id = "autoformat_global",
      name = "󰊄 Formateo automático (global)",
      get = function()
        return vim.g.autoformat ~= false
      end,
      set = function(state)
        vim.g.autoformat = state
      end,
    }):map("<leader>uf")

    -- <leader>uF => por buffer
    T.new({
      id = "autoformat_buffer",
      name = "󰊄 Formateo automático (buffer)",
      get = function()
        return vim.b.autoformat ~= false
      end,
      set = function(state)
        vim.b.autoformat = state
      end,
    }):map("<leader>uF")

    -- 2) Opciones de Neovim (spell / wrap / etc)
    T.option("spell", { name = "󰓆 Corrector ortográfico (spell)" }):map("<leader>us")
    T.option("wrap", { name = "󰖶 Ajuste de líneas largas (wrap)" }):map("<leader>uw")
    T.option("relativenumber", { name = "󰔂 Números relativos" }):map("<leader>uL")

    -- 3) Toggles de UI / LSP / Snacks
    T.diagnostics({ name = " Diagnósticos (LSP)" }):map("<leader>ud")
    T.line_number({ name = "󰔁 Números de línea" }):map("<leader>ul")
    T.option("conceallevel", {
      off = 0,
      on = (vim.o.conceallevel > 0 and vim.o.conceallevel) or 2,
      name = " Ocultar sintaxis (conceal)",
    }):map("<leader>uc")
    T.option("showtabline", {
      off = 0,
      on = (vim.o.showtabline > 0 and vim.o.showtabline) or 2,
      name = "󰓩 Barra de pestañas (tabline)",
    }):map("<leader>uA")
    T.treesitter({ name = " Treesitter: resaltado" }):map("<leader>uT")
    T.option("background", { off = "light", on = "dark", name = " Fondo oscuro" }):map("<leader>ub")
    T.dim({ name = "󰌶 Atenuar fuera del foco" }):map("<leader>uD")
    T.animate({ name = "󰪏 Animaciones" }):map("<leader>ua")
    T.indent({ name = "󰉶 Guías de indentación" }):map("<leader>ug")
    T.scroll({ name = "󱕐 Scroll suave" }):map("<leader>uS")
    T.profiler({ name = "󱎫 Profiler (medición)" }):map("<leader>dpp")
    T.profiler_highlights({ name = "󰸌 Profiler: resaltados" }):map("<leader>dph")
    T.dim({ name = "󰌶 Oscurecer código inactivo" }):map("<leader>uod")
    T.zen({ name = "🧘 Modo sin distracciones" }):map("<leader>uz")
    T.zoom({ name = "Alternar zoom de ventana" }):map("<leader>uZ")
    if vim.lsp.inlay_hint then
      T.inlay_hints({ name = "󰛨 Inlay hints (pistas en línea)" }):map("<leader>uh")
    end
  end,

  keys = {
    -- Notificaciones
    {
      "<leader>n",
      function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end,
      desc = "Historial de notificaciones",
    },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Cerrar todas las notificaciones" },

    -- Explorador (recomendado)
    {
      "<leader>ee",
      function()
        Snacks.explorer()
      end,
      desc = "Explorador de archivos",
      mode = "n",
    },

    -- Scratch / profiler
    { "<leader>.", function() Snacks.scratch() end, desc = "Alternar buffer Scratch" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Seleccionar buffer Scratch" },
    { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Scratch del profiler" },

    -- Picker: accesos rápidos
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Lista de buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Buscar texto (directorio raíz)" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Historial de comandos" },
    { "<leader><space>", function() Snacks.picker.files() end, desc = "Buscar archivos (directorio raíz)" },
    -- Buscar archivos (find)
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (todos)" },

    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Buscar archivo de configuración" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Buscar archivos (directorio raíz)" },
    { "<leader>fF", function() Snacks.picker.files({ cwd = (vim.uv or vim.loop).cwd() }) end, desc = "Buscar archivos (cwd)" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Buscar archivos (git)" },

    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Archivos recientes" },
    { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Recientes (cwd)" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Proyectos" },

    -- Git
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Diff de Git (hunks)" },
    { "<leader>gD", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Diff de Git (origin)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Estado de Git" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Stash de Git" },
    { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "Issues de GitHub (abiertas)" },
    { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "Issues de GitHub (todas)" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "Pull requests (abiertas)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "Pull requests (todas)" },

    -- Grep / búsqueda en buffers
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Líneas del buffer" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Buscar en buffers abiertos" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep (directorio raíz)" },
    { "<leader>sG", function() Snacks.picker.grep({ cwd = (vim.uv or vim.loop).cwd() }) end, desc = "Grep (cwd)" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Buscar especificación de plugin" },
    { "<leader>sw", function() Snacks.picker.grep({ search = vim.fn.expand("<cword>") }) end, desc = "Selección/palabra (raíz)", mode = { "n", "x" } },
    { "<leader>sW", function() Snacks.picker.grep({ search = vim.fn.expand("<cword>"), cwd = (vim.uv or vim.loop).cwd() }) end, desc = "Selección/palabra (cwd)", mode = { "n", "x" } },
    -- Buscar (search)
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registros" },
    { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Historial de búsqueda" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocomandos" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Historial de comandos" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Comandos" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnósticos" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnósticos del buffer" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Páginas de ayuda" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Resaltados (highlights)" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Iconos" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Saltos" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Atajos (keymaps)" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Lista de ubicación (loclist)" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Páginas man" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marcas" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Reanudar última búsqueda" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Lista quickfix" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Árbol de deshacer (undo)" },

    -- UI
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Esquemas de colores" },
  },
}
