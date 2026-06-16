return {
   "lua_ls",
   category = "core",
   ft = "lua",
   before = function()
      vim.cmd.packadd("lazydev.nvim")
   end,
   after = function()
      require("lazydev").setup({
         library = {
            { words = { "nixInfo%.lze" }, path = nixInfo("lze", "plugins", "start", "lze") .. "/lua" },
            { words = { "nixInfo%.lze" }, path = nixInfo("lzextras", "plugins", "start", "lzextras") .. "/lua" },
         },
      })

      vim.lsp.config("lua_ls", {
         settings = {
            Lua = {
               signatureHelp = { enabled = true },
            },
         },
      })
      vim.lsp.enable("lua_ls")

      require("config.format").register_conform("lua", { "stylua" })
   end,
}
