local zsh_as_bash_group = vim.api.nvim_create_augroup("zshAsBash", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = zsh_as_bash_group,
    pattern = { "*.tmux", "*.sh", "*.zsh", "*zprofile" },
    command = "silent! set filetype=sh",
})

-- ─── Helm ────────────────────────────────────────────────────────────────────
-- yamlls tries to parse every *.yaml/*.yml as plain YAML. A Helm template
-- mixes YAML with Go-template syntax (`{{- if .strategy }}`), which breaks the
-- yamlls parser: "Unexpected flow-map-end token in YAML stream: '}'" on lines
-- like `type: {{ if .strategy }} {{ default "Recreate" .strategy.type }} ...`.
--
-- yamlls does not listen on the `helm` filetype (only `yaml`,
-- `yaml.docker-compose`, `yaml.gitlab`, `yaml.helm-values` — see
-- lsp/yamlls.lua in nvim-lspconfig), so giving templates that filetype already
-- takes them out of its reach, no manual exclusion needed. helm_ls
-- (mrjosh/helm-ls) is the dedicated LSP, configured in after/plugin/lsp.lua.
--
-- `yaml.helm-values` is the composite filetype both yamlls AND helm_ls already
-- listen on by default (same nvim-lspconfig files) — so values.yaml keeps
-- normal YAML validation from yamlls and gains `.Values` completion/hover
-- from helm_ls, both attached to the same buffer.
--
-- Both detector functions only return the dedicated filetype when there is a
-- real Chart.yaml nearby; otherwise they return nil and Neovim falls back to
-- the default extension-based detection (`yaml`) — so a `templates/` folder
-- that is not part of an actual Helm chart is unaffected.

-- Walk up from `dir` looking for Chart.yaml (covers templates/**, which can be
-- N levels below the chart root: templates/deploy.yaml -> 1 level up;
-- templates/tests/test-connection.yaml -> 2 levels up).
local function has_chart_yaml_ancestor(dir)
    return vim.fs.find("Chart.yaml", { upward = true, path = dir, type = "file", limit = 1 })[1] ~= nil
end

-- values.yaml/values-*.yaml always live next to Chart.yaml — sibling check,
-- not ancestor, so a stray values.yaml elsewhere isn't caught just because
-- some distant ancestor happens to be a chart.
local function has_chart_yaml_sibling(dir)
    return vim.uv.fs_stat(vim.fs.joinpath(dir, "Chart.yaml")) ~= nil
end

local function detect_helm_template(path)
    if has_chart_yaml_ancestor(vim.fs.dirname(path)) then
        return "helm"
    end
end

local function detect_helm_values(path)
    if has_chart_yaml_sibling(vim.fs.dirname(path)) then
        return "yaml.helm-values"
    end
end

-- No trailing `$` on these: vim.filetype.add already wraps every pattern in
-- `^...$` itself (see normalize_path/M.add in $VIMRUNTIME/lua/vim/filetype.lua),
-- so a pattern-local `$` produces a literal `$$` that never matches anything.
vim.filetype.add({
    pattern = {
        -- templates/**/*.yaml, templates/**/*.yml, templates/**/*.tpl
        [".*/templates/.*%.ya?ml"] = detect_helm_template,
        [".*/templates/.*%.tpl"] = detect_helm_template,

        -- values.yaml, values.yml, values-prod.yaml, values.prod.yaml, ...
        [".*/values%.ya?ml"] = detect_helm_values,
        [".*/values[%.%-][%w%.%-]*%.ya?ml"] = detect_helm_values,
    },
})
