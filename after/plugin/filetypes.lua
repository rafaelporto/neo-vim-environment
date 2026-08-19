local zsh_as_bash_group = vim.api.nvim_create_augroup("zshAsBash", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = zsh_as_bash_group,
    pattern = { "*.tmux", "*.sh", "*.zsh", "*zprofile" },
    command = "silent! set filetype=sh",
})


local json_group = vim.api.nvim_create_augroup("jsonFiles", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = json_group,
    pattern = { "*.json", "*.jsonc", "*.json.base" },
    command = "silent! set filetype=json",
})
