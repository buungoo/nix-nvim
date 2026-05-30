return {
  "blink.pairs",
  enabled = true,
  category = "core",
  event = "InsertEnter",
  after = function()
    require('blink.pairs').setup({})
  end,
}
