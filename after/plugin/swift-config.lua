local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }
local on_attach = function(_, bufnr)
    opts.buffer = bufnr

    vim.keymap.set("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", { desc = "Show Xcodebuild Actions" })
    vim.keymap.set("n", "<leader>xf", "<cmd>XcodebuildProjectManager<cr>", { desc = "Show Project Manager Actions" })

    vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
    vim.keymap.set("n", "<leader>xB", "<cmd>XcodebuildBuildForTesting<cr>", { desc = "Build For Testing" })
    vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })

    vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
    vim.keymap.set("v", "<leader>xt", "<cmd>XcodebuildTestSelected<cr>", { desc = "Run Selected Tests" })
    vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run Current Test Class" })
    vim.keymap.set("n", "<leader>x.", "<cmd>XcodebuildTestRepeat<cr>", { desc = "Repeat Last Test Run" })

    vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
    vim.keymap.set("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
    vim.keymap.set("n", "<leader>xC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", { desc = "Show Code Coverage Report" })
    vim.keymap.set("n", "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>", { desc = "Toggle Test Explorer" })
    vim.keymap.set("n", "<leader>xs", "<cmd>XcodebuildFailingSnapshots<cr>", { desc = "Show Failing Snapshots" })

    vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
    vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", { desc = "Select Test Plan" })
    vim.keymap.set("n", "<leader>xq", "<cmd>Telescope quickfix<cr>", { desc = "Show QuickFix List" })

    vim.keymap.set("n", "<leader>xx", "<cmd>XcodebuildQuickfixLine<cr>", { desc = "Quickfix Line" })
    vim.keymap.set("n", "<leader>xa", "<cmd>XcodebuildCodeActions<cr>", { desc = "Show Code Actions" })

    vim.keymap.set("n", "<leader>ml", function()
        require("lint").try_lint()
    end, { desc = "Lint file" })
end

vim.lsp.config["sourcekit"] = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = on_attach,
    cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
}

vim.lsp.enable("sourcekit")

local conform = require("conform")

-- Formatter config
conform.setup({
    formatters_by_ft = {
        swift = { "swiftformat" },
        dart = { "dart_format" },
    },
    format_on_save = function(bufnr)
        local ignore_filetypes = { "oil" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            return
        end

        return { timeout_ms = 500, lsp_fallback = true }
    end,
    log_level = vim.log.levels.ERROR,
})

-- linter config
local lint = require("lint")

lint.linters_by_ft = {
    swift = { "swiftlint" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
        if not vim.endswith(vim.fn.bufname(), "swiftinterface") then
            require("lint").try_lint()
        end
    end,
})
