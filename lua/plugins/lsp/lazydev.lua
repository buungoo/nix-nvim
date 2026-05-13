return {
  "lazydev.nvim",
  category = "core",
  ft = "lua",
  after = function()
    require('lazydev').setup({
      library = {
        { words = { "nixInfo%.lze" }, path = nixInfo("lze", "plugins", "start", "lze") .. '/lua' },
        { words = { "nixInfo%.lze" }, path = nixInfo("lzextras", "plugins", "start", "lzextras") .. '/lua' },
      },
    })
  end,
}
