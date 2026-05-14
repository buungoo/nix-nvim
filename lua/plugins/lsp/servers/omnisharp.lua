return {
  "omnisharp",
  category = "core",
  ft = "cs",
  after = function()
    vim.lsp.config('omnisharp', {})
    vim.lsp.enable('omnisharp')
  end,
}
