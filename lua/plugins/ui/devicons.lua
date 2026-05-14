return {
  "nvim-web-devicons",
  category = "core",
  lazy = false,
  after = function()
    require('nvim-web-devicons').setup()
  end,
}
