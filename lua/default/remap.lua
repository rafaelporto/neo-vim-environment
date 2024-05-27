vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Abre a pasta do arquivo"})

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move o texto selecionado para baixo" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv" , { desc = "Move o texto selecionado para cima" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Adiciona a linha inferior no final da linha atual e mantem o cursor na posição atual"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Desce a página mantendo o cursor no meio do buffer"})
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Sobe a página mantendo o cursor no meio do buffer"})
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Remove o testo em destaque e cola o que estiver no buffer"})

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copia para o clipboard do sistema" })
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Sai do modo de inserção" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Salva o arquivo" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { desc = "Salva o arquivo e sai do modo de inserção" })
vim.keymap.set("n", "<C-q>", ":q<CR>", { desc = "Fecha o buffer" })
vim.keymap.set("n", "<C-qa>", ":qa<CR>", { desc = "Fecha todos os buffers" })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Formata o arquivo"})

-- quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", {desc = "Próximo diagnóstico"})
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", {desc = "Diagnóstico anterior"})
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", {desc = "Próximo diagnóstico local"})
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", {desc = "Diagnóstico local anterior"})

-- replace na palavra em que o cursor estiver
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- tornar o arquivo aberto em executável
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.config/nvim/lua/default/plugins.lua<CR>")
vim.keymap.set("n", "<leader>vkm", "<cmd>e ~/.config/nvim/lua/default/remap.lua<CR>")
vim.keymap.set("n", "<leader>vtk", "<cmd>e ~/.config/nvim/after/plugin/telescope.lua<CR>", {})

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

vim.keymap.set("n", "<leader>sp", "<cmd>echo expand('%')<CR>", { desc = "Exibe o caminho do arquivo" })
