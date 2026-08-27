-- neotest estava instalado desde sempre mas require("neotest").setup() nunca era
-- chamado em nenhum lugar do repo — era peso morto, sem adapter e sem keymap.
--
-- O setup é DEFERIDO até o primeiro <leader>t. Fazê-lo no nível do arquivo
-- carregava o neotest, o nvim-nio, o FixCursorHold e os 5 adapters em toda
-- sessão: medido em ~19ms de startup (195ms -> 176ms ao remover este arquivo),
-- para algo que só serve ao rodar teste. E não se perde nada: os sinais do
-- neotest só mostram resultado DEPOIS de uma execução, que por definição começa
-- num destes keymaps.
--
-- Todos os cinco adapters têm metamétodo __call, então a diferença não é
-- "chamável ou não": chamar passa opções, usar nu aceita os defaults. Abaixo,
-- golang/jest/dart são chamados porque precisam de opções; vitest e dotnet vão
-- nus. Errar isso é o tropeço clássico de primeira tentativa.

local did_setup = false

local function neotest()
    if not did_setup then
        did_setup = true
        require("neotest").setup({
            adapters = {
                require("neotest-golang")({
                    -- gotestsum é fortemente recomendado upstream: o runner "go"
                    -- puro lê JSON do stdout e sofre truncamento/corrupção; o
                    -- gotestsum escreve em arquivo.
                    -- Instalar: go install gotest.tools/gotestsum@latest
                    runner = "gotestsum",
                    go_test_args = { "-v", "-race", "-count=1" },

                    -- "manual" em vez do default "dap-go". No modo dap-go o
                    -- adapter chama require("dap-go").setup() a CADA sessão de
                    -- debug, e o dap-go faz table.insert em
                    -- dap.configurations.go sem limpar antes — o seletor do F5
                    -- acumularia 7 entradas por debug (medido: 4 -> 4 aqui, seria
                    -- 39 com o default). Usamos o adapter "go" de
                    -- after/plugin/dap-go.lua, o que dispensa o plugin
                    -- nvim-dap-go inteiro.
                    dap_mode = "manual",
                    dap_manual_config = {
                        name = "Debug testes Go (neotest)",
                        type = "go", -- casa com dap.adapters.go de dap-go.lua
                        request = "launch",
                        mode = "test",
                    },

                    -- Suítes do testify. Funciona: o runtime carrega
                    -- features/testify/queries/go/{testify_method,suite,package}.scm,
                    -- todos presentes.
                    --
                    -- Mas :checkhealth neotest-golang reporta dois ❌ para
                    -- "testify/namespace" e "testify/test_method" com isto
                    -- ligado — o health.lua da v2.10.0 procura namespace.scm e
                    -- test_method.scm, que o plugin não traz. É falso alarme do
                    -- health check, não quebra: a descoberta foi validada com
                    -- testify_enabled em true e em false, achando os 2 testes
                    -- nos dois casos.
                    testify_enabled = true,
                }),

                -- Nu, sem parênteses: é assim que este adapter é registrado.
                require("neotest-vitest"),

                -- NÃO sobrescrever jestArguments: sem --forceExit,
                -- --testLocationInResults, --json e --outputFile o adapter trava.
                -- E NÃO ligar jest_test_discovery: exige discovery.enabled =
                -- false global, degradando Go, Dart e dotnet.
                require("neotest-jest")({}),

                require("neotest-dart")({
                    command = "flutter", -- trocar por "fvm flutter" se usar FVM
                    use_lsp = true,      -- outline do dartls p/ nomes que o
                                         -- treesitter não parseia (testWidgets)
                }),

                require("neotest-dotnet")({
                    -- Explícito, ainda que seja o default do adapter: ele emite
                    -- `type = <adapter_name>` na estratégia de dap, e dap-dotnet.lua
                    -- registra tanto `coreclr` quanto `netcoredbg`. Declarar aqui é
                    -- o que impede o <leader>tD de voltar a apontar para um adapter
                    -- inexistente se um dos dois nomes desaparecer.
                    dap = { adapter_name = "netcoredbg" },
                    -- Default é "project", que ancora a descoberta no .csproj do
                    -- buffer atual — numa solution onde só um projeto tem testes,
                    -- pedir <leader>ta de qualquer outro arquivo não acha nada.
                    -- Custo: o dotnet test roda na solution inteira.
                    discovery_root = "solution",
                }),
            },
        })
    end
    return require("neotest")
end

local function map(key, fn, desc)
    vim.keymap.set("n", key, fn, { desc = desc })
end

map("<leader>tt", function() neotest().run.run() end, "Test: rodar mais próximo")
map("<leader>tf", function() neotest().run.run(vim.fn.expand("%")) end, "Test: rodar arquivo")
map("<leader>ta", function() neotest().run.run({ suite = true }) end, "Test: rodar suíte")
-- <leader>tD e não <leader>td: o todo-comment.lua já usa <leader>td para
-- :TodoTelescope e carrega DEPOIS deste arquivo na ordem alfabética, então o
-- td daqui nunca disparava. Casa com o <leader>tS (parar), também maiúsculo.
map("<leader>tD", function()
    -- ensure() antes: o neotest carrega o nvim-dap por conta própria, mas os
    -- listeners que abrem a dapui vivem em lua/default/dap.lua. Sem isto o
    -- debug rodaria sem UI.
    require("default.dap").ensure()
    neotest().run.run({ strategy = "dap" })
end, "Test: debug mais próximo")
map("<leader>tl", function() neotest().run.run_last() end, "Test: repetir último")
map("<leader>tS", function() neotest().run.stop() end, "Test: parar")
map("<leader>ts", function() neotest().summary.toggle() end, "Test: summary")
map("<leader>to", function() neotest().output.open({ enter = true }) end, "Test: output")
map("<leader>tp", function() neotest().output_panel.toggle() end, "Test: painel de output")
map("<leader>tw", function() neotest().watch.toggle(vim.fn.expand("%")) end, "Test: watch arquivo")
map("]n", function() neotest().jump.next({ status = "failed" }) end, "Próxima falha de teste")
map("[n", function() neotest().jump.prev({ status = "failed" }) end, "Falha de teste anterior")
