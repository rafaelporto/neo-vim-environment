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


    local function map(mode, key, fn, desc)
        vim.keymap.set(mode, key, fn, { buffer = bufnr, remap = false, desc = desc })
    end

    -- Goto
    map("n", "gd",           function() vim.lsp.buf.definition() end,        "Go to Definition")
    map("n", "gi",           function() vim.lsp.buf.implementation() end,     "Go to Implementation")
    map("n", "gr",           function() vim.lsp.buf.references() end,         "References")

    -- LSP actions
    map("n", "K",            function() vim.lsp.buf.hover() end,              "Hover docs")
    map("n", "<leader>vds",  function() vim.lsp.buf.document_symbol() end,    "Document symbols")
    map("n", "<leader>vws",  function() vim.lsp.buf.workspace_symbol() end,   "Workspace symbols")
    map("n", "<leader>ca",   function() vim.lsp.buf.code_action() end,        "Code actions")
    map("n", "<leader>rn",   function() vim.lsp.buf.rename() end,             "Rename symbol")
    map("i", "<C-h>",        function() vim.lsp.buf.signature_help() end,     "Signature help")

    -- Diagnostics
    map("n", "<leader>vd",   function() vim.diagnostic.open_float() end,      "Diagnostic float")
    map("n", ">d",           function() vim.diagnostic.goto_next() end,       "Next diagnostic")
    map("n", "<d",           function() vim.diagnostic.goto_prev() end,       "Prev diagnostic")
    map("n", "<leader>aa",   function() vim.diagnostic.setqflist() end,       "All diagnostics → quickfix")
    map("n", "<leader>ae",   function() vim.diagnostic.setqflist({ severity = "E" }) end, "Workspace errors → quickfix")
    map("n", "<leader>aw",   function() vim.diagnostic.setqflist({ severity = "W" }) end, "Workspace warnings → quickfix")
    map("n", "<leader>d",    function() vim.diagnostic.setloclist() end,      "Buffer diagnostics → loclist")

    -- Metals
    map("n", "<leader>ws",   function() require("metals").hover_worksheet() end, "Metals hover worksheet")

    -- DAP (Metals)
    map("n", "<leader>dc",   function() require("dap").continue() end,           "DAP continue")
    map("n", "<leader>dr",   function() require("dap").repl.toggle() end,        "DAP toggle REPL")
    map("n", "<leader>dK",   function() require("dap.ui.widgets").hover() end,   "DAP hover widget")
    map("n", "<leader>dt",   function() require("dap").toggle_breakpoint() end,  "DAP toggle breakpoint")
    map("n", "<leader>dso",  function() require("dap").step_over() end,          "DAP step over")
    map("n", "<leader>dsi",  function() require("dap").step_into() end,          "DAP step into")
    map("n", "<leader>dl",   function() require("dap").run_last() end,           "DAP run last")
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
