return {
  "fidget.nvim",
  category = "core",
  event = "DeferredUIEnter",
  after = function()
    require('fidget').setup({})
  end,
}
