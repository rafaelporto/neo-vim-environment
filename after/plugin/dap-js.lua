-- DAP para JavaScript / TypeScript via js-debug-adapter
-- Instalar: :MasonInstall js-debug-adapter
--
-- Os nomes seguem o vscode-js-debug: pwa-node / pwa-chrome.
-- Debug de teste vem do neotest (<leader>tD), então não há config de jest/vitest
-- aqui.


local adapter_bin = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter"
if vim.fn.executable(adapter_bin) == 0 then
    return -- não instalado; silêncio em vez de alertar a cada startup
end

-- Registrado, não executado: o corpo abaixo só roda quando a pilha de DAP
-- inicializa (primeiro F5/F9). Ver lua/default/dap.lua.
require("default.dap").register(function(dap)
    for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
        dap.adapters[adapter] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = { command = adapter_bin, args = { "${port}" } },
        }
    end

    local configurations = {
        {
            -- O Node 26 faz type stripping nativo, então .ts roda direto: não há
            -- config de ts-node/tsx de propósito.
            type = "pwa-node",
            request = "launch",
            name = "Launch arquivo atual",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        {
            -- args/url como função: o prompt dispara no F5, não no startup.
            type = "pwa-node",
            request = "launch",
            name = "Launch npm script",
            runtimeExecutable = "npm",
            runtimeArgs = function()
                return { "run", vim.fn.input("npm script: ", "dev") }
            end,
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach a processo",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
        {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome em localhost",
            url = function()
                return vim.fn.input("URL: ", "http://localhost:3000")
            end,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
            userDataDir = false,
        },
        {
            type = "pwa-chrome",
            request = "attach",
            name = "Attach ao Chrome (--remote-debugging-port=9222)",
            port = 9222,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
        },
    }

    for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[ft] = configurations
    end
end)
