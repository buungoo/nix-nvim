return {
  "nvim-window",
  category = "core",
  keys = {
    { "<leader>w", function() require('nvim-window').pick() end, mode = "n", desc = "Jump to window" },
  },
  after = function()
    require('nvim-window').setup {
      chars = { 'a', 's', 'd', 'f', 'j', 'k', 'l', 'h', 'g' },
      normal_hl = 'Normal',
      hint_hl = 'Bold',
      border = 'single',
      render = 'float',
    }
  end,
}
