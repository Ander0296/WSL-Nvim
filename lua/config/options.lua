vim.g.mapleader = " "
local opt = vim.opt

-- configuración de lazyvim
opt.conceallevel = 2
opt.confirm = true
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.foldtext = ""
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.jumpoptions = "view"
opt.linebreak = true -- Wrap lines at convenient points
opt.grepprg = "rg --vimgrep"
opt.formatexpr = "v:lua.LazyVim.format.formatexpr()"
opt.list = true -- Show some invisible characters (tabs...
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.ruler = false
opt.shiftround = true -- Round indent
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.smoothscroll = true
opt.spelllang = { "en", "es" }
opt.splitkeep = "screen"
opt.termguicolors = true -- True color support
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wrap = false -- Disable line wrap
vim.g.markdown_recommended_style = 0


-- Configuración común a ambos entornos
opt.autoindent = true -- Indenta automáticamente
opt.autowrite = true -- Enable auto write
opt.backspace = "indent,eol,start" -- Backspace inteligente (permite borrar indentaciones, líneas vacías y al inicio)
opt.breakindent = true -- Mantiene la indentación visual en líneas largas que se ajustan (wrap)
opt.clipboard:append("unnamedplus") -- Portapapeles del sistema (copiar/pegar con Ctrl+C/V)
opt.completeopt = "menu,menuone,noselect"
opt.cursorline = true -- Resalta la línea actual
opt.expandtab = true -- Convertir tabuladores en espacios
opt.ignorecase = true -- Ignorar mayúsculas en búsquedas
opt.list = true -- Muestra caracteres invisibles como espacios y tabs
-- opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "" -- Desactivar mouse
opt.number = true -- Mostrar número de línea absoluto
opt.relativenumber = true -- Mostrar número de línea relativo (ayuda a navegar)
opt.scrolloff = 10 -- Deja 10 líneas de margen arriba y abajo del cursor
opt.shiftwidth = 2 -- 4 espacios al indentar con << o >>
opt.showmode = false -- Oculta el modo (insert/normal) si ya se muestra en la statusline
opt.signcolumn = "yes" -- Siempre mostrar columna de signos (errores, git, etc.)
opt.smartcase = true -- Sensible a mayúsculas si se usan en la búsqueda
opt.smartindent = true -- Indentación inteligente según el contexto
opt.smarttab = true -- Tab responde de forma inteligente al contexto de indentación
opt.softtabstop = 4 -- Elimina cuatro espacios si es tab
opt.splitbelow = true -- Dividir ventanas abajo
opt.splitright = true -- Dividir ventanas a la derecha
opt.swapfile = false -- No usar archivos swap
opt.tabstop = 4 -- 4 espacios por tabulador
opt.timeoutlen = 1500 -- Tiempo de espera para combinaciones de teclas (ms)
opt.undofile = true -- Guarda historial de deshacer entre sesiones
opt.wrap = false -- No ajustar líneas largas
vim.g.deprecation_warnings = false
vim.g.lazyvim_cmp = "auto"
vim.g.lazyvim_picker = "auto"
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
vim.g.trouble_lualine = true


-- Si estás en WSL, usa win32yank para compartir el portapapeles con Windows
if vim.fn.has("wsl") == 1 then
	vim.g.clipboard = {
		name = "win32yank-wsl",
		copy = {
			["+"] = "win32yank.exe -i --crlf",
			["*"] = "win32yank.exe -i --crlf",
		},
		paste = {
			["+"] = "win32yank.exe -o --lf",
			["*"] = "win32yank.exe -o --lf",
		},
		cache_enabled = 0,
	}
end

-- Solo mostrar cursorline en la ventana activa
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	callback = function()
		vim.wo.cursorline = true
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	callback = function()
		vim.wo.cursorline = false
	end,
})

vim.o.laststatus = 3 -- Activar statusline global

-- Mostrar número y número relativo solo en la ventana activa
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FocusGained" }, {
	callback = function()
		vim.wo.number = true
		vim.wo.relativenumber = true
	end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "FocusLost" }, {
	callback = function()
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})




-- LAZYVIM AUTOCOMMANDS

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})


-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})



-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})



-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})


-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})


-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
