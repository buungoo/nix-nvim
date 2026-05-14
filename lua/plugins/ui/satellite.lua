return {
  "satellite.nvim",
  category = "core",
  event = "BufReadPost",
  after = function()
    require("satellite").setup()
  end,
}
