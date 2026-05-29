return {
  "pyrefly",
  category = "core",
  ft = "python",
  after = function()
    vim.lsp.config('pyrefly', {
      cmd = { "pyrefly", "lsp" },
    })
    vim.lsp.enable('pyrefly')

    -- Pyrefly doesn't support formatting, so we use conform.nvim with ruff instead.
    require("config.format").register_conform("python", { "ruff_format" })
  end,
}
