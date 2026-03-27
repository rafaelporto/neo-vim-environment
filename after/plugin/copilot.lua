vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
    desc = "Copilot: Accept suggestion",
})
