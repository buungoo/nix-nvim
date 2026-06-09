return {
  "gitsigns.nvim",
  category = "core",
  event = "BufReadPost",
  after = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.nav_hunk('next') end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.nav_hunk('prev') end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>gS', gs.stage_buffer, { desc = 'git stage buffer' })
        map('n', '<leader>gR', gs.reset_buffer, { desc = 'git reset buffer' })
        map('n', '<leader>gp', gs.preview_hunk_inline, { desc = 'preview git hunk inline' })
        map('n', '<leader>gb', function() gs.blame_line { full = false } end, { desc = 'git blame line' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })

        local ok, miniclue = pcall(require, 'mini.clue')
        if ok then
          vim.list_extend(miniclue.config.clues, {
            { mode = 'n', keys = '<Leader>g', desc = '+git' },
            { mode = 'n', keys = '<Leader>gt', desc = '+toggle' },
          })
        end
      end,
    })
  end,
}
