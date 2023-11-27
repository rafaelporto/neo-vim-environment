return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        init = function()
            -- Disable automatic setup, we are doing it manually
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },
    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
        },
        config = function()
            -- Here is where you configure the autocompletion settings.
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_cmp()

            -- And you can configure cmp even more, if you want to.
            local cmp = require('cmp')
            local cmp_action = lsp_zero.cmp_action()

            require('luasnip.loaders.from_vscode').lazy_load()

            vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

            cmp.setup({
                formatting = cmp_format,
                preselect = 'item',
                completion = {
                    completeopt = 'menu,menuone,noinsert'
                },
                window = {
                    documentation = cmp.config.window.bordered(),
                },
                sources = {
                    { name = 'path' },
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lua' },
                    { name = 'buffer',  keyword_length = 3 },
                    { name = 'luasnip', keyword_length = 2 },
                },
                mapping = cmp.mapping.preset.insert({
                    -- confirm completion item
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),

                    -- toggle completion menu
                    ['<C-e>'] = cmp_action.toggle_completion(),

                    -- tab complete
                    ['<Tab>'] = cmp_action.tab_complete(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),

                    -- navigate between snippet placeholder
                    ['<C-d>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

                    -- scroll documentation window
                    ['<C-f>'] = cmp.mapping.scroll_docs(5),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-5),
                }),
            })
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            -- This is where all the LSP shenanigans will live
            local lsp_zero = require('lsp-zero')

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = { "tsserver", "eslint", "clojure_lsp" },
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                    clojure_lsp = function()
                        require('lspconfig').clojure_lsp.setup {}
                    end,
                    tsserver = function()
                        require('lspconfig').tsserver.setup {}
                    end,
                  -- omnisharp = function()
                  --      local pid = vim.fn.getpid()
                  --      local home = os.getenv("HOME")
                  --      local omnisharp_extended = require('omnisharp_extended')
                  --      require 'lspconfig'.omnisharp.setup {
                  --          cmd = {
                  --              home .. "/.omnisharp/OmniSharp",
                  --              '--languageserver',
                  --              '--hostPID',
                  --              tostring(pid)
                  --          },
                  --          enable_roslyn_analysers = true,
                  --          enable_import_completion = true,
                  --          organize_imports_on_format = true,
                  --          filetypes = { 'cs', 'vb', 'csproj', 'sln', 'props' },
                  --          handlers = {
                  --              ["textDocument/definition"] = omnisharp_extended.handler,
                  --              ["on_attach"] = function()
                  --                  vim.keymap.set("n", "<leader>gdr", omnisharp_extended.telescope_lsp_definitions(), {})
                  --              end
                  --          }
                  --      }
                  --  end

                }
            })

            lsp_zero.set_sign_icons({
                error = '✘',
                warn = '▲',
                hint = '⚑',
                info = ''
            })

            vim.diagnostic.config({
                virtual_text = true,
                severity_sort = true,
                float = {
                    style = 'minimal',
                    border = 'rounded',
                    source = 'always',
                    header = '',
                    prefix = '',
                },
            })

            lsp_zero.on_attach(function(client, bufnr)
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
                vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
                vim.keymap.set("n", "gr", require('telescope.builtin').lsp_references, {})
            end)

            lsp_zero.setup()
        end
    }
}
