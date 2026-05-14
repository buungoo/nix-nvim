return {
  "mini.files",
  category = "core",
  keys = {
    { "-", function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true) end, mode = { "n" }, desc = 'Open parent directory' },
    { "<leader>-", function() require('mini.files').open(vim.fn.getcwd(), true) end, mode = { "n" }, desc = 'Open cwd' },
  },
  after = function()
    local MiniFiles = require('mini.files')

    MiniFiles.setup({
      mappings = {
        close       = '<Esc>',
        go_in       = 'l',
        go_in_plus  = 'L',
        go_out      = 'h',
        go_out_plus = 'H',
        reset       = '<BS>',
        reveal_cwd  = '@',
        show_help   = 'g?',
        synchronize = '=',
        trim_left   = '<',
        trim_right  = '>',
      },
      options = {
        permanent_delete = true,
        use_as_default_explorer = true,
      },
      windows = {
        max_number = math.huge,
        preview = false,
        width_focus = 50,
        width_nofocus = 15,
        width_preview = 25,
      },
    })

    local widths = { 60, 20, 10 }

    local ensure_center_layout = function(ev)
      local state = MiniFiles.get_explorer_state()
      if state == nil then return end

      local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match('^minifiles://%d+/(.*)')
      local depth_this
      for i, path in ipairs(state.branch) do
        if path == path_this then depth_this = i end
      end
      if depth_this == nil then return end
      local depth_offset = depth_this - state.depth_focus

      local i = math.abs(depth_offset) + 1
      local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
      win_config.width = i <= #widths and widths[i] or widths[#widths]

      win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
      for j = 1, math.abs(depth_offset) do
        local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
        local prev_win_width = (sign == -1 and widths[j+1]) or widths[j] or widths[#widths]
        win_config.col = win_config.col + sign * (prev_win_width + 2)
      end

      win_config.height = depth_offset == 0 and 25 or 20
      win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
      win_config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
      vim.api.nvim_win_set_config(ev.data.win_id, win_config)
    end

    vim.api.nvim_create_autocmd("User", { pattern = "MiniFilesWindowUpdate", callback = ensure_center_layout })
  end,
}
