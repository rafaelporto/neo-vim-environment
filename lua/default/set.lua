-- ─── UI ───────────────────────────────────────────────────────────────────────
vim.opt.guicursor = ""
vim.opt.termguicolors = true
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.wrap = false

-- ─── Line Numbers ─────────────────────────────────────────────────────────────
vim.opt.nu = true
vim.opt.relativenumber = true

-- ─── Indentation ──────────────────────────────────────────────────────────────
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- ─── Search ───────────────────────────────────────────────────────────────────
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- ─── Files ────────────────────────────────────────────────────────────────────
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.isfname:append("@-@")

-- ─── Performance ──────────────────────────────────────────────────────────────
vim.opt.updatetime = 50

-- ─── Plugins ──────────────────────────────────────────────────────────────────

-- conjure
vim.g["conjure#log#botright"] = true
vim.g["conjure#debug"] = false
vim.g["conjure#mapping#doc_word"] = false

-- markdown
vim.g["mkdp_auto_start"] = 0
vim.g["mkdp_refresh_slow"] = 0

-- copilot
vim.g.copilot_assume_mapped = true
vim.g.copilot_no_tab_map = true
