return {
  "roslyn",
  category = "core",
  ft = "cs",
  after = function()
    vim.lsp.config('roslyn', {})
    vim.lsp.enable('roslyn')
  end,
}
