-- Flutter/Dart via flutter-tools.nvim
-- dartls is bundled with the Flutter SDK — no Mason install needed.
-- SDK path: ~/sdk-flutter (update here if you move it)
-- Debugger: `flutter debug_adapter` (bundled). Use standard DAP keymaps: F5/F9/F10/F11.
-- Hot reload: <leader>Fr  |  Hot restart: <leader>FH

local flutter_sdk = vim.fn.expand("~/sdk-flutter")

require("flutter-tools").setup({
    flutter_path = flutter_sdk .. "/bin/flutter",
    widget_guides = { enabled = false },
    closing_tags = {
        highlight = "ErrorMsg",
        prefix = " // ",
        enabled = true,
    },
    dev_log = {
        enabled = true,
        open_cmd = "tabedit",
    },
    debugger = {
        enabled = true,
        run_via_dap = true,
        exception_breakpoints = {},
    },
    lsp = {
        color = {
            enabled = true,
            virtual_text = true,
            virtual_text_str = "■",
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
        },
        on_attach = function(_, bufnr)
            local function map(key, cmd, desc)
                vim.keymap.set("n", key, cmd, { buffer = bufnr, desc = desc })
            end
            map("<leader>FR", "<cmd>FlutterRun<cr>", "Flutter Run")
            map("<leader>Fd", "<cmd>FlutterDevices<cr>", "Flutter Devices")
            map("<leader>Fe", "<cmd>FlutterEmulators<cr>", "Flutter Emulators")
            map("<leader>Fq", "<cmd>FlutterQuit<cr>", "Flutter Quit")
            map("<leader>Fr", "<cmd>FlutterReload<cr>", "Flutter Hot Reload")
            map("<leader>FH", "<cmd>FlutterRestart<cr>", "Flutter Hot Restart")
            map("<leader>Fl", "<cmd>FlutterLspRestart<cr>", "Flutter LSP Restart")
            map("<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", "Flutter Outline")
            map("<leader>FD", "<cmd>FlutterDevTools<cr>", "Flutter DevTools")
        end,
    },
})
