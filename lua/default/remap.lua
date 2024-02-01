vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- moves highlighted text to up (with K) or down (with J)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z") -- Adiciona a linha inferior no final da linha atual e mantem o cursor na posição atual
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Desce a página mantendo o cursor no meio do buffer
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Sobe a página mantendo o cursor no meio do buffer`
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]]) -- Remove o texto em destaque e cola o que estiver no buffer

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copia para o clipboard do sistema" }) -- copia a linha para o clipboard do sistema
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

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
