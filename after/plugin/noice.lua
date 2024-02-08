require("noice").setup({
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
    },
    -- you can enable a preset for easier configuration
    presets = {
        bottom_search = true,   -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,     -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
    },
})

vim.keymap.set("n", "<leader>nh", ":Noice history<CR>", { noremap = true, silent = true, desc = "Noice history" })
vim.keymap.set('n', '<leader>nt', ":Noice telescope<CR>", { noremap = true, silent = true, desc = "Telescope noice" })
vim.keymap.set('n', '<leader>nl', ":Noice last<CR>", { noremap = true, silent = true, desc = "Noice last message" })
vim.keymap.set('n', '<leader>nc', ":Noice dismiss<CR>", { noremap = true, silent = true, desc = "Noice dismiss message" })
vim.keymap.set('n', '<leader>nd', ":Noice disable<CR>", { noremap = true, silent = true, desc = "Noice disable" })
vim.keymap.set('n', '<leader>ne', ":Noice enable<CR>", { noremap = true, silent = true, desc = "Noice enable" })
vim.keymap.set('n', '<leader>ner', ":Noice errors<CR>",
    { noremap = true, silent = true, desc = "Shows the error messages in a split" })
