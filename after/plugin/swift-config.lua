-- Keymaps do xcodebuild.
--
-- Antes o arquivo preparava `opts.buffer = bufnr` e nenhum dos 19 keymaps usava
-- `opts` — todos eram GLOBAIS. Bastava o sourcekit anexar uma vez para os 19
-- existirem em qualquer buffer, fazendo o <leader>x esperar timeoutlen em toda
-- parte, de forma inconsistente: numa sessão só de Go, onde o sourcekit nunca
-- anexa, o <leader>x respondia na hora.
-- (o `local keymap = vim.keymap` que existia aqui nunca foi usado)
local on_attach = function(_, bufnr)
    local function map(mode, key, cmd, desc)
        vim.keymap.set(mode, key, cmd, {
            buffer = bufnr,
            noremap = true,
            silent = true,
            desc = desc,
        })
    end

    map("n", "<leader>X", "<cmd>XcodebuildPicker<cr>", "Show Xcodebuild Actions")
    map("n", "<leader>xf", "<cmd>XcodebuildProjectManager<cr>", "Show Project Manager Actions")

    map("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", "Build Project")
    map("n", "<leader>xB", "<cmd>XcodebuildBuildForTesting<cr>", "Build For Testing")
    map("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", "Build & Run Project")

    map("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", "Run Tests")
    map("v", "<leader>xt", "<cmd>XcodebuildTestSelected<cr>", "Run Selected Tests")
    map("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", "Run Current Test Class")
    map("n", "<leader>x.", "<cmd>XcodebuildTestRepeat<cr>", "Repeat Last Test Run")

    map("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", "Toggle Xcodebuild Logs")
    map("n", "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", "Toggle Code Coverage")
    map("n", "<leader>xC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", "Show Code Coverage Report")
    map("n", "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>", "Toggle Test Explorer")
    map("n", "<leader>xs", "<cmd>XcodebuildFailingSnapshots<cr>", "Show Failing Snapshots")

    map("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", "Select Device")
    map("n", "<leader>xp", "<cmd>XcodebuildSelectTestPlan<cr>", "Select Test Plan")
    map("n", "<leader>xq", "<cmd>Telescope quickfix<cr>", "Show QuickFix List")

    map("n", "<leader>xx", "<cmd>XcodebuildQuickfixLine<cr>", "Quickfix Line")
    map("n", "<leader>xa", "<cmd>XcodebuildCodeActions<cr>", "Show Code Actions")
end

-- Sem `cmd` aqui de propósito. Antes havia
--   cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) }
-- que nascia um subprocesso xcrun em TODA sessão, inclusive Go/TS, só para
-- resolver um caminho: 17ms de 17,3ms do custo deste arquivo.
--
-- O nvim-lspconfig já traz lsp/sourcekit.lua com cmd = { "sourcekit-lsp" },
-- os filetypes certos, um root_dir que entende buildServer.json / .bsp /
-- *.xcodeproj / *.xcworkspace / Package.swift, e capabilities extras. E o
-- shim /usr/bin/sourcekit-lsp respeita o xcode-select, então resolver na hora
-- de subir o LSP é mais correto que congelar o caminho no startup do nvim.
vim.lsp.config["sourcekit"] = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = on_attach,
}

vim.lsp.enable("sourcekit")
