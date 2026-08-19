-- neotest estava instalado desde sempre mas require("neotest").setup() nunca era
-- chamado em nenhum lugar do repo — era peso morto, sem adapter e sem keymap.
--
-- A sintaxe de registro DIFERE por adapter e é o erro clássico de primeira
-- tentativa: golang/jest/dart/dotnet são módulos chamáveis, vitest é usado nu.

require("neotest").setup({
    adapters = {
        require("neotest-golang")({
            -- gotestsum é fortemente recomendado upstream: o runner "go" puro lê
            -- JSON do stdout e sofre truncamento/corrupção; o gotestsum escreve
            -- em arquivo. Instalar: go install gotest.tools/gotestsum@latest
            runner = "gotestsum",
            go_test_args = { "-v", "-race", "-count=1" },

            -- "manual" em vez do default "dap-go". No modo dap-go o adapter
            -- chama require("dap-go").setup() a CADA sessão de debug, e o dap-go
            -- faz table.insert em dap.configurations.go sem limpar antes — o
            -- seletor do F5 acumularia 7 entradas por debug. Aqui usamos o
            -- adapter "go" definido em after/plugin/dap-go.lua, o que também
            -- dispensa o plugin nvim-dap-go inteiro.
            dap_mode = "manual",
            dap_manual_config = {
                name = "Debug testes Go (neotest)",
                type = "go", -- casa com dap.adapters.go de dap-go.lua
                request = "launch",
                mode = "test",
            },

            -- Suítes do testify. Funciona: verifiquei que o runtime carrega
            -- features/testify/queries/go/{testify_method,suite,package}.scm,
            -- todos presentes.
            --
            -- Mas :checkhealth neotest-golang vai reportar dois ❌ para
            -- "testify/namespace" e "testify/test_method" quando isto está
            -- ligado — o health.lua da v2.10.0 procura namespace.scm e
            -- test_method.scm, que o plugin não traz. É falso alarme do próprio
            -- health check, não uma quebra: a descoberta de testes foi validada
            -- com testify_enabled em true e em false, achando os 2 testes nos
            -- dois casos.
            testify_enabled = true,
        }),

        -- Nu, sem parênteses: é assim que este adapter é registrado.
        require("neotest-vitest"),

        -- NÃO sobrescrever jestArguments: sem --forceExit,
        -- --testLocationInResults, --json e --outputFile o adapter trava.
        -- E NÃO ligar jest_test_discovery: ele exige discovery.enabled = false
        -- global, o que degradaria Go, Dart e dotnet.
        require("neotest-jest")({}),

        require("neotest-dart")({
            command = "flutter", -- trocar por "fvm flutter" se usar FVM
            use_lsp = true,      -- usa o outline do dartls p/ nomes de teste que
                                 -- o treesitter não parseia (testWidgets etc.)
        }),

        require("neotest-dotnet"),
    },
})

local neotest = require("neotest")

local function map(key, fn, desc)
    vim.keymap.set("n", key, fn, { desc = desc })
end

map("<leader>tt", function() neotest.run.run() end, "Test: rodar mais próximo")
map("<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, "Test: rodar arquivo")
map("<leader>ta", function() neotest.run.run({ suite = true }) end, "Test: rodar suíte")
map("<leader>td", function() neotest.run.run({ strategy = "dap" }) end, "Test: debug mais próximo")
map("<leader>tl", function() neotest.run.run_last() end, "Test: repetir último")
map("<leader>tS", function() neotest.run.stop() end, "Test: parar")
map("<leader>ts", function() neotest.summary.toggle() end, "Test: summary")
map("<leader>to", function() neotest.output.open({ enter = true }) end, "Test: output")
map("<leader>tp", function() neotest.output_panel.toggle() end, "Test: painel de output")
map("<leader>tw", function() neotest.watch.toggle(vim.fn.expand("%")) end, "Test: watch arquivo")
map("]n", function() neotest.jump.next({ status = "failed" }) end, "Próxima falha de teste")
map("[n", function() neotest.jump.prev({ status = "failed" }) end, "Falha de teste anterior")
