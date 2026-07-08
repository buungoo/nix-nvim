vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

vim.opt.scrolloff = 999
-- vim.opt.scrolloffpad = 999

vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.cursorline = true

vim.o.mouse = 'a'

vim.opt.cpoptions:append('I')
vim.o.expandtab = true
vim.o.tabstop = 3
vim.o.softtabstop = 3
vim.o.shiftwidth = 3

vim.o.breakindent = true
vim.o.wrap = false

vim.o.ignorecase = true
vim.o.smartcase = true

vim.wo.signcolumn = 'yes'

vim.o.updatetime = 250
vim.o.timeout = false
vim.o.completeopt = 'menu,preview,noselect'
vim.o.termguicolors = true
vim.o.virtualedit = 'block'

-- Only works in terminal emulators (TERM=linux cant interpret it)
if vim.env.TERM ~= 'linux' then
   vim.g.clipboard = 'osc52'
   vim.o.clipboard = 'unnamedplus'
end

-- Disable built-in plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tutor = 1
