local map = vim.keymap.set

-- Better up / down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Bajar por línea visual", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Bajar por línea visual", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Subir por línea visual", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Subir por línea visual", expr = true, silent = true })

-- Moverse entre ventanas usando Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Ir a la ventana izquierda", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Ir a la ventana inferior", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Ir a la ventana superior", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Ir a la ventana derecha", remap = true })

-- Redimensionar ventanas usando Ctrl + flechas
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Aumentar altura de la ventana" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Disminuir altura de la ventana" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Disminuir ancho de la ventana" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Aumentar ancho de la ventana" })

-- Mover líneas o bloques arriba y abajo con Alt + j / Alt + k
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Mover línea hacia abajo" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Mover línea hacia arriba" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Mover línea hacia abajo (modo insertar)" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Mover línea hacia arriba (modo insertar)" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Mover selección hacia abajo" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Mover selección hacia arriba" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Siguiente buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Siguiente buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Cambiar al otro buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Cambiar al otro buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Cerrar buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Cerrar otros buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Cerrar buffer y ventana" })

-- limpiar búsqueda y detener snippet con Escape
map({ "i", "n", "s" }, "<esc>", function() vim.cmd("noh"); pcall(function() if vim.snippet and vim.snippet.active() then vim.snippet.stop() end end); pcall(function() local ls = require("luasnip"); if ls and ls.unlink_current then ls.unlink_current() end end); pcall(function() if vim.fn.exists("*vsnip#available") == 1 and vim.fn == 1 then vim.fn["vsnip#stop"]() end end); return "<esc>" end, { expr = true, desc = "Escape y limpiar resaltado de búsqueda" })

-- ui
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redibujar / limpiar resaltado de búsqueda / actualizar diff" })

-- búsqueda (comportamiento más consistente de n/N)
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Siguiente resultado de búsqueda" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Siguiente resultado de búsqueda" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Siguiente resultado de búsqueda" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Resultado anterior de búsqueda" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Resultado anterior de búsqueda" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Resultado anterior de búsqueda" })

-- puntos de corte para deshacer (undo)
map("i", ",", ",<c-g>u", { desc = "Punto de deshacer al escribir ," })
map("i", ".", ".<c-g>u", { desc = "Punto de deshacer al escribir ." })
map("i", ";", ";<c-g>u", { desc = "Punto de deshacer al escribir ;" })

-- guardar archivo
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Guardar archivo" })

-- keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Ayuda del término (keywordprg)" })

-- mejor indentación
map("x", "<", "<gv", { desc = "Disminuir indentación y mantener selección" })
map("x", ">", ">gv", { desc = "Aumentar indentación y mantener selección" })

-- comentarios
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Agregar comentario abajo" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Agregar comentario arriba" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- nuevo archivo
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "Nuevo archivo" })

-- lista de ubicación (location list)
map("n", "<leader>xl", function() local ok, err = pcall((vim.fn.getloclist(0, { winid = 0 }).winid ~= 0) and vim.cmd.lclose or vim.cmd.lopen); if not ok and err then vim.notify(err, vim.log.levels.ERROR) end end, { desc = "Lista de ubicación" })

-- lista quickfix
map("n", "<leader>xq", function() local ok, err = pcall((vim.fn.getqflist({ winid = 0 }).winid ~= 0) and vim.cmd.cclose or vim.cmd.copen); if not ok and err then vim.notify(err, vim.log.levels.ERROR) end end, { desc = "Lista quickfix" })
map("n", "[q", vim.cmd.cprev, { desc = "Quickfix anterior" })
map("n", "]q", vim.cmd.cnext, { desc = "Quickfix siguiente" })

-- formato
map({ "n", "x" }, "<leader>cf", function() local ok, err = pcall(function() local mode = vim.fn.mode(); if mode == "v" or mode == "V" or mode == "\22" then local s = vim.fn.getpos("'<"); local e = vim.fn.getpos("'>"); vim.lsp.buf.format({ async = false, timeout_ms = 5000, range = { ["start"] = { s[2] - 1, s[3] - 1 }, ["end"] = { e[2] - 1, e[3] - 1 } } }) else vim.lsp.buf.format({ async = false, timeout_ms = 5000 }) end end); if not ok then vim.notify(err, vim.log.levels.ERROR) end end, { desc = "Formatear" })

