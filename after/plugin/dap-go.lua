-- DAP para Go via delve. Instalar o adapter: :MasonInstall delve
--
-- O adapter chama-se "go" e não "delve" de propósito: é o nome que o
-- neotest-golang espera no dap_manual_config (ver after/plugin/neotest.lua), e
-- evita manter dois nomes para a mesma coisa.
--
-- Debug de UM teste específico vem do neotest (<leader>tD) — as configs abaixo
-- cobrem arquivo, pacote e os testes do pacote inteiro.

local dlv = vim.fn.stdpath("data") .. "/mason/bin/dlv"
if vim.fn.executable(dlv) == 0 then
    dlv = "dlv" -- fallback para o PATH
end

-- Registrado, não executado: o corpo abaixo só roda quando a pilha de DAP
-- inicializa (primeiro F5/F9). Ver lua/default/dap.lua.
require("default.dap").register(function(dap)
    dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
            command = dlv,
            args = { "dap", "-l", "127.0.0.1:${port}" },
        },
    }

    dap.configurations.go = {
        {
            type = "go",
            name = "Debug arquivo atual",
            request = "launch",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug pacote",
            request = "launch",
            program = "./${relativeFileDirname}",
        },
        {
            type = "go",
            name = "Debug testes do pacote",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
        {
            type = "go",
            name = "Attach a processo",
            request = "attach",
            mode = "local",
            processId = require("dap.utils").pick_process,
        },
    }
end)
