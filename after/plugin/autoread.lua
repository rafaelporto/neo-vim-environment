-- `autoread` já vem ligado no nvim, mas só age quando algo dispara `checktime`,
-- e nada disparava. FocusGained é o gatilho deste layout (alternar do painel do
-- Claude para o do nvim) e só chega com `focus-events on` no tmux.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
	desc = "Recarrega buffers alterados fora do nvim",
	command = "checktime",
})

-- Recarregar em silêncio é pior que não recarregar: o texto muda sob o cursor
-- sem explicação. Buffer com alteração não salva não é sobrescrito.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	desc = "Avisa quando o buffer foi recarregado do disco",
	callback = function()
		vim.notify("buffer recarregado: alterado fora do nvim", vim.log.levels.WARN)
	end,
})
