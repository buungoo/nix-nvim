return {
  "markdown-preview.nvim",
  category = "core",
  ft = "markdown",
  keys = {
    { "<leader>md", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
  },
  after = function()
    local ok, miniclue = pcall(require, 'mini.clue')
    if ok then
      vim.list_extend(miniclue.config.clues, {
        { mode = 'n', keys = '<Leader>m', desc = '+markdown' },
      })
    end
  end,
}
