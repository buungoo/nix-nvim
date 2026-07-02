return {
  "roslyn.nvim",
  category = "core",
  ft = "cs",
  after = function()
    require("roslyn").setup({})
  end,
}
