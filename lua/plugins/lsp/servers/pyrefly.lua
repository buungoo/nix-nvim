return {
  "pyrefly",
  category = "core",
  ft = "python",
  before = function()
    vim.cmd.packadd("conform.nvim")
  end,
  after = function()
    vim.lsp.config('pyrefly', {
      cmd = { "pyrefly", "lsp" },
    })
    vim.lsp.enable('pyrefly')

    -- Pyrefly doesn't support formatting, so we use conform.nvim with ruff instead.
    require("conform").setup({
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    })

    -- Override <leader>ff to use conform for these filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function(args)
        vim.keymap.set('n', '<leader>ff', function()
          require("conform").format({ async = true, lsp_fallback = true })
        end, { buffer = args.buf, desc = 'LSP: Format Buffer' })
      end,
    })
  end,
}
