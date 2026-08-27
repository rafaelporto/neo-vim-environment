-- Roslyn LSP (C#) — seblyng/roslyn.nvim
--
-- Divisão de responsabilidades:
--   * o plugin registra a config base em lsp/roslyn.lua (cmd, filetypes,
--     root_dir via resolução de .sln/.csproj) e o plugin/roslyn.lua dele chama
--     vim.lsp.enable("roslyn");
--   * as opções do plugin (solution picking, filewatching) vão em `opts` no
--     spec do lazy, em lua/default/plugins.lua;
--   * este arquivo só estende a config do servidor.
--
-- Nada aqui faz require("roslyn"): é declarativo de propósito. Um require em
-- nível de arquivo carregaria o plugin em toda sessão e anularia o ft = { "cs" }
-- do spec.
--
-- `capabilities` não é definido aqui — o wildcard vim.lsp.config("*", ...) de
-- lsp.lua é merge layer 1 e já cobre este servidor.
--
-- Servidor: :MasonInstall roslyn (precisa do registry Crashdummyy, ver lsp.lua).
-- Requer o dotnet SDK no PATH: o Roslyn usa o MSBuild dele para carregar a
-- solution.

vim.lsp.config("roslyn", {
    settings = {
        -- Os hints só aparecem se o cliente ligar inlay hints; lsp.lua faz isso
        -- no LspAttach para todo servidor com textDocument/inlayHint.
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            -- Sem estes três a anotação repete o que o código já diz.
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },

        -- lsp.lua já expõe <leader>lc (run) e faz o refresh no LspAttach.
        ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
        },

        ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_provide_regex_completions = true,
        },

        -- O Roslyn é o único formatter de C# aqui: conform declara
        -- cs = { "csharpier" } mas o binário não é instalado, então o
        -- lsp_format = "fallback" manda a formatação para este servidor. Sem esta
        -- chave ele formataria sem tocar nos `using` — é o equivalente ao
        -- goimports que o Go tem.
        ["csharp|formatting"] = {
            dotnet_organize_imports_on_format = true,
        },
    },
})

-- Deliberadamente ausente: ["csharp|background_analysis"]. O escopo escolhido é
-- `openFiles`, que já é o default do servidor, então declarar a chave seria
-- no-op. `fullSolution` foi considerado e rejeitado: numa solution grande custa
-- CPU e RAM continuamente, e esta máquina roda gopls em paralelo. Erro em
-- arquivo fechado aparece no build.
