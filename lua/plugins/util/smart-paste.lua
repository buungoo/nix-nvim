return {
   'smart-paste',
   category = 'core',
   keys = {
      { 'p', mode = { 'n', 'x' }, desc = 'Smart paste after cursor line' },
      { 'P', mode = { 'n', 'x' }, desc = 'Smart paste before cursor line' },
      { 'gp', mode = 'n', desc = 'Smart paste after cursor line and follow' },
      { 'gP', mode = 'n', desc = 'Smart paste before cursor line and follow' },
      { ']p', mode = 'n', desc = 'Smart paste line below' },
      { '[p', mode = 'n', desc = 'Smart paste line above' },
   },
   after = function()
      require('smart-paste').setup()
   end,
}
