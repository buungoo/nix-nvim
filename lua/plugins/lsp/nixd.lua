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
    vim.lsp.enable('nixd')
  end,
}
