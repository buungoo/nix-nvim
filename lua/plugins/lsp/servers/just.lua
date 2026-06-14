return {
  "just",
  category = "core",
  ft = "just",
  after = function()
    vim.lsp.config("just", {
      before_init = function(params, _)
        local ec = vim.b.editorconfig
        if type(ec) ~= "table" then
          return
        end

        local indentation

        if ec.indent_style == "tab" then
          indentation = "\t"
        elseif ec.indent_style == "space" then
          local size = tonumber(ec.indent_size) or tonumber(ec.tab_width)
          if size and size > 0 then
            indentation = string.rep(" ", size)
          end
        end

        if not indentation then
          return
        end

        params.initializationOptions = vim.tbl_deep_extend("force", params.initializationOptions or {}, {
          formatting = {
            indentation = indentation,
          },
        })
      end,
    })
    vim.lsp.enable("just")
  end,
}
