-- import nvim-treesitter plugin
local treesitter = require("nvim-treesitter.configs")

-- configure treesitter
treesitter.setup({             -- enable syntax highlighting
    highlight = {
        enable = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    -- enable indentation
    indent = { enable = true },
    sync_install = false,
    -- ensure these language parsers are installed
    ensure_installed = {
        "vimdoc",
        "javascript",
        "typescript",
        "dockerfile",
        "lua",
        "clojure",
        "c_sharp",
        "bash",
        "html",
        "css",
        "json",
        "markdown",
        "sql",
        "yaml",
        "tsx",
        "scala"
    }
})

-- use bash-treesitter-parser for zsh
-- Autocmd that will actually be in charging of starting the whole thing
local zsh_as_bash_group = vim.api.nvim_create_augroup("zshAsBash", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = zsh_as_bash_group,
	pattern = {"*.sh", "*.zsh", "*zprofile" },
	command = "silent! set filetype=sh",
})

