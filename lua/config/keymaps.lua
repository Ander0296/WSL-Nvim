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


