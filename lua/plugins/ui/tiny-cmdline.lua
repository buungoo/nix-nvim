return {
  "tiny-cmdline-nvim",
  category = "core",
  lazy = false,
  before = function()
    vim.o.cmdheight = 0
    require('vim._core.ui2').enable({})
  end,
  after = function()
    require("tiny-cmdline").setup({
      on_reposition = require("tiny-cmdline").adapters.blink,
      native_types = {},
    })
  end,
}
