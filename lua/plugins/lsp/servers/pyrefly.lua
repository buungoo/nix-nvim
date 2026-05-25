return {
  "pyrefly",
  category = "core",
  ft = "python",
  after = function()
    vim.lsp.config('pyrefly', {
      cmd = { "pyrefly", "lsp" },
    })
    vim.lsp.enable('pyrefly')
  end,
}
