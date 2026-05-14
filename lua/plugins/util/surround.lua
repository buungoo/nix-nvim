return {
  "nvim-surround",
  category = "core",
  event = "BufReadPost",
  after = function()
    require('nvim-surround').setup()
  end,
}
