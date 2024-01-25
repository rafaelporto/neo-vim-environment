local lsp = require("lsp-zero")
local lspconfig = require('lspconfig')
local schemas = require('schemastore')

lsp.preset("recommended")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'tsserver',
        "eslint",
        "clojure_lsp",
        "omnisharp",
        "lua_ls",
        "yamlls",
        "jsonls",
        "dockerls"
    },
    handlers = {
        lsp.default_setup,
        omnisharp = function()
            local pid = vim.fn.getpid()
            local home = os.getenv("HOME")
            local omnisharp_extended = require('omnisharp_extended')
            require 'lspconfig'.omnisharp.setup {
                cmd = {
                    home .. "/.omnisharp/OmniSharp",
                    '--languageserver',
                    '--hostPID',
                    tostring(pid)
                },
                enable_roslyn_analysers = true,
                enable_import_completion = true,
                organize_imports_on_format = true,
                filetypes = { 'cs', 'vb', 'csproj', 'sln', 'props' },
                handlers = {
                    ["textDocument/definition"] = omnisharp_extended.handler,
                    ["on_attach"] = function()
                        vim.keymap.set("n", "<leader>gdr", omnisharp_extended.telescope_lsp_definitions(), {})
                    end
                }
            }
        end,
        jsonls = function()
            lspconfig.jsonls.setup {
                settings = {
                    json = {
                        schemas = schemas.json.schemas(),
                        validate = { enable = true },
                    },
                },
                filetypes = { "json", "jsonc", "*json.base" },
                capabilities = capabilities
            }
        end,
        bashls = function()
            lspconfig.bashls.setup {
                filetypes = { "sh", "zsh", "bash", "*zprofile" },
            }
        end,
        docker_compose_language_service = function()
            lspconfig.docker_compose_language_service.setup {}
        end,
        marksman = function()
            lspconfig.marksman.setup {}
        end,
        dockerls = function()
            lspconfig.dockerls.setup {}
        end,
        cssls = function()
            lspconfig.cssls.setup {
                capabilities = capabilities
            }
        end,
        lua_ls = function()
            local lua_opts = lsp.nvim_lua_ls()
            lspconfig.lua_ls.setup(lua_opts)
        end,
        clojure_lsp = function()
            lspconfig.clojure_lsp.setup {}
        end,
        tsserver = function()
            lspconfig.tsserver.setup {}
        end,
        yamlls = function()
            lspconfig.yamlls.setup {
                settings = {
                    yamlls = {
                        schemas = schemas.yaml.schemas(),
                    },
                },
            }
        end,
    }
})

local cmp = require('cmp')
local cmp_action = lsp.cmp_action()
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        ['<C-u>'] = cmp.mapping.scroll_docs(-5),
        ['<C-d>'] = cmp.mapping.scroll_docs(5),
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    })
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = '✘',
        warn = '▲',
        hint = '⚑',
        info = '»'
    }
})

lsp.on_attach(function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- Goto mappings
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)

    -- LSP mappings
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vds", function() vim.lsp.buf.document_symbol() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

    -- Diagnostics
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", ">d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "<d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>aa", function() vim.diagnostic.setqflist() end, opts)
    vim.keymap.set("n", "<leader>ae", function()
        vim.diagnostic.setqflist({ severity = "E" }) -- all workspace errors
    end, opts)
    vim.keymap.set("n", "<leader>aw", function()
        vim.diagnostic.setqflist({ severity = "W" }) -- all workspace warnings
    end, opts)
    vim.keymap.set("n", "<leader>d", function()
        vim.diagnostic.setloclist()
    end, opts) -- buffer diagnostics only
end)

vim.diagnostic.config({
    virtual_text = true
})

local function toggleLines()
    local new_value = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = new_value, virtual_text = not new_value })
    return new_value
end

vim.keymap.set('n', '<leader>lu', toggleLines, { desc = "Toggle Underline Diagnostics", silent = true })

lsp.setup()
