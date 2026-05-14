return {
  "fzf-lua",
  category = "core",
  event = "DeferredUIEnter",
  keys = {
    { "<leader>sf", function() require("fzf-lua").files() end, desc = "Find Files" },
    { "<leader>sg", function() require("fzf-lua").live_grep() end, desc = "Grep Files" },
    { "<leader>sb", function() require("fzf-lua").buffers() end, desc = "Find Buffers" },
  },
  after = function()
    local c = require('plugins.ui.themes.palette')

    vim.api.nvim_set_hl(0, "FzfLuaBorder", { fg = c.picker_border })
    vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { fg = c.picker_preview_border })
    vim.api.nvim_set_hl(0, "FzfLuaTitle", { fg = c.picker_header, bold = true })
    vim.api.nvim_set_hl(0, "FzfLuaHeaderText", { fg = c.picker_header })
    vim.api.nvim_set_hl(0, "FzfLuaFzfMatch", { fg = c.picker_match, bold = true })
    vim.api.nvim_set_hl(0, "FzfLuaFzfInfo", { fg = c.picker_info })
    vim.api.nvim_set_hl(0, "FzfLuaFzfPointer", { fg = c.picker_match })
    vim.api.nvim_set_hl(0, "FzfLuaFzfMarker", { fg = c.picker_match })

    require("fzf-lua").setup({
      fzf_bin = "sk",
      files = {
        hidden = true,
      },
      winopts = {
        fullscreen = true,
        border = "rounded",
        preview = {
          layout = "vertical",
          vertical = "up:60%",
          border = "rounded",
          scrollbar = false,
        },
      },
    })
  end,
}
