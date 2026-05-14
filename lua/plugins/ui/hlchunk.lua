return {
  "hlchunk.nvim",
  category = "core",
  event = "DeferredUIEnter",
  after = function()
    local c = require('plugins.ui.themes.palette')

    require('hlchunk').setup({
      chunk = {
        enable = true,
        use_treesitter = true,
        chars = {
          right_arrow = '─',
        },
        delay = 0,
        duration = 100,
        style = {
          c.chunk,
          c.chunk_error,
        },
      },
      indent = {
        enable = true,
        chars = {
          '│',
        },
        style = {
          c.indent,
        },
      },
    })
  end,
}
