return {
  "nvim-lspconfig",
  category = "core",
  lazy = false,
  after = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local buf = args.buf
        local function map(key, fn, desc)
          vim.keymap.set('n', key, fn, { buffer = buf, desc = 'LSP: ' .. desc })
        end

        map('gd', function() require('fzf-lua').lsp_definitions() end, 'Go to Definition')
        map('gr', function() require('fzf-lua').lsp_references() end, 'References')
        map('gI', function() require('fzf-lua').lsp_implementations() end, 'Go to Implementation')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>ff', function() require('config.format').format() end, 'Format Buffer')
      end,
    })
  end,
}
