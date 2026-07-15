vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll Down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll Up' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next Search Result' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous Search Result' })

vim.keymap.set('n', '<leader><leader>[', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader><leader>]', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader><leader>l', '<cmd>b#<CR>', { desc = 'Last buffer' })
vim.keymap.set('n', '<leader><leader>d', '<cmd>bdelete<CR>', { desc = 'delete buffer' })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set({ 'n', 'v', 'x' }, '<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set(
   'i',
   '<C-p>',
   '<C-r><C-p>+',
   { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' }
)
vim.keymap.set(
   'x',
   '<leader>P',
   '"_dP',
   { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' }
)

local function yank_current_file_path(label, path_fn)
   local path = vim.api.nvim_buf_get_name(0)

   if path == '' then
      vim.notify('Current buffer has no file path', vim.log.levels.WARN)
      return
   end

   local result = path_fn(vim.fs.normalize(path))

   if not result or result == '' then
      vim.notify('Could not get ' .. label .. ' path', vim.log.levels.WARN)
      return
   end

   vim.fn.setreg('"', result)
   vim.fn.setreg('+', result)
   vim.notify('Yanked ' .. label .. ' path: ' .. result)
end

vim.keymap.set('n', '<leader>yr', function()
   yank_current_file_path('repo relative', function(path)
      local git_dir = vim.fs.find('.git', { path = vim.fs.dirname(path), upward = true })[1]

      if not git_dir then
         return nil
      end

      local repo_root = vim.fs.normalize(vim.fs.dirname(git_dir))
      local root_with_separator = repo_root .. '/'

      if path:sub(1, #root_with_separator) ~= root_with_separator then
         return nil
      end

      return path:sub(#root_with_separator + 1)
   end)
end, { desc = 'Yank repo relative file path' })

vim.keymap.set('n', '<leader>yh', function()
   yank_current_file_path('home relative', function(path)
      return vim.fn.fnamemodify(path, ':~')
   end)
end, { desc = 'Yank home relative file path' })

vim.keymap.set('n', '<leader>yw', function()
   yank_current_file_path('working directory relative', function(path)
      return vim.fn.fnamemodify(path, ':.')
   end)
end, { desc = 'Yank working directory relative file path' })

vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])
vim.cmd([[command! Qa qa]])
vim.cmd([[command! QA qa]])
