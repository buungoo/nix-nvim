return {
  "blink.pairs",
  enabled = true,
  category = "core",
  event = "BufReadPost",
  after = function()
    local function set_highlights()
      local palette = require("plugins.ui.themes.palette")
      vim.api.nvim_set_hl(0, "BlinkPairsOrange", { fg = palette.pairs_1 or "#ffa066" })
      vim.api.nvim_set_hl(0, "BlinkPairsPurple", { fg = palette.pairs_2 or "#957fb8" })
      vim.api.nvim_set_hl(0, "BlinkPairsBlue", { fg = palette.pairs_3 or "#6a9589" })
      vim.api.nvim_set_hl(0, "BlinkPairsUnmatched", { fg = palette.pairs_unmatched or "#c34043" })
      vim.api.nvim_set_hl(0, "BlinkPairsMatchParen", { link = "MatchParen" })
    end

    require("blink.pairs").setup({
      mappings = {
        enabled = true,
        cmdline = true,
      },
      highlights = {
        enabled = true,
        cmdline = true,
        groups = { "BlinkPairsOrange", "BlinkPairsPurple", "BlinkPairsBlue" },
        unmatched_group = "BlinkPairsUnmatched",
        matchparen = {
          enabled = true,
          cmdline = false,
          include_surrounding = true,
          group = "BlinkPairsMatchParen",
          priority = 250,
        },
      },
      debug = false,
    })

    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("blink_pairs_highlights", { clear = true }),
      callback = set_highlights,
    })
  end,
}
