return {
    {
        'rose-pine/neovim',
        name = 'rose-pine'
    },
    'nvim-treesitter/nvim-treesitter-context',
    'mbbill/undotree',
    'github/copilot.vim',
    'Olical/conjure',
    'tpope/vim-dispatch',
    'clojure-vim/vim-jack-in',
    'radenling/vim-dispatch-neovim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    {
        'neovim/nvim-lspconfig',
        cmd = 'LspInfo',
        event = {'BufReadPre', 'BufNewFile'},
        dependencies = {
            {'hrsh7th/cmp-nvim-lsp'},
        }
    }
}
