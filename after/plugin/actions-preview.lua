require('actions-preview').setup {

}

vim.keymap.set({ 'n', 'v' }, '<leader>ca', require('actions-preview').code_actions, { desc = 'Code Actions' })
