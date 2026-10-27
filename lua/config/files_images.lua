local M = {}
local current, api
local generation, rendering = 0, false
local namespace = vim.api.nvim_create_namespace('MiniFilesImages')
local extensions =
   { png = true, jpg = true, jpeg = true, gif = true, webp = true, avif = true, bmp = true, ico = true, svg = true }

local function supported_terminal()
   local term = (vim.env.TERM_PROGRAM or vim.env.TERM or ''):lower()
   return vim.fn.has('ttyout') == 1
      and (
         term:find('ghostty', 1, true)
         or term:find('kitty', 1, true)
         or vim.env.KITTY_WINDOW_ID
         or vim.env.GHOSTTY_RESOURCES_DIR
      )
end

local function image_api()
   if api then
      return api
   end
   local image = require('image')
   image.setup({
      backend = 'kitty',
      processor = 'magick_cli',
      kitty_method = 'normal',
      max_height_window_percentage = 100,
      window_overlap_clear_enabled = true,
      hijack_file_patterns = {},
      integrations = {
         markdown = { enabled = false },
         asciidoc = { enabled = false },
         typst = { enabled = false },
         neorg = { enabled = false },
         syslang = { enabled = false },
         html = { enabled = false },
         css = { enabled = false },
         org = { enabled = false },
      },
   })
   api = image
   return api
end

function M.clear()
   generation = generation + 1
   if not current then
      return
   end
   local previous = current
   current = nil
   pcall(previous.image.clear, previous.image)
   if vim.api.nvim_buf_is_valid(previous.buf) then
      vim.api.nvim_buf_clear_namespace(previous.buf, namespace, 0, -1)
   end
end

local function update()
   if not supported_terminal() then
      return
   end
   local state = require('mini.files').get_explorer_state()
   local target
   for _, win in ipairs(state and state.windows or {}) do
      local extension = win.path:match('%.([^./]+)$')
      if extension and extensions[extension:lower()] then
         local stat = vim.uv.fs_stat(win.path)
         if stat and stat.type == 'file' then
            target = win
         end
      end
   end
   if not target then
      return M.clear()
   end
   local buf = vim.api.nvim_win_get_buf(target.win_id)
   if current and (current.path ~= target.path or current.win ~= target.win_id or current.buf ~= buf) then
      M.clear()
   end

   -- Coalesce per-window events and skip images passed over while navigating.
   generation = generation + 1
   local ticket = generation
   local function render()
      if ticket ~= generation or not vim.api.nvim_win_is_valid(target.win_id) then
         return
      end
      if vim.api.nvim_win_get_buf(target.win_id) ~= buf then
         return
      end
      -- ImageMagick pumps the event loop; serialize conversions so a newer
      -- request cannot race an older render using the same image identifier.
      if rendering then
         return vim.defer_fn(render, 20)
      end
      rendering = true
      local ok, err = pcall(function()
         local image = current and current.image
            or image_api().from_file(target.path, {
               id = 'minifiles-' .. vim.fn.sha256(target.path),
               window = target.win_id,
               buffer = buf,
               with_virtual_padding = false,
            })
         if not image then
            return
         end
         if ticket ~= generation then
            image:clear()
            return
         end
         current = { image = image, path = target.path, win = target.win_id, buf = buf }
         image:render({
            width = vim.api.nvim_win_get_width(target.win_id),
            height = vim.api.nvim_win_get_height(target.win_id),
         })
         if ticket ~= generation then
            image:clear()
            return
         end
         if not image.is_rendered then
            return
         end
         -- Conceal the binary placeholder or SVG text without editing the
         -- buffer and creating pending mini.files filesystem changes.
         vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
         for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            if #line > 0 then
               vim.api.nvim_buf_set_extmark(buf, namespace, i - 1, 0, { end_col = #line, conceal = '' })
            end
         end
      end)
      rendering = false
      if not ok then
         M.clear()
         vim.notify('mini.files image preview: ' .. tostring(err), vim.log.levels.WARN)
      end
   end
   vim.defer_fn(render, 100)
end

function M.setup(group)
   vim.api.nvim_create_autocmd('User', { group = group, pattern = 'MiniFilesWindowUpdate', callback = update })
   vim.api.nvim_create_autocmd('User', { group = group, pattern = 'MiniFilesExplorerClose', callback = M.clear })
   vim.api.nvim_create_autocmd('TabLeave', { group = group, callback = M.clear })
   vim.api.nvim_create_autocmd('TabEnter', { group = group, callback = update })
   vim.api.nvim_create_autocmd({ 'WinClosed', 'BufWipeout' }, {
      group = group,
      callback = function(ev)
         if
            current
            and (
               (ev.event == 'WinClosed' and tonumber(ev.match) == current.win)
               or (ev.event == 'BufWipeout' and ev.buf == current.buf)
            )
         then
            M.clear()
         end
      end,
   })
end

return M
