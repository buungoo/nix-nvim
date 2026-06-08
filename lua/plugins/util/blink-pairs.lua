return {
  "blink.pairs",
  enabled = false,
  category = "core",
  event = "InsertEnter",
  after = function()
    require('blink.pairs').setup({})
  end,
}
