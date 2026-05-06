-- nvim 0.12+ ships all parsers bundled; no plugin needed.
-- Built-in ftplugins already call vim.treesitter.start() for most filetypes.
-- This autocmd handles the remaining ones.
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
