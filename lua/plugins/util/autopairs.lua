return {
  "nvim-autopairs",
  category = "core",
  event = "InsertEnter",
  after = function()
    require('nvim-autopairs').setup({
      check_ts = true,
    })
  end,
}
