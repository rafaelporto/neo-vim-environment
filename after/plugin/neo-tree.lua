require("neo-tree").setup({
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    window = {
        position = "left",
        width = 35,
    },
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
        },
        follow_current_file = {
            enabled = true,
        },
    },
})
