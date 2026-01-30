return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
      -- opcional (mejora capabilities si usas nvim-cmp)
      { "hrsh7th/cmp-nvim-lsp", lazy = true },

      -- ✅ Java: jdtls “bien hecho”
      { "mfussenegger/nvim-jdtls", ft = "java" },
    },

    config = function()
      -- =========================
      -- Capabilities
      -- =========================
      local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if has_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      capabilities.workspace = capabilities.workspace or {}
      capabilities.workspace.fileOperations = {
        didRename = true,
        willRename = true,
      }

      local has_snacks, Snacks = pcall(require, "snacks")

      -- =========================
      -- Diagnósticos (bonitos)
      -- =========================
      local icons = {
        Error = " ",
        Warn  = " ",
        Hint  = " ",
        Info  = " ",
      }

      for type, icon in pairs(icons) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        signs = true,
      })

      -- =========================
      -- Keymaps LSP (por buffer) vía LspAttach
      -- =========================
      local function map(bufnr, mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      local function supports(client, method)
        return client and client.supports_method and client:supports_method(method)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("MyLspKeymaps", { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          -- Hover / signature
          map(bufnr, "n", "K", vim.lsp.buf.hover, "Documentación (hover)")
          map(bufnr, "n", "gK", vim.lsp.buf.signature_help, "Ayuda de firma")
          map(bufnr, "i", "<C-k>", vim.lsp.buf.signature_help, "Ayuda de firma")

          -- Ir a...
          if supports(client, "textDocument/definition") then
            map(bufnr, "n", "gd", vim.lsp.buf.definition, "Ir a definición")
          end
          if supports(client, "textDocument/declaration") then
            map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Ir a declaración")
          end
          if supports(client, "textDocument/typeDefinition") then
            map(bufnr, "n", "gy", vim.lsp.buf.type_definition, "Ir a tipo")
          end
          if supports(client, "textDocument/implementation") then
            map(bufnr, "n", "gI", vim.lsp.buf.implementation, "Ir a implementación")
          end
          if supports(client, "textDocument/references") then
            map(bufnr, "n", "gr", vim.lsp.buf.references, "Referencias")
          end

          -- Acciones / renombrar
          if supports(client, "textDocument/codeAction") then
            map(bufnr, { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Acción de código")
          end
          if supports(client, "textDocument/rename") then
            map(bufnr, "n", "<leader>cr", vim.lsp.buf.rename, "Renombrar símbolo")
          end

          -- Renombrar archivo (si Snacks lo soporta + server lo soporta)
          if has_snacks and Snacks.rename and Snacks.rename.rename_file then
            if supports(client, "workspace/willRenameFiles") or supports(client, "workspace/didRenameFiles") then
              map(bufnr, "n", "<leader>cR", Snacks.rename.rename_file, "Renombrar archivo (LSP)")
            end
          end

          -- Inlay hints
          if vim.lsp.inlay_hint and supports(client, "textDocument/inlayHint") then
            pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
          end

          -- Organizar imports (TS/JS y Java)
          if client and (client.name == "vtsls" or client.name == "tsserver" or client.name == "jdtls") then
            map(bufnr, "n", "<leader>co", function()
              vim.lsp.buf.code_action({
                apply = true,
                context = { only = { "source.organizeImports" }, diagnostics = {} },
              })
            end, "Organizar imports")
          end

          -- Snacks picker (si existe)
          if has_snacks and Snacks.picker then
            map(bufnr, "n", "<leader>cl", function()
              Snacks.picker.lsp_config()
            end, "Info LSP")

            if Snacks.picker.lsp_definitions then
              map(bufnr, "n", "gd", Snacks.picker.lsp_definitions, "Ir a definición (picker)")
            end
            if Snacks.picker.lsp_references then
              map(bufnr, "n", "gr", Snacks.picker.lsp_references, "Referencias (picker)")
            end
          end
        end,
      })

      -- =========================
      -- ✅ Configurar + habilitar servers (API nueva)
      -- =========================
      local function enable_server(name, cfg)
        cfg = cfg or {}
        cfg.capabilities = vim.tbl_deep_extend("force", capabilities, cfg.capabilities or {})
        local ok = pcall(vim.lsp.config, name, cfg)
        if ok then
          pcall(vim.lsp.enable, name)
        end
        return ok
      end

      -- lua_ls
      enable_server("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            hint = {
              enable = true,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      })

      -- TS/JS (preferir vtsls, si no existe usar tsserver)
      if not enable_server("vtsls", {}) then
        enable_server("tsserver", {})
      end

      -- otros comunes
      enable_server("pyright", {})
      enable_server("jsonls", {})
      enable_server("html", {})
      enable_server("cssls", {})
      enable_server("bashls", {})

      -- =========================
      -- ✅ Java (jdtls) con nvim-jdtls
      -- =========================
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("JDTLS_Start", { clear = true }),
        pattern = "java",
        callback = function()
          local ok_jdtls, jdtls = pcall(require, "jdtls")
          if not ok_jdtls then return end
          local ok_setup, jdtls_setup = pcall(require, "jdtls.setup")
          if not ok_setup then return end

          local root_markers = {
            ".git",
            "mvnw", "gradlew",
            "pom.xml",
            "build.gradle", "settings.gradle",
            "build.gradle.kts", "settings.gradle.kts",
          }

          local root_dir = jdtls_setup.find_root(root_markers)
          if not root_dir then return end

          local project_name = vim.fn.fnamemodify(root_dir, ":t")
          local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

          local sysname = (vim.uv or vim.loop).os_uname().sysname
          local config_dir = "config_linux"
          if sysname == "Windows_NT" then
            config_dir = "config_win"
          elseif sysname == "Darwin" then
            config_dir = "config_mac"
          end

          local ok_mr, mr = pcall(require, "mason-registry")
          if not ok_mr then return end

          local pkg = mr.get_package("jdtls")
          local jdtls_path = pkg:get_install_path()

          local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
          if launcher_jar == "" then return end

          -- bundles (java-test / java-debug-adapter) si están instalados
          local bundles = {}

          local function add_bundles(pkg_name, pattern)
            local ok_pkg, p = pcall(mr.get_package, pkg_name)
            if not ok_pkg or not p:is_installed() then return end
            local install_path = p:get_install_path()
            local found = vim.fn.glob(install_path .. "/" .. pattern, 1, 1)
            for _, f in ipairs(found) do table.insert(bundles, f) end
          end

          add_bundles("java-test", "extension/server/*.jar")
          add_bundles("java-debug-adapter", "extension/server/com.microsoft.java.debug.plugin-*.jar")

          local cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher_jar,
            "-configuration", jdtls_path .. "/" .. config_dir,
            "-data", workspace_dir,
          }

          local config = {
            cmd = cmd,
            root_dir = root_dir,
            capabilities = capabilities,
            init_options = { bundles = bundles },
            settings = {
              java = {
                signatureHelp = { enabled = true },
                contentProvider = { preferred = "fernflower" },
                saveActions = { organizeImports = true },
                completion = { importOrder = { "java", "javax", "com", "org" } },
              },
            },
          }

          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
}
