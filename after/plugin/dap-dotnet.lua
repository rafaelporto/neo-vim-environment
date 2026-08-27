-- DAP para .NET (C#) via netcoredbg
--
-- O adapter NÃO vem do Mason: o pacote `netcoredbg` do mason-org entrega
-- netcoredbg-osx-amd64.tar.gz para o target darwin_arm64, e um debugger x64 não
-- anexa a um processo arm64 — o netcoredbg usa dbgshim/ICorDebug, que exige a
-- mesma arquitetura do alvo. Quem fornece o build arm64 é o
-- netcoredbg-macOS-arm64.nvim, com o binário commitado no repo do plugin.
--
-- Registrado, não executado: o corpo abaixo só roda quando a pilha de DAP
-- inicializa (primeiro F5/F9). Ver lua/default/dap.lua.

--- Acha a dll mais plausível para depurar, a partir da raiz da solution.
---
--- Critério: só assemblies com `<nome>.runtimeconfig.json` ao lado, porque esse
--- arquivo é gerado apenas para projeto executável — é o que separa o assembly do
--- projeto das dezenas de dlls de dependência que compartilham o bin/, e também
--- descarta class library. Filtrar por "dll mais curta" não serve: numa pasta de
--- saída típica a vencedora é uma dependência qualquer.
---
--- Entre os executáveis, prefere o do projeto do buffer atual; a saída de um
--- projeto de teste também recebe cópia dos executáveis referenciados, e essas
--- cópias são descartadas porque o nome da dll não bate com o do projeto.
---
--- O get_dll_path() do plugin arm64 procura em `<dir do arquivo atual>/bin/Debug`,
--- o que só acerta com o buffer na raiz do projeto; de uma subpasta ele cai no cwd.
---@return string
local function guess_dll()
    -- Markers como função, não glob: vim.fs.root repassa a string para
    -- vim.fs.find, que casa nome exato — "*.sln" nunca casaria.
    -- A tabela é ordenada e o primeiro marker que casar ganha: a solution vem
    -- antes do csproj de propósito, senão editar um arquivo de uma lib nunca
    -- encontraria a dll do executável.
    local root = vim.fs.root(0, {
        function(name) return name:match("%.slnx?$") ~= nil end,
        function(name) return name:match("%.csproj$") ~= nil end,
    }) or vim.fn.getcwd()

    -- Projeto do buffer atual, para desempate.
    local own = vim.fs.root(0, function(name) return name:match("%.csproj$") ~= nil end)
    own = own and vim.fs.basename(own) or nil

    local candidates = {}
    for _, cfg in ipairs(vim.fs.find(function(name, path)
        return name:match("%.runtimeconfig%.json$") ~= nil
            and path:match("/bin/Debug/net[^/]*$") ~= nil
    end, { path = root, type = "file", limit = math.huge })) do
        local name = vim.fs.basename(cfg):gsub("%.runtimeconfig%.json$", "")
        -- `<proj>/bin/Debug/net*/` -> sobe 3 níveis para achar o dir do projeto.
        local proj = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(cfg)))))
        if name == proj then
            local dll = vim.fs.joinpath(vim.fs.dirname(cfg), name .. ".dll")
            if vim.uv.fs_stat(dll) then
                table.insert(candidates, { path = dll, own = (name == own) })
            end
        end
    end

    if #candidates == 0 then
        -- Nada compilado ainda: devolve a raiz para o prompt completar em cima.
        return root .. "/"
    end

    table.sort(candidates, function(a, b)
        if a.own ~= b.own then
            return a.own
        end
        return a.path < b.path
    end)
    return candidates[1].path
end

require("default.dap").register(function(dap)
    local ok, netcoredbg = pcall(require, "netcoredbg-macOS-arm64")
    if not ok then
        vim.notify(
            "netcoredbg-macOS-arm64.nvim não carregou; debug de C# indisponível",
            vim.log.levels.WARN
        )
        return
    end

    -- Registra dap.adapters.coreclr E dap.adapters.netcoredbg, ambos apontando
    -- para o binário arm64. O alias `netcoredbg` importa: é o adapter_name que o
    -- neotest-dotnet declara em after/plugin/neotest.lua, usado pelo <leader>tD.
    -- setup() não recebe argumento — faz require("dap") internamente, o que é
    -- seguro aqui porque a pilha já subiu.
    netcoredbg.setup()

    -- Depois do setup(), nunca antes: o plugin também define configurations.cs
    -- (uma entrada só, que pergunta ASPNETCORE_* a cada launch) e a última
    -- escrita ganha.
    dap.configurations.cs = {
        {
            type = "coreclr",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to dll: ", guess_dll(), "file")
            end,
            cwd = "${workspaceFolder}",
            -- Fixo em vez de perguntar: é o que faz o app carregar
            -- appsettings.Development.json, e prompt a cada F5 cansa.
            env = { ASPNETCORE_ENVIRONMENT = "Development" },
        },
        {
            type = "coreclr",
            name = "Attach a processo",
            request = "attach",
            processId = require("dap.utils").pick_process,
        },
    }
end)
