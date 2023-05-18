vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({

	-- colorscheme
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			vim.o.background = "dark"
			vim.g.gruvbox_material_background = "hard"
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},

	-- git signs
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
	},

	-- lazygit
	{
		"kdheepak/lazygit.nvim"
	},

	-- lualine
	{
		'nvim-lualine/lualine.nvim',
		event = "VeryLazy",
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require("lualine").setup()
		end
	},

	-- LSP ZERO
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{
				-- Optional
				"williamboman/mason.nvim",
				build = function()
					pcall(vim.cmd, "MasonUpdate")
				end,
			},
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "L3MON4D3/LuaSnip" }, -- Required
		},
		config = function()
			local lsp = require("lsp-zero").preset("recommended")

			lsp.ensure_installed({
				"rust_analyzer",
				"tsserver",
				"lua_ls",
				"gopls",
			})

			lsp.on_attach(function(client, bufnr)
				local opts = { buffer = bufnr, remap = false }
				vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
				vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
				vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
				vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
				vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
				vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", opts)
				vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
				vim.keymap.set("n", "lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set("n", "la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

				vim.keymap.set("n", "lw", "<cmd>Telescope diagnostics<cr>", opts)
				vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
				vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
				vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)

				-- check file type, if Go then use GoFmt else the default
				if vim.bo.filetype == "go" then
					vim.keymap.set({ "n", "x" }, "lf", "<cmd>GoFmt<cr>", opts)
				else
					vim.keymap.set({ "n", "x" }, "lf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
				end
			end)

			lsp.set_preferences({
				suggest_lsp_servers = false,
				sign_icons = {
					error = "E",
					warn = "W",
					hint = "H",
					info = "I",
				},
			})

			require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

			lsp.setup()

			local cmp = require("cmp")
			local cmp_action = require("lsp-zero").cmp_action()

			cmp.setup({
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = {
					["<Tab>"] = cmp_action.luasnip_supertab(),
					["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
				},

				sources = {
					-- Copilot Source
					{ name = "copilot",  group_index = 2 },
					-- Other Sources
					{ name = "nvim_lsp", group_index = 2 },
					{ name = "path",     group_index = 2 },
					{ name = "luasnip",  group_index = 2 },
				},
			})
		end,
	},

	-- better diagnostics list and others
	{
		"folke/trouble.nvim",
		cmd = { "TroubleToggle", "Trouble" },
		opts = { use_diagnostic_signs = true },
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
			{ "<leader>xL", "<cmd>TroubleToggle loclist<cr>",               desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>",              desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").previous({ skip_groups = true, jump = true })
					else
						vim.cmd.cprev()
					end
				end,
				desc = "Previous trouble/quickfix item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						vim.cmd.cnext()
					end
				end,
				desc = "Next trouble/quickfix item",
			},
		},
	},

	-- Go
	{
		"ray-x/go.nvim",
		config = function()
			require("go").setup()
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-lua/plenary.nvim",
			build = "make",
			config = function()
				require("telescope").load_extension("fzf")
				require("telescope").load_extension("ui-select")
			end,
		},
		keys = {
			{ "<leader>st",       "<cmd>Telescope live_grep<cr>",                 desc = "Live Grep" },
			{ "<leader>:",        "<cmd>Telescope command_history<cr>",           desc = "Command History" },
			{ "<leader>fb",       "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
			{ "<leader><leader>", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
			{ "<leader>ff",       "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
			{ "<C-f>",            "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
			{ "<C-p>",            "<cmd>Telescope git_files<cr>",                 desc = "Git Files" },
			{ "<leader>sa",       "<cmd>Telescope autocommands<cr>",              desc = "Auto Commands" },
			{ "<leader>sb",       "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
			{ "<leader>sc",       "<cmd>Telescope command_history<cr>",           desc = "Command History" },
			{ "<leader>sC",       "<cmd>Telescope commands<cr>",                  desc = "Commands" },
			{ "<leader>sd",       "<cmd>Telescope diagnostics bufnr=0<cr>",       desc = "Document diagnostics" },
			{ "<leader>sD",       "<cmd>Telescope diagnostics<cr>",               desc = "Workspace diagnostics" },
			{ "<leader>sh",       "<cmd>Telescope help_tags<cr>",                 desc = "Help Pages" },
			{ "<leader>sH",       "<cmd>Telescope highlights<cr>",                desc = "Search Highlight Groups" },
			{ "<leader>sk",       "<cmd>Telescope keymaps<cr>",                   desc = "Key Maps" },
			{ "<leader>sM",       "<cmd>Telescope man_pages<cr>",                 desc = "Man Pages" },
			{ "<leader>sm",       "<cmd>Telescope marks<cr>",                     desc = "Jump to Mark" },
			{ "<leader>so",       "<cmd>Telescope vim_options<cr>",               desc = "Options" },
			{ "<leader>sR",       "<cmd>Telescope resume<cr>",                    desc = "Resume" },
			{ "<leader>sw",       "<cmd>Telescope grep_string<cr>",               desc = "Grep String" },
		},
		opts = {
			defaults = {
				previewer = false,
				hidden = true,
				file_ignore_patterns = { "node_modules", "package-lock.json" },
				initial_mode = "insert",
				select_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					width = 0.5,
					height = 0.4,
					prompt_position = "top",
					preview_cutoff = 120,
				},
			},
			pickers = {
				find_files = {
					previewer = false,
				},
				git_files = {
					previewer = false,
				},
				buffers = {
					previewer = false,
				},
				live_grep = {
					only_sort_text = true,
					previewer = true,
					layout_config = {
						horizontal = {
							width = 0.9,
							height = 0.75,
							preview_width = 0.6,
						},
					},
				},
				grep_string = {
					only_sort_text = true,
					previewer = true,
					layout_config = {
						horizontal = {
							width = 0.9,
							height = 0.75,
							preview_width = 0.6,
						},
					},
				},
				lsp_references = {
					show_line = false,
					previewer = true,
					layout_config = {
						horizontal = {
							width = 0.9,
							height = 0.75,
							preview_width = 0.6,
						},
					},
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,    -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				},
				["ui-select"] = function()
					require("telescope.themes").get_dropdown({
						previewer = false,
						initial_mode = "normal",
						sorting_strategy = "ascending",
						layout_strategy = "horizontal",
						layout_config = {
							horizontal = {
								width = 0.5,
								height = 0.4,
								preview_width = 0.6,
							},
						},
					})
				end
			},
		}
	},

	-- autopairs
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
			})
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
			end
		end,
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
				context_commentstring = { enable = true, enable_autocmd = false },
				auto_install = true,
				ensure_installed = {
					"bash",
					"c",
					"javascript",
					"typescript",
					"yaml",
					"rust",
					"go",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>vv",
						node_incremental = "+",
						scope_incremental = false,
						node_decremental = "_",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,

						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["af"] = { query = "@function.outer", desc = "around a function" },
							["if"] = { query = "@function.inner", desc = "inner part of a function" },
							["ac"] = { query = "@class.outer", desc = "around a class" },
							["ic"] = { query = "@class.inner", desc = "inner part of a class" },
							["ai"] = { query = "@conditional.outer", desc = "around an if statement" },
							["ii"] = { query = "@conditional.inner", desc = "inner part of an if statement" },
							["al"] = { query = "@loop.outer", desc = "around a loop" },
							["il"] = { query = "@loop.inner", desc = "inner part of a loop" },
							["ap"] = { query = "@parameter.outer", desc = "around parameter" },
							["ip"] = { query = "@parameter.inner", desc = "inside a parameter" },
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@parameter.inner"] = "v", -- charwise
							["@function.outer"] = "v", -- charwise
							["@conditional.outer"] = "V", -- linewise
							["@loop.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
						include_surrounding_whitespace = false,
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_previous_start = {
							["[f"] = { query = "@function.outer", desc = "Previous function" },
							["[c"] = { query = "@class.outer", desc = "Previous class" },
							["[p"] = { query = "@parameter.inner", desc = "Previous parameter" },
						},
						goto_next_start = {
							["]f"] = { query = "@function.outer", desc = "Next function" },
							["]c"] = { query = "@class.outer", desc = "Next class" },
							["]p"] = { query = "@parameter.inner", desc = "Next parameter" },
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>a"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>A"] = "@parameter.inner",
						},
					},
				},
			})
		end,
	},

	-- comments
	{
		"numToStr/Comment.nvim",
		opts = {},
		config = function()
			require("Comment").setup()
		end,
	},

	-- Copilot
	{
		"zbirenbaum/copilot.lua",
		enabled = true,
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = false,
					auto_refresh = true,
					keymap = {
						jump_next = "<c-j>",
						jump_prev = "<c-k>",
						accept = "<c-a>",
						refresh = "r",
						open = "<M-CR>",
					},
					layout = {
						position = "bottom", -- | top | left | right
						ratio = 0.4,
					},
				},
				suggestion = {
					enabled = false,
					auto_trigger = true,
					debounce = 75,
					keymap = {
						accept = "<c-a>",
						accept_word = false,
						accept_line = false,
						next = "<c-j>",
						prev = "<c-k>",
						dismiss = "<C-e>",
					},
				},
			})
		end
	},
	-- copilot cmp
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end
	}
})

