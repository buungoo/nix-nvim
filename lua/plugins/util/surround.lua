return {
  "nvim-surround",
  category = "core",
  event = "BufReadPost",
  after = function()
    require('nvim-surround').setup()

    local ok, miniclue = pcall(require, 'mini.clue')
    if ok then
      vim.list_extend(miniclue.config.triggers, {
        { mode = 'n', keys = 'ys' },
        { mode = 'n', keys = 'ds' },
        { mode = 'n', keys = 'cs' },
      })
      vim.list_extend(miniclue.config.clues, {
        { mode = 'n', keys = 'ys', desc = 'Add surround' },
        { mode = 'n', keys = 'ds', desc = 'Delete surround' },
        { mode = 'n', keys = 'cs', desc = 'Change surround' },
      })
    end
  end,
}
