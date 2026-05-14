return {
  "ts_ls",
  category = "core",
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  before = function()
    vim.cmd.packadd("conform.nvim")
  end,
  after = function()
    vim.lsp.config('ts_ls', {})
    vim.lsp.enable('ts_ls')

    -- ts_ls doesn't support external formatters, so we use conform.nvim instead.
    -- Multiple formatters can be listed per filetype — conform uses the first one
    -- found on PATH, so whichever formatter your dev shell provides wins.
    require("conform").setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
    })

    -- Override <leader>ff to use conform for these filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      callback = function(args)
        vim.keymap.set('n', '<leader>ff', function()
          require("conform").format({ async = true, lsp_fallback = true })
        end, { buffer = args.buf, desc = 'LSP: Format Buffer' })
      end,
    })
  end,
}
