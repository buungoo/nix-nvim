return {
  "nvim-treesitter",
  category = "core",
  event = { "BufReadPost", "BufNewFile" },
  after = function()
    local group = vim.api.nvim_create_augroup("treesitter-grammars", { clear = true })

    local function start_treesitter(bufnr, filetype)
      local lang = vim.treesitter.language.get_lang(filetype)
      if not lang then return end
      if not pcall(vim.treesitter.language.add, lang) then return end
      pcall(vim.treesitter.start, bufnr, lang)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        start_treesitter(args.buf, args.match)
      end,
    })

    start_treesitter(0, vim.bo.filetype)
  end,
}
