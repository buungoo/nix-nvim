local M = {}

function M.enable(name, available)
   local config = vim.lsp.config[name]
   if type(config.cmd) == 'table' and vim.fn.executable(config.cmd[1]) ~= 1 then
      return
   end

   -- Function-based commands can depend on the resolved project root.
   if available then
      local root_dir = config.root_dir
      vim.lsp.config(name, {
         root_dir = function(bufnr, on_dir)
            root_dir(bufnr, function(root)
               if available(root) then
                  on_dir(root)
               end
            end)
         end,
      })
   end

   vim.lsp.enable(name)
end

return M
