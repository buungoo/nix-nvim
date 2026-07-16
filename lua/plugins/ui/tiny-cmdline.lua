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
   end,
}
