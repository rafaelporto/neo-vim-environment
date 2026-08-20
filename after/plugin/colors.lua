-- setup() por tema, executado só quando aquele tema é de fato escolhido.
-- Antes, github-theme e catppuccin rodavam setup() no startup mesmo sem nunca
-- serem selecionados (ColorMyPencils só recebe dracula ou tokyonight-day).
local theme_setup = {
    ["github_dark"] = function() require("github-theme").setup({ options = { transparent = true } }) end,
    ["github_light"] = function() require("github-theme").setup({ options = { transparent = true } }) end,
    ["catppuccin"] = function() require("catppuccin").setup({ transparent_background = true }) end,
}

function ColorMyPencils(color)
    color = color or "dracula"
    local setup = theme_setup[color]
    if setup then
        setup()
    end
    vim.cmd.colorscheme(color)
end

local clients_lsp = function()
    local bufnr = vim.api.nvim_get_current_buf()

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if next(clients) == nil then
        return ""
    end

    local c = {}
    for _, client in pairs(clients) do
        table.insert(c, client.name)
    end
    return "\u{f085} " .. table.concat(c, "|")
end

require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = {
            {
                require("noice").api.status.command.get,
                cond = require("noice").api.status.command.has,
                color = { fg = "#ff9e64" },
            },
            {
                require("noice").api.status.search.get,
                cond = require("noice").api.status.search.has,
                color = { fg = "#ff9e64" },
            },
        },
        lualine_y = { clients_lsp, "encoding", "filetype" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    winbar = {},
    inactive_winbar = {
        lualine_a = { "filename", "diagnostics" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    extensions = {},
})

local time = os.date("*t")
if time.hour < 8 or time.hour >= 17 then
    ColorMyPencils("dracula")
else
    ColorMyPencils("tokyonight-day")
end
