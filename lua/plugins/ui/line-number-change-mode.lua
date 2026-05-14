return {
  "line-number-change-mode-nvim",
  category = "core",
  lazy = false,
  before = function()
    vim.cmd.packadd("kanagawa.nvim")
  end,
  after = function()
    local c = require('plugins.ui.themes.palette')

    require("line-number-change-mode").setup({
      mode = {
        n = {
          bg = c.line_nr_bg,
          fg = c.line_nr,
          bold = true,
        },
        i = {
          bg = c.mode_insert,
          fg = c.line_nr,
          bold = true,
        },
        v = {
          bg = c.mode_visual,
          fg = c.line_nr,
          bold = true,
        },
        V = {
          bg = c.mode_vline,
          fg = c.line_nr,
          bold = true,
        },
        R = {
          bg = c.mode_replace,
          fg = c.line_nr,
          bold = true,
        },
      },
    })
  end,
}
