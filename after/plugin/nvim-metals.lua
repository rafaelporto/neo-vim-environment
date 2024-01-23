local api = vim.api
local metals_config = require("metals").bare_config()

-- Example of settings
metals_config.settings = {
    showImplicitArguments = true,
    excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
}

-- *READ THIS*
-- I *highly* recommend setting statusBarProvider to true, however if you do,
-- you *have* to have a setting to display this in your statusline or else
-- you'll not see any messages from metals. There is more info in the help
-- docs about this
 metals_config.init_options.statusBarProvider = "on"

-- Example if you are using cmp how to make sure the correct capabilities for snippets are set
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Debug settings if you're using nvim-dap
local dap = require("dap")

dap.configurations.scala = {
    {
        type = "scala",
        request = "launch",
        name = "RunOrTest",
        metals = {
            runType = "runOrTestFile",
            --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
        },
    },
    {
        type = "scala",
        request = "launch",
        name = "Test Target",
        metals = {
            runType = "testTarget",
        },
    },
}

metals_config.on_attach = function(_, bufnr)
    require("metals").setup_dap()

    -- LSP mappings
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
    vim.keymap.set("n", "<leader>aa", function () vim.diagnostic.setqflist() end, opts)
    vim.keymap.set("n", "<leader>ae", function ()
        vim.diagnostic.setqflist({ severity = "E" }) -- all workspace errors
    end, opts)
    vim.keymap.set("n", "<leader>aw", function ()
        vim.diagnostic.setqflist({ severity = "W" }) -- all workspace warnings
    end, opts)
    vim.keymap.set("n", "<leader>d", function ()
        vim.diagnostic.setloclist()
    end, opts) -- buffer diagnostics only

    vim.keymap.set("n", "<leader>ws", function()
        require("metals").hover_worksheet()
    end)

    -- Example mappings for usage with nvim-dap. If you don't use that, you can
    -- skip these
    vim.keymap.set("n", "<leader>dc", function()
        require("dap").continue()
    end)

    vim.keymap.set("n", "<leader>dr", function()
        require("dap").repl.toggle()
    end)

    vim.keymap.set("n", "<leader>dK", function()
        require("dap.ui.widgets").hover()
    end)

    vim.keymap.set("n", "<leader>dt", function()
        require("dap").toggle_breakpoint()
    end)

    vim.keymap.set("n", "<leader>dso", function()
        require("dap").step_over()
    end)

    vim.keymap.set("n", "<leader>dsi", function()
        require("dap").step_into()
    end)

    vim.keymap.set("n", "<leader>dl", function()
        require("dap").run_last()
    end)
end

-- Autocmd that will actually be in charging of starting the whole thing
local nvim_metals_group = api.nvim_create_augroup("nvim-metals", { clear = true })
api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt" },
    callback = function()
        require("metals").initialize_or_attach(metals_config)
    end,
    group = nvim_metals_group,
})
