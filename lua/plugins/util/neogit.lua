return {
   'neogit',
   category = 'core',
   cmd = 'Neogit',

   keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
   },
   before = function()
      require('lze').trigger_load('mini.pick')
   end,
   after = function()
      require('neogit').setup({
         integrations = {
            mini_pick = true,
            fzf_lua = false,
         },
      })
   end,
}
