-- DAP configuration for .NET (C#) via netcoredbg
-- Install adapter: Mason -> netcoredbg

-- Registrado, não executado: o corpo abaixo só roda quando a pilha de DAP
-- inicializa (primeiro F5/F9). Ver lua/default/dap.lua.
require("default.dap").register(function(dap)
    dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
        args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
        {
            type = "coreclr",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end,
        },
        {
            type = "coreclr",
            name = "Attach",
            request = "attach",
            processId = require("dap.utils").pick_process,
        },
    }
end)
