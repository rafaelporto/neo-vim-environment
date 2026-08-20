-- Keymaps de debug e layout da UI.
--
-- A pilha (nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, nvim-nio) só carrega no
-- primeiro toque de uma destas teclas — ver lua/default/dap.lua para o porquê.
local lazydap = require("default.dap")

-- Layout da dapui, aplicado quando a pilha inicializa.
lazydap.ui_opts =     {
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
            -- Use a table to apply multiple mappings
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
        },
        -- Use this to override mappings for specific elements
        element_mappings = {
            -- Example:
            -- stacks = {
            --   open = "<CR>",
            --   expand = "o",
            -- }
        },
        -- Expand lines larger than the window
        -- Requires >= 0.7
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position. It can be an Int
        -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
        -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
            {
                elements = {
                    -- Elements can be strings or table with id and size keys.
                    { id = "scopes", size = 0.25 },
                    "breakpoints",
                    "stacks",
                    "watches",
                },
                size = 40, -- 40 columns
                position = "left",
            },
            {
                elements = {
                    "repl",
                    "console",
                },
                size = 0.25, -- 25% of total lines
                position = "bottom",
            },
        },
        controls = {
            -- Requires Neovim nightly (or 0.8 when released)
            enabled = true,
            -- Display controls in this element
            element = "repl",
            icons = {
                pause = "",
                play = "",
                step_into = "",
                step_over = "",
                step_out = "",
                step_back = "",
                run_last = "↻",
                terminate = "□",
            },
        },
        floating = {
            max_height = nil, -- These can be integers or a float between 0 and 1.
            max_width = nil, -- Floats will be treated as percentage of your screen.
            border = "single", -- Border style. Can be "single", "double" or "rounded"
            mappings = {
                close = { "q", "<Esc>" },
            },
        },
        windows = { indent = 1 },
        render = {
            max_type_length = nil, -- Can be integer or nil.
            max_value_lines = 100, -- Can be integer or nil.
        },
    }

local function action(name)
    return function()
        local dap = lazydap.ensure()
        dap[name]()
    end
end

vim.keymap.set("n", "<F9>", action("toggle_breakpoint"), { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<F5>", action("continue"), { desc = "Continue debug" })
vim.keymap.set("n", "<F11>", action("step_into"), { desc = "Step into" })
vim.keymap.set("n", "<s-F11>", action("step_out"), { desc = "Step out" })
vim.keymap.set("n", "<F10>", action("step_over"), { desc = "Step over" })
vim.keymap.set("n", "<s-F5>", action("close"), { desc = "Stop debug" })

-- <leader>Du / <leader>Dc e não <leader>du / <leader>duc: <leader>d é o
-- delete-sem-yank, um OPERATOR, então enquanto houvesse um <leader>du toda
-- composição <leader>dw / <leader>dip / <leader>d} pagava timeoutlen esperando
-- para ver se o "u" vinha. Maiúscula segue o padrão de <leader>F (Flutter) e
-- <leader>X (xcodebuild).
vim.keymap.set("n", "<leader>Du", function() lazydap.ui().toggle() end, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>Dc", function() lazydap.ui().close() end, { desc = "Close DAP UI" })
