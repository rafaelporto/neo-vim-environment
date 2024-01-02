return {
    {
        'rose-pine/neovim',
        name = 'rose-pine'
    },
    'nvim-treesitter/nvim-treesitter-context',
    'mbbill/undotree',
    {
        'github/copilot.vim',
        lazy = false,
        enabled = true
    },
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
    },
    {
        'neoclide/coc.nvim',
        branch = 'release',
        init = function ()
            vim.g.coc_global_extensions = {
                'coc-conjure',
                'coc-tsserver',
                'coc-json',
                'coc-html',
                'coc-css'
            }
        end
    },
    'hoffs/omnisharp-extended-lsp.nvim'

}
