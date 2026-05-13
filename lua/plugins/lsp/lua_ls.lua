return {
  "lua_ls",
  category = "core",
  ft = "lua",
  after = function()
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixInfo", "vim" },
            disable = { 'missing-fields' },
          },
        },
      },
    })
    vim.lsp.enable('lua_ls')
  end,
}