-- diagnósticos
local diagnostic_goto = function(next, severity) return function() vim.diagnostic.jump({ count = (next and 1 or -1) * vim.v.count1, severity = severity and vim.diagnostic.severity[severity] or nil, float = true }) end end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnósticos de la línea" })
map("n", "]d", diagnostic_goto(true), { desc = "Siguiente diagnóstico" })
map("n", "[d", diagnostic_goto(false), { desc = "Diagnóstico anterior" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Siguiente error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Error anterior" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Siguiente advertencia" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Advertencia anterior" })

-- lazygit / git
local function git_root() local git = vim.fs.find(".git", { upward = true, path = vim.fn.getcwd() })[1]; return git and vim.fs.dirname(git) or vim.fn.getcwd() end
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.lazygit({ cwd = git_root() }) end, { desc = "Lazygit (raíz del repo)" })
  map("n", "<leader>gG", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.lazygit() end, { desc = "Lazygit (directorio actual)" })
end
map("n", "<leader>gL", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.picker.git_log() end, { desc = "Git log (directorio actual)" })
map("n", "<leader>gb", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.picker.git_log_line() end, { desc = "Git blame de la línea" })
map("n", "<leader>gf", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.picker.git_log_file() end, { desc = "Historial Git del archivo actual" })
map("n", "<leader>gl", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.picker.git_log({ cwd = git_root() }) end, { desc = "Git log (raíz del repo)" })
map({ "n", "x" }, "<leader>gB", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.gitbrowse() end, { desc = "Abrir en navegador (Git)" })
map({ "n", "x" }, "<leader>gY", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, { desc = "Copiar enlace (Git)" })

-- resaltados bajo el cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspeccionar posición (resaltados)" })
map("n", "<leader>uI", function() vim.treesitter.inspect_tree(); vim.api.nvim_input("I") end, { desc = "Inspeccionar árbol (Tree-sitter)" })

-- terminal flotante
local function project_root() local markers = { ".git", "pyproject.toml", "package.json", "go.mod", "Cargo.toml", "pom.xml", "build.gradle", "Makefile" }; local found = vim.fs.find(markers, { upward = true, path = vim.fn.getcwd() })[1]; return found and vim.fs.dirname(found) or vim.fn.getcwd() end
map("n", "<leader>fT", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.terminal() end, { desc = "Terminal (directorio actual)" })
map("n", "<leader>ft", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.terminal(nil, { cwd = project_root() }) end, { desc = "Terminal (raíz del proyecto)" })
map({ "n", "t" }, "<c-/>", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.terminal(nil, { cwd = project_root() }) end, { desc = "Terminal (raíz del proyecto)" })
map({ "n", "t" }, "<c-_>", function() local ok, Snacks = pcall(require, "snacks"); if not ok then return vim.notify("snacks.nvim no está cargado", vim.log.levels.WARN) end; Snacks.terminal(nil, { cwd = project_root() }) end, { desc = "which_key_ignore" })

-- ventanas
map("n", "<leader>-", "<C-W>s", { desc = "Dividir ventana abajo", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Dividir ventana a la derecha", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Cerrar ventana", remap = true })

-- pestañas
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Última pestaña" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Cerrar otras pestañas" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "Primera pestaña" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "Nueva pestaña" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Siguiente pestaña" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Cerrar pestaña" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Pestaña anterior" })
map("n", "<A-l>", "<cmd>tabn<CR>", { desc = "Ir a la siguiente pestaña" })
map("n", "<A-h>", "<cmd>tabp<CR>", { desc = "Ir a la pestaña anterior" })

-- Siempre verás el resultado en el centro de tu pantalla.
map("n", "n", "nzzzv", { desc = "Ir al siguiente resultado y centrar el cursor" })
map("n", "N", "Nzzzv", { desc = "Ir al resultado anterior y centrar el cursor" })

-- Desactivar flechas (opcional)
map({ "n", "i", "v" }, "<Up>", "<Nop>")
map({ "n", "i", "v" }, "<Down>", "<Nop>")
map({ "n", "i", "v" }, "<Left>", "<Nop>")
map({ "n", "i", "v" }, "<Right>", "<Nop>")
