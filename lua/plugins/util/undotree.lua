-- Built-in plugin since Neovim 0.12, enabled via packadd
return {
   "nvim.undotree",
   keys = {
      { "<leader>u", function() vim.cmd.Undotree() end, desc = "Toggle Undotree" },
   },
   load = function(name)
      vim.cmd.packadd(name)
   end,
   after = function()
      vim.o.undofile = true
      vim.api.nvim_create_autocmd("FileType", {
         pattern = "nvim-undotree",
         callback = function(ev)
            vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
         end,
      })
   end,
}
