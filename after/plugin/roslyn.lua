-- Roslyn LSP (C#) — seblj/roslyn.nvim
-- The plugin registers the base LSP config in lsp/roslyn.lua and calls vim.lsp.enable("roslyn").
-- Use vim.lsp.config("roslyn", ...) to extend/merge additional options into it.

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("roslyn", {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
        -- Preserves <leader>gdr muscle memory from the old omnisharp setup
        vim.keymap.set("n", "<leader>gdr",
            function() require("telescope.builtin").lsp_definitions() end,
            { buffer = bufnr, desc = "Roslyn: Telescope Definitions" })
    end,
})

-- Plugin-level options (solution picking, filewatching, etc.)
require("roslyn").setup()
