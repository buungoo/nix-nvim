return {
  "blink.pairs",
  category = "core",
  event = "InsertEnter",
  after = function()
    require('blink.pairs').setup({})
  end,
}
