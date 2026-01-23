vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
    { silent = true, noremap = true, desc = "Trouble quickfix" })

local trouble = require("trouble")

vim.api.nvim_create_autocmd("User", {
    pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
    callback = function(event)
        if event.data.cancelled then
            return
        end

        if event.data.success then
            trouble.close()
        elseif not event.data.failedCount or event.data.failedCount > 0 then
            if next(vim.fn.getqflist()) then
                trouble.open("quickfix")
            else
                trouble.close()
            end

            trouble.refresh()
        end
    end,
})
