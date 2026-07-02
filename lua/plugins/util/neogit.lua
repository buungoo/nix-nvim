return {
   'neogit',
   category = 'core',
   cmd = 'Neogit',

   keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
   },
   before = function()
      require('lze').trigger_load('fzf-lua')
   end,
   after = function()
      require('neogit').setup({
         integrations = {
            fzf_lua = true,
         },
      })
   end,
}
