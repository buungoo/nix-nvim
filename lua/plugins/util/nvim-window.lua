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
      border = 'single',
      render = 'float',
    }
  end,
}
