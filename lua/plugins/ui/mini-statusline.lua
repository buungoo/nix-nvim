return {
  "mini.statusline",
  category = "core",
  event = "DeferredUIEnter",
  after = function()
    require('mini.statusline').setup({
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          local location = MiniStatusline.section_location({ trunc_width = 75 })
          local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

          return MiniStatusline.combine_groups({
            { hl = mode_hl,                 strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { diagnostics } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { cwd } },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { search } },
            { hl = mode_hl,                  strings = { location } },
          })
        end,
      },
    })
  end,
}
