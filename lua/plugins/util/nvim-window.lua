return {
  "nvim-window",
  category = "core",
  keys = {
    { "<leader>w", function() require('nvim-window').pick() end, mode = "n", desc = "Jump to window" },
  },
  after = function()
    require('nvim-window').setup {
      -- NOTE: The order matters. Key at index 0 will be window 0, etc.
      chars = { 'j', 'f', 'k', 'd', 'l', 's', 'ö', 'a', },
      normal_hl = 'Normal',
      hint_hl = 'Bold',
      border = 'rounded',
      render = 'float',
      close_window = function(win, conf)
        -- Keep ui2's internal windows intact, even when they are hidden.
        return conf.relative ~= 'laststatus'
          and vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'aerial'
      end,
    }
  end,
}
