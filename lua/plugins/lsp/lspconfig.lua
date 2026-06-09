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
        map('gC', function() require('fzf-lua').lsp_incoming_calls() end, 'Incoming Calls')
        map('gI', function() require('fzf-lua').lsp_implementations() end, 'Go to Implementation')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>ff', function() require('config.format').format() end, 'Format Buffer')

        local ok, miniclue = pcall(require, 'mini.clue')
        if ok then
          vim.list_extend(miniclue.config.clues, {
            { mode = 'n', keys = '<Leader>r', desc = '+refactor' },
            { mode = 'n', keys = '<Leader>c', desc = '+code' },
            { mode = 'n', keys = '<Leader>f', desc = '+format' },
          })
        end
      end,
    })
  end,
}
