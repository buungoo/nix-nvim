return {
  "roslyn_ls",
  category = "core",
  ft = "cs",
  after = function()
    if vim.fn.executable('Microsoft.CodeAnalysis.LanguageServer') == 1 then
      vim.lsp.config('roslyn_ls', {})
      vim.lsp.enable('roslyn_ls')
    end
  end,
}
