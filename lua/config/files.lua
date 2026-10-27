local M = {}
local fullscreen = false
local widths = { 60, 20, 10 }
local preview_width = 40
local border = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' }

local function window_widths()
   local available = math.max(vim.o.columns - 4, 2)
   local focus = math.min(widths[1], math.floor(0.6 * available))
   return { width_focus = focus, width_nofocus = widths[2], width_preview = math.min(preview_width, available - focus) }
end

function M.open_parent()
   local path = vim.api.nvim_buf_get_name(0)
   if vim.bo.buftype ~= '' or path == '' then
      path = vim.fn.getcwd()
   elseif not vim.uv.fs_stat(path) then
      local parent = vim.fs.dirname(path)
      path = parent and vim.fn.isdirectory(parent) == 1 and parent or vim.fn.getcwd()
   end
   require('mini.files').open(path, true)
end

function M.toggle_fullscreen()
   local files = require('mini.files')
   if not files.get_explorer_state() then
      return
   end
   fullscreen = not fullscreen
   files.refresh()
end

local function update_layout(ev)
   local state = require('mini.files').get_explorer_state()
   if not state then
      return
   end

   -- All windows are available here now. Use their public paths rather than
   -- decoding the internal minifiles:// buffer names (discussion #2448).
   local focus
   for i, win in ipairs(state.windows) do
      if win.path == state.branch[state.depth_focus] then
         focus = i
      end
   end
   if not focus then
      return
   end

   local sizes, total = {}, 0
   for i in ipairs(state.windows) do
      sizes[i] = widths[math.min(math.abs(i - focus) + 1, #widths)]
      if i == focus + 1 then
         sizes[i] = preview_width
      end
      total = total + sizes[i]
   end
   local available = math.max(vim.o.columns - 2 * #sizes, #sizes)
   if fullscreen or total > available then
      local used = 0
      for i, width in ipairs(sizes) do
         sizes[i] = math.max(math.floor(available * width / total), 1)
         used = used + sizes[i]
      end
      sizes[focus] = sizes[focus] + available - used
      total = available
   end

   local left = 0
   for i = 1, focus - 1 do
      left = left + sizes[i] + 2
   end
   local center = math.floor((vim.o.columns - sizes[focus] - 2) / 2)
   local col = fullscreen and 0 or math.max(0, math.min(center - left, vim.o.columns - total - 2 * #sizes))
   local height_available = math.max(vim.o.lines - vim.o.cmdheight - 2, 1)
   for i, win in ipairs(state.windows) do
      if win.win_id == ev.data.win_id then
         local height = fullscreen and height_available or math.min(i == focus and 25 or 20, height_available)
         vim.api.nvim_win_set_config(win.win_id, {
            relative = 'editor',
            width = sizes[i],
            height = height,
            col = col,
            row = fullscreen and 0 or math.floor((height_available - height) / 2),
            border = border,
         })
         return
      end
      col = col + sizes[i] + 2
   end
end

function M.setup()
   local windows = window_widths()
   windows.preview = true
   require('mini.files').setup({
      mappings = { close = '<Esc>' },
      options = { permanent_delete = true, use_as_default_explorer = true },
      windows = windows,
   })
   local group = vim.api.nvim_create_augroup('MiniFilesConfig', { clear = true })
   vim.api.nvim_create_autocmd('User', { group = group, pattern = 'MiniFilesWindowUpdate', callback = update_layout })
   vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'MiniFilesBufferCreate',
      callback = function(ev)
         vim.keymap.set('n', 'gF', M.toggle_fullscreen, { buffer = ev.data.buf_id, desc = 'Toggle fullscreen' })
      end,
   })
   vim.api.nvim_create_autocmd('VimResized', {
      group = group,
      callback = function()
         local files = require('mini.files')
         local windows = window_widths()
         files.config.windows = vim.tbl_extend('force', files.config.windows, windows)
         files.refresh({ windows = windows })
      end,
   })
   require('config.files_images').setup(group)
end

return M
