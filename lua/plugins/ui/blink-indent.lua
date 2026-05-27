return {
  "blink.indent",
  enabled = false;
  category = "core",
  event = "BufReadPost",
  after = function()
    local c = require('plugins.ui.themes.palette')

    require('blink.indent').setup({
      static = {
        char = '│',
        highlights = { 'BlinkIndent' },
      },
      scope = {
        char = '│',
        chars = {
          top = '╭',
          right_arrow = '─',
          bottom = '╰',
          bottom_right_arrow = '─',
        },
        highlights = { 'BlinkIndentScope' },
      },
    })

    vim.api.nvim_set_hl(0, 'BlinkIndent', { fg = c.indent })
    vim.api.nvim_set_hl(0, 'BlinkIndentScope', { fg = c.chunk })
  end,
}
