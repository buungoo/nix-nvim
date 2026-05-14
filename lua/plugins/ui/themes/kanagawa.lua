return {
  "kanagawa.nvim",
  category = "core",
  event = "VimEnter",
  priority = 1000,
  after = function()
    require('kanagawa').setup {
      commentStyle = { italic = true },
      keywordStyle = { italic = false },
      dimInactive = true,
      overrides = function(colors)
        local t = colors.theme
        local p = colors.palette
        return {
          Search = { bg = p.roninYellow, fg = p.sumiInk0, bold = true },
          IncSearch = { bg = p.roninYellow, fg = p.sumiInk0, bold = true },
          CurSearch = { bg = p.roninYellow, fg = p.sumiInk0, bold = true },

          Pmenu = { fg = t.ui.shade0, bg = t.ui.bg_p1 },
          PmenuSel = { fg = "NONE", bg = t.ui.bg_p2 },
          PmenuSbar = { bg = t.ui.bg_m1 },
          PmenuThumb = { bg = p.carpYellow },

          NormalFloat = { bg = "none" },
          FloatBorder = { fg = t.ui.nontext, bg = "none" },
          FloatTitle = { bg = "none" },

          BlinkCmpMenu = { bg = t.ui.bg_p1 },
          BlinkCmpMenuBorder = { fg = t.ui.bg_p2, bg = t.ui.bg_p1 },
          BlinkCmpDocBorder = { fg = t.ui.bg_p2, bg = "none" },
          BlinkCmpSignatureHelpBorder = { fg = t.ui.bg_p2, bg = "none" },

          CursorLineNr = { fg = p.sakuraPink, bg = "NONE" },
        }
      end,
    }
    vim.cmd.colorscheme('kanagawa-wave')

    -- Populate the semantic color palette for other plugins
    local p = require('kanagawa.colors').setup({ theme = 'wave' }).palette
    local c = require('plugins.ui.themes.palette')
    c.search = p.roninYellow
    c.search_bg = p.sumiInk0
    c.indent = p.sumiInk5
    c.chunk = p.roninYellow
    c.chunk_error = p.autumnRed
    c.picker_match = p.roninYellow
    c.picker_border = p.roninYellow
    c.picker_preview_border = p.sumiInk6
    c.picker_header = p.dragonPink
    c.picker_info = p.waveAqua2
    c.line_nr = p.roninYellow
    c.line_nr_bg = p.sumiInk6
    c.mode_insert = p.dragonPink
    c.mode_visual = p.waveAqua2
    c.mode_vline = p.waveAqua1
    c.mode_replace = p.autumnRed
  end,
}