----------------
--- SETTINGS ---
----------------
local options = {
	incsearch = true,                     -- make search act like search in modern browsers
	backup = false,                       -- creates a backup file
	clipboard = "unnamedplus",            -- allows neovim to access the system clipboard
	cmdheight = 1,                        -- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 0,                     -- so that `` is visible in markdown files
	fileencoding = "utf-8",               -- the encoding written to a file
	hlsearch = true,                      -- highlight all matches on previous search pattern
	ignorecase = true,                    -- ignore case in search patterns
	mouse = "a",                          -- allow the mouse to be used in neovim
	pumheight = 10,                       -- pop up menu height
	showmode = false,                     -- we don't need to see things like -- INSERT -- anymore
	showtabline = 0,                      -- always show tabs
	smartcase = true,                     -- smart case
	smartindent = true,                   -- make indenting smarter again
	splitbelow = true,                    -- force all horizontal splits to go below current window
	splitright = true,                    -- force all vertical splits to go to the right of current window
	swapfile = false,                     -- creates a swapfile
	termguicolors = true,                 -- set term gui colors (most terminals support this)
	timeoutlen = 1000,                    -- time to wait for a mapped sequence to complete (in milliseconds)
	undofile = true,                      -- enable persistent undo
	updatetime = 100,                     -- faster completion (4000ms default)
	writebackup = false,                  -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true,                     -- convert tabs to spaces
	shiftwidth = 2,                       -- the number of spaces inserted for each indentation
	tabstop = 2,                          -- insert 2 spaces for a tab
	cursorline = true,                    -- highlight the current line
	number = true,                        -- set numbered lines
	breakindent = true,                   -- wrap lines with indent
	relativenumber = true,                -- set relative numbered lines
	numberwidth = 4,                      -- set number column width to 2 {default 4}
	signcolumn = "yes",                   -- always show the sign column, otherwise it would shift the text each time
	wrap = false,                         -- display lines as one long line
	scrolloff = 8,                        -- Makes sure there are always eight lines of context
	sidescrolloff = 8,                    -- Makes sure there are always eight lines of context
	laststatus = 3,                       -- Always display the status line
	showcmd = false,                      -- Don't show the command in the last line
	ruler = false,                        -- Don't show the ruler
	guifont = "monospace:h17",            -- the font used in graphical neovim applications
	title = true,                         -- set the title of window to the value of the titlestring
	-- modifiable = false,                   -- allow a buffer to be modified
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- Keymaps --
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Fast saving
vim.keymap.set("n", "<Leader>w", ":write!<CR>")
vim.keymap.set("n", "<Leader>q", ":q!<CR>", { silent = true })

-- Some useful quickfix shortcuts for quickfix
vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-m>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>a", "<cmd>cclose<CR>")

-- Exit on jj and jk
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Exit on jj and jk
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("i", "jk", "<ESC>")

-- Remove search highlight
vim.keymap.set("n", "<Leader>h", ":nohlsearch<CR>")

-- goodies
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- If I visually select words and paste from clipboard, don't replace my
-- clipboard with the selected word, instead keep my old word in the
-- clipboard
vim.keymap.set("x", "p", '"_dP')

-- Better split switching
vim.keymap.set("", "<C-j>", "<C-W>j")
vim.keymap.set("", "<C-k>", "<C-W>k")
vim.keymap.set("", "<C-h>", "<C-W>h")
vim.keymap.set("", "<C-l>", "<C-W>l")

-- Visually select lines, and move them up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>c", ":bd<cr>")

-- lazygit
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>")

-- autocommands
-- don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

--- Remove all trailing whitespace on save
local TrimWhiteSpaceGrp = vim.api.nvim_create_augroup("TrimWhiteSpaceGrp", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	command = [[:%s/\s\+$//e]],
	group = TrimWhiteSpaceGrp,
})

-- wrap words "softly" (no carriage return) in mail buffer
vim.api.nvim_create_autocmd("Filetype", {
	pattern = "mail",
	callback = function()
		vim.opt.textwidth = 0
		vim.opt.wrapmargin = 0
		vim.opt.wrap = true
		vim.opt.linebreak = true
		vim.opt.columns = 80
		vim.opt.colorcolumn = "80"
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- show cursor line only in active window
local cursorGrp = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	pattern = "*",
	command = "set cursorline",
	group = cursorGrp,
})
vim.api.nvim_create_autocmd(
	{ "InsertEnter", "WinLeave" },
	{ pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	-- { pattern = { "*.txt", "*.md", "*.tex" }, command = [[setlocal spell<cr> setlocal spelllang=en,de<cr>]] }
	{
		pattern = { "*.txt", "*.md", "*.tex" },
		callback = function()
			vim.opt.spell = true
			vim.opt.spelllang = "en,de"
		end,
	}
)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "<leader>v", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
	end,
})

-- open telescope when neovim starts only if no other plugin is opening
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("silent! lua require('telescope.builtin').find_files()")
	end,
})
