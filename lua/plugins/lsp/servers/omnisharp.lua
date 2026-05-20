return {
  "omnisharp",
  category = "core",
  ft = "cs",
  after = function()
    if vim.fn.executable('OmniSharp') == 1 then
      vim.lsp.config('omnisharp', {})
      vim.lsp.enable('omnisharp')
    end
  end,
}
