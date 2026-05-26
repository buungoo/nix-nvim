return {
  "mini.clue",
  category = "core",
  keys = {
    { "<leader>", mode = { "n", "x" } },
  },
  after = function()
    local miniclue = require('mini.clue')
    miniclue.setup({
      triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
      },
      clues = {},
      window = {
        delay = 300,
      },
    })
  end,
}
