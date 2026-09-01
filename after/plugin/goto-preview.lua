-- A variável NÃO pode se chamar `goto`: é palavra reservada desde o Lua 5.2.
-- O LuaJIT do Neovim tolera e o arquivo roda, mas o lua_ls marca 6 erros de
-- sintaxe na linha 1 — ruído vermelho permanente que compete com erro de verdade.
local gotopreview = require("goto-preview")

gotopreview.setup()

vim.keymap.set(
	"n",
	"<leader>pd",
	'<cmd>lua require("goto-preview").goto_preview_definition()<CR>',
	{ desc = "Preview Definition", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>pt",
	'<cmd>lua require("goto-preview").goto_preview_type_definition()<CR>',
	{ desc = "Preview Type Definition", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>pi",
	'<cmd>lua require("goto-preview").goto_preview_implementation()<CR>',
	{ desc = "Preview Implementation", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>pr",
	'<cmd>lua require("goto-preview").goto_preview_references()<CR>',
	{ desc = "Preview References", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>pc",
	'<cmd>lua require("goto-preview").close_all_win()<CR>',
	{ desc = "Close Previews", silent = true }
)
