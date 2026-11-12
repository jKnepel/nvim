vim.opt.guicursor = ""

vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.whichwrap:append("<,>,h,l")

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
-- expand("~") instead of $HOME, which is usually unset on Windows
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
-- 'background' is left unset: nvim detects light/dark from the terminal (OSC 11)

vim.opt.scrolloff = 8
-- two columns, so a diagnostic (E/W) and a git sign (M/A/S) on the same line both show
vim.opt.signcolumn = "yes:2"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- one status line at the bottom instead of one per window, so horizontal splits are
-- separated by a line (WinSeparator) like vertical ones
vim.opt.laststatus = 3

-- lets auto-session restore buffer-local options (e.g. filetype settings)
vim.opt.sessionoptions:append("localoptions")
-- save terminal buffers; restoring one re-runs its command, so use `nvim --clean` if a restored one crashes
vim.opt.sessionoptions:append("terminal")

vim.opt.exrc = true
