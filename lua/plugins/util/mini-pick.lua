return {
  'mini.pick',
  category = 'core',
  event = 'DeferredUIEnter',
  on_require = 'mini.pick',
  keys = {
    { '<leader>sf', function() require('config.picker').files() end, desc = 'Find Files' },
    { '<leader>sF', function() require('config.picker').files(vim.fn.expand('%:p:h')) end, desc = 'Find Files (current dir)' },
     { '<leader>sg', function() require('config.picker').grep() end, desc = 'Grep Files' },
     { '<leader>sG', function() require('config.picker').grep_word() end, desc = 'Grep Word Under Cursor' },
    { '<leader>sb', function() require('mini.pick').builtin.buffers() end, desc = 'Find Buffers' },
    { '<leader>sd', function() require('config.picker').directories() end, desc = 'Find Directory' },
  },
  after = function() require('config.picker').setup() end,
}
