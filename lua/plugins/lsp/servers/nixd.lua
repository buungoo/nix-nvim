return {
  "nixd",
  category = "core",
  ft = "nix",
  after = function()
    vim.lsp.config('nixd', {
      settings = {
        nixd = {
          formatting = { command = { "alejandra" } },
        },
      },
    })
    require('config.lsp').enable('nixd')
  end,
}
