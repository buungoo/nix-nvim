return {
   'tiny-cmdline-nvim',
   category = 'core',
   event = 'DeferredUIEnter',
   before = function()
      vim.o.cmdheight = 0
      require('vim._core.ui2').enable({})
   end,
   after = function()
      require('tiny-cmdline').setup({
         position = {
            x = '50%', -- horizontal: "0%" = left, "50%" = center, "100%" = right
            y = '40%', -- vertical:   "0%" = top,  "50%" = center, "100%" = bottom
         },
         on_reposition = require('tiny-cmdline').adapters.blink,
          native_types = {},
       })

       -- Avoid cursor drift from ui2's per-key cmdheight changes.
       local saved_scrolloff
       local group = vim.api.nvim_create_augroup('TinyCmdlineScrolloff', { clear = true })
       vim.api.nvim_create_autocmd('CmdlineEnter', {
          group = group,
          pattern = ':',
          callback = function()
             if saved_scrolloff then return end
             local win = vim.api.nvim_get_current_win()
             saved_scrolloff = {
                win = win,
                level = vim.v.event.cmdlevel,
                value = vim.api.nvim_get_option_value('scrolloff', { win = win, scope = 'local' }),
             }
             vim.wo[win].scrolloff = 0
          end,
       })
       vim.api.nvim_create_autocmd('CmdlineLeave', {
          group = group,
          pattern = ':',
          callback = function()
             local saved = saved_scrolloff
             if not saved or saved.level ~= vim.v.event.cmdlevel then return end
             saved_scrolloff = nil
             if vim.api.nvim_win_is_valid(saved.win) then vim.wo[saved.win].scrolloff = saved.value end
          end,
       })
    end,
}
