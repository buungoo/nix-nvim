return {
  "clangd",
  category = "core",
  ft = { "c", "cpp", "objc", "objcpp" },
  after = function()
    vim.lsp.config('clangd', {})
    require('config.lsp').enable('clangd')
  end,
}
