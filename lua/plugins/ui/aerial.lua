return {
   'aerial.nvim',
   category = 'core',
   event = { 'BufReadPost', 'BufNewFile' },
   before = function()
      vim.cmd.packadd('nvim-treesitter')
   end,
   after = function()
      local aerial = require('aerial')

      local function position(conf)
         local statusline = vim.o.laststatus > 0 and 1 or 0
         conf.relative = 'editor'
         conf.anchor = 'SE'
         conf.row = math.max(3, vim.o.lines - vim.o.cmdheight - statusline - 1)
         conf.col = vim.o.columns - 1
         conf.width = math.max(1, math.min(35, vim.o.columns - 4))
         conf.height = math.max(1, math.min(12, conf.row - 2))
         conf.zindex = 40 -- Keep completion, pickers, and other temporary floats above the outline.
         return conf
      end

      aerial.setup({
         backends = { 'treesitter', 'lsp' },
         attach_mode = 'global',
         open_automatic = true,
         close_on_select = false,
         show_guides = true,
         highlight_on_hover = true,
         autojump = true,
         post_jump_cmd = 'normal! zz',
         filter_kind = {
            'Class',
            'Constructor',
            'Enum',
            'Function',
            'Interface',
            'Module',
            'Method',
            'Struct',
            'Object',
         },
         layout = {
            default_direction = 'float',
            width = 35,
            min_width = 1,
            max_width = 35,
            resize_to_content = false,
         },
         float = {
            relative = 'editor',
            border = 'rounded',
            height = 12,
            min_height = 1,
            max_height = 12,
            override = position,
         },
      })

      local origin
      vim.keymap.set('n', '<leader>a', function()
         if vim.bo.filetype == 'aerial' then
            local source = origin and origin.win or vim.w.source_win
            if source and vim.api.nvim_win_is_valid(source) then
               vim.api.nvim_set_current_win(source)
               if origin and vim.api.nvim_get_current_buf() == origin.buf then
                  vim.fn.winrestview(origin.view)
               end
            end
            origin = nil
         else
            origin = {
               win = vim.api.nvim_get_current_win(),
               buf = vim.api.nvim_get_current_buf(),
               view = vim.fn.winsaveview(),
            }
            aerial.focus()
            if vim.api.nvim_get_current_win() == origin.win then
               origin = nil
            end
         end
      end, { desc = 'Preview symbols / return to original position' })

      -- Aerial repositions on symbol updates, but not on editor resizes.
      vim.api.nvim_create_autocmd('VimResized', {
         group = vim.api.nvim_create_augroup('aerial-minimap', { clear = true }),
         callback = function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
               if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'aerial' then
                  local conf = vim.api.nvim_win_get_config(win)
                  if conf.relative ~= '' then
                     vim.api.nvim_win_set_config(win, position(conf))
                  end
               end
            end
         end,
      })
   end,
}
