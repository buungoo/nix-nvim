return {
  "mini.clue",
  category = "core",
  lazy = false,
  after = function()
    local miniclue = require('mini.clue')
    miniclue.setup({
      triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
      },
      clues = {
        miniclue.gen_clues.g(),
      },
      window = {
        delay = 300,
        config = { border = 'rounded' },
      },
    })
  end,
}
