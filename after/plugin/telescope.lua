local builtin = require('telescope.builtin')
local telescope = require('telescope')
local theme = require('telescope.themes')

telescope.setup {
	defaults = {
		mappings = {
			i = { ["<C-t>"] = require('trouble.providers.telescope').open_with_trouble },
			n = { ["<C-t>"] = require('trouble.providers.telescope').open_with_trouble },
		}
	},
	extensions = {
		["ui-select"] = {
			theme.get_dropdown { },
			file_browser = {
				theme = 'ivy',
				hijack_newtrw = true,
			},
			project = {
				theme = 'dropdown',
				sync_with_nvim_tree = true,
			}
		},
		project = {
			sync_with_nvim_tree = true,
		}
	}
}

telescope.load_extension('ui-select')
telescope.load_extension('dap')
telescope.load_extension('noice')

vim.keymap.set('n', '<leader>stl', builtin.treesitter, { desc = 'Lists Function names, variables, from Treesitter' })
vim.keymap.set('n', '<leader>sF', "<cmd>Telescope find_files hidden=true no_ignore=true<CR>", { desc = 'Find All Files' })
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Find Grep' })
 vim.keymap.set('n', '<leader>sG', function() builtin.live_grep { additional_args = { '--no-ignore' } } end,	{ desc = 'Find Grep Including In .gitignore' })
vim.keymap.set('n', '<leader>sG',
	function()
		builtin.live_grep { additional_args = function(args)
			return vim.list_extend(args,
				{ '--hidden', '--no-ignore' })
		end }
	end, { desc = 'Find Grep Everything' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>sc', builtin.current_buffer_fuzzy_find, { desc = 'Find in current buffer' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Find Diagnostics' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Find Keymaps' })
vim.keymap.set('n',  '<C-p>', builtin.git_files, { desc = 'Find Project git files' })
vim.keymap.set('n', '<leader>sB', ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File Browser" })
vim.keymap.set('n', '<leader>sP', ":Telescope project<CR>", { desc = "Find Projects" })
vim.keymap.set('n', '<leader>sr', builtin.registers, { desc = 'Find Registers' })
vim.keymap.set('n', '<leader>sR', builtin.resume, { desc = 'Open last picker' })
vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = 'Find Marks' })
vim.keymap.set('n', '<leader>sC', function()
	builtin.colorscheme({ enable_preview = true })
end, { desc = 'Find Color Scheme' })
vim.keymap.set('n', '<leader>sj', builtin.jumplist, { desc = 'Find Jump List' })
vim.keymap.set('n', '<leader>so', builtin.oldfiles, { desc = 'Find Recent Files' })

vim.keymap.set('n', '<leader>sqf', builtin.quickfix, { desc = 'Find Quick Fixes' })
vim.keymap.set('n', '<leader>gi', builtin.lsp_implementations, { desc = 'Find Implementations' })
vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, { desc = 'Find Definitions' })
vim.keymap.set('n', '<leader>gD', builtin.lsp_type_definitions, { desc = 'Find Definitions' })
vim.keymap.set('n', '<leader>gr', builtin.lsp_references, { desc = 'Find references for word under the cursor' })

vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git Branches' })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })
vim.keymap.set('n', '<leader>gS', builtin.git_stash, { desc = 'Git Stash' })


vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = 'Find Telescope Pickers' })
vim.keymap.set('n', '<leader>sT', builtin.builtin, { desc = 'Find Telescope cached Pickers' })

vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
