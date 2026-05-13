vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nix", "lua", "java" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.txt",
  callback = function()
    if vim.bo.buftype == "help" then
      vim.cmd("only")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
    copy_to_unnamedplus(vim.v.event.regcontents)
    local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
    copy_to_unnamed(vim.v.event.regcontents)
  end,
})
