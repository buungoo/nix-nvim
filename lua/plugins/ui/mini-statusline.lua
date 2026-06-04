local function darken(hex, factor)
  if type(hex) ~= 'string' then
    return hex
  end

  local value = hex:gsub('#', '')
  if #value ~= 6 then
    return hex
  end

  local function channel(start_idx)
    local n = tonumber(value:sub(start_idx, start_idx + 1), 16)
    return math.max(0, math.floor(n * factor + 0.5))
  end

  return string.format('#%02x%02x%02x', channel(1), channel(3), channel(5))
end

return {
  "mini.statusline",
  category = "core",
  event = "DeferredUIEnter",
  after = function()
    local filename_hl = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineFilename', link = false })
    vim.api.nvim_set_hl(0, 'MiniStatuslineFilenameMuted', {
      fg = darken(filename_hl.fg and string.format('#%06x', filename_hl.fg), 0.65),
      bg = filename_hl.bg and string.format('#%06x', filename_hl.bg) or nil,
    })

    require('mini.statusline').setup({
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          local buf_path = vim.api.nvim_buf_get_name(0)
          local rel_path = ''
          if buf_path ~= '' then
            rel_path = vim.fn.fnamemodify(buf_path, ':.')
            if rel_path == cwd then
              rel_path = vim.fn.fnamemodify(buf_path, ':t')
            end
          end
          local location = MiniStatusline.section_location({ trunc_width = 75 })
          local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

          return MiniStatusline.combine_groups({
            { hl = mode_hl,                 strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { diagnostics } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { cwd } },
            { hl = 'MiniStatuslineFilenameMuted', strings = rel_path ~= '' and { ' ' .. rel_path } or {} },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { search } },
            { hl = mode_hl,                  strings = { location } },
          })
        end,
      },
    })
  end,
}
