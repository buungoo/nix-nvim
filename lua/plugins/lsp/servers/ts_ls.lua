return {
  "ts_ls",
  category = "core",
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  after = function()
    vim.lsp.config('ts_ls', {})
    vim.lsp.enable('ts_ls')

    -- ts_ls doesn't support external formatters, so we use conform.nvim instead.
    -- Multiple formatters can be listed per filetype — conform uses the first one
    -- found on PATH, so whichever formatter your dev shell provides wins.
    require("config.format").register_conform(
      { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      { "prettier" }
    )
  end,
}
