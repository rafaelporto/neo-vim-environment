-- DAP para Swift/iOS via xcodebuild.nvim
-- Xcode 16+: codelldb não é mais necessário; o xcodebuild.setup() cuida do adapter.
--
-- Adiado por filetype de propósito. Antes o require estava no nível do arquivo e
-- carregava o xcodebuild INTEIRO em toda sessão — 11,04 ms medidos, em Go, TS ou
-- Dart, para registrar um adapter de debug que só serve a Swift.
--
-- Seguro adiar: o adapter só precisa existir antes de você iniciar um debug, o
-- que necessariamente acontece depois de abrir um buffer Swift.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("dap_swift", { clear = true }),
    pattern = { "swift", "objc", "objcpp" },
    once = true,
    callback = function()
        require("xcodebuild.integrations.dap").setup()
    end,
})
