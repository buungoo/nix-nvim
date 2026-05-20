return {
  "roslyn",
  category = "core",
  ft = "cs",
  after = function()
    if vim.fn.executable('Microsoft.CodeAnalysis.LanguageServer') == 1 then
      vim.lsp.config('roslyn', {})
      vim.lsp.enable('roslyn')
    end
  end,
}
