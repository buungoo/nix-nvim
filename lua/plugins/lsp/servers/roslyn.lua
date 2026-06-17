return {
  "roslyn_ls",
  category = "core",
  ft = "cs",
  after = function()
    if vim.fn.executable('Microsoft.CodeAnalysis.LanguageServer') == 1 then
      vim.lsp.config('roslyn_ls', {
        on_init = function(client)
          local root = client.config.root_dir
          -- find the nearest .csproj walking up from the buffer
          local csproj = vim.fs.find(function(n) return n:match('%.csproj$') end,
            { upward = true, path = vim.api.nvim_buf_get_name(0) })[1]
          local proj = csproj and vim.fn.fnamemodify(csproj, ':t')

          -- pick the .sln that references our .csproj, or fall back to the first one
          local chosen
          for entry, type in vim.fs.dir(root) do
            if type == 'file' and entry:match('%.slnx?$') then
              if proj then
                local content = table.concat(vim.fn.readfile(vim.fs.joinpath(root, entry)), '\n')
                if content:find(proj, 1, true) then
                  chosen = entry
                  break
                end
              end
              chosen = chosen or entry
            end
          end

          if chosen then
            client:notify('solution/open', {
              solution = vim.uri_from_fname(vim.fs.joinpath(root, chosen))
            })
          end
        end,
      })
      vim.lsp.enable('roslyn_ls')
    end
  end,
}
