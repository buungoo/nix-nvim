return {
   'roslyn.nvim',
   category = 'core',
   ft = 'cs',
   after = function()
      -- Generic default. When a repo has several solutions referencing the same
      -- .csproj, roslyn.nvim can't decide and returns a nil root_dir (buffer then
      -- lands in the /tmp "canonical misc" project).
      --
      -- A project can force a specific solution by setting (e.g. in a project
      -- .nvim.lua) `vim.g.roslyn_preferred_solution = "Foo.sln"` (basename or full
      -- path). This is read live at resolution time, so it is immune to load
      -- ordering. Otherwise we fall back to the solution closest to the file so
      -- that at least something loads.
      require('roslyn').setup({
         choose_target = function(targets)
            local pref = vim.g.roslyn_preferred_solution
            if pref then
               for _, t in ipairs(targets) do
                  if vim.fs.basename(t) == pref or vim.fs.normalize(t) == vim.fs.normalize(pref) then
                     return t
                  end
               end
            end
            local buf = vim.api.nvim_buf_get_name(0)
            local containing = vim.tbl_filter(function(t)
               return buf:find(vim.fs.dirname(t), 1, true) == 1
            end, targets)
            local pool = #containing > 0 and containing or targets
            table.sort(pool, function(a, b)
               return #vim.fs.dirname(a) > #vim.fs.dirname(b)
            end)
            return pool[1]
         end,
      })
   end,
}
