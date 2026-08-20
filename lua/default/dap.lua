-- Inicialização preguiçosa da pilha de DAP.
--
-- Antes, quatro arquivos em after/plugin/ (debugging.lua e os três dap-*.lua)
-- faziam require("dap") no nível do arquivo, então nvim-dap, nvim-dap-ui,
-- nvim-dap-virtual-text e nvim-nio subiam em TODA sessão — o depurador inteiro
-- carregado para ler código. Adiar só um dos arquivos não resolveria nada,
-- porque qualquer um dos outros três já puxava a pilha.
--
-- Este módulo é o ponto único: os arquivos por linguagem registram uma função
-- em vez de tocar o dap, e nada carrega até o primeiro F5/F9/<leader>Du (ou um
-- debug de teste pelo neotest).

local M = {}

local registered = {}
local did_init = false

--- Registra configuração de adapter/configurations de uma linguagem.
--- A função só é chamada quando a pilha de DAP realmente inicializa, e recebe
--- o módulo `dap` já carregado.
---@param fn fun(dap: table)
function M.register(fn)
    table.insert(registered, fn)
end

--- Garante que a pilha está inicializada; devolve o módulo `dap`.
---@return table dap
function M.ensure()
    local dap = require("dap")
    if did_init then
        return dap
    end
    did_init = true

    require("nvim-dap-virtual-text").setup()

    local dapui = require("dapui")
    dapui.setup(M.ui_opts or {})

    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    -- Extensão do telescope para DAP (:Telescope dap commands/configurations/
    -- list_breakpoints/variables/frames). Só faz sentido durante um debug, e é
    -- ela que puxava o telescope-dap -> dap em todo startup.
    pcall(function()
        require("telescope").load_extension("dap")
    end)

    for _, fn in ipairs(registered) do
        fn(dap)
    end

    return dap
end

--- Devolve o módulo dapui, inicializando a pilha se preciso.
function M.ui()
    M.ensure()
    return require("dapui")
end

return M
