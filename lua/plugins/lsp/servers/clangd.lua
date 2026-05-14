return {
  "clangd",
  category = "core",
  ft = { "c", "cpp", "objc", "objcpp" },
  after = function()
    vim.lsp.config('clangd', {})
    vim.lsp.enable('clangd')
  end,
}
