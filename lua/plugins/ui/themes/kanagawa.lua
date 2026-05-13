return {
  "kanagawa.nvim",
  category = "core",
  event = "VimEnter",
  priority = 1000,
  after = function()
    require('kanagawa').setup {
      commentStyle = { italic = true },
      keywordStyle = { italic = false },
      overrides = function()
        local c = require('config.colors')
        return {
          Search = { bg = c.search, fg = c.search_bg, bold = true },
          IncSearch = { bg = c.search, fg = c.search_bg, bold = true },
          CurSearch = { bg = c.search, fg = c.search_bg, bold = true },
        }
      end,
    }
    vim.cmd.colorscheme('kanagawa-wave')
  end,
}
