local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

-- <leader>A e não <leader>a: o namespace <leader>a é de diagnósticos
-- (aa/ad/ae/aq/aw), então um <leader>a completo esperava timeoutlen a cada
-- adição — e adicionar arquivo ao harpoon é ação frequente.
vim.keymap.set("n", "<leader>A", mark.add_file,          { desc = "Harpoon add file" })
vim.keymap.set("n", "<C-e>",    ui.toggle_quick_menu,   { desc = "Harpoon menu" })

vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Harpoon file 1" })
vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "Harpoon file 2" })
vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "Harpoon file 3" })
vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { desc = "Harpoon file 4" })
