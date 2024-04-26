require("todo-comments").setup {
}

vim.keymap.set("n", "ntd", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "ptd", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

vim.keymap.set('n', '<leader>td',":TodoTelescope<CR>" , { desc = 'Lista todos os TODOs do projeto' })
