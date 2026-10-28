return {
  "rust_analyzer",
  category = "core",
  ft = "rust",
  after = function()
    vim.lsp.config('rust_analyzer', {})
    require('config.lsp').enable('rust_analyzer')
  end,
}
