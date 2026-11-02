local M = {}

function M.start(command, cwd)
   local pick = require('mini.pick')
   local items, pending, stderr = {}, '', ''
   local stopped, finished, published, publishing = false, false, nil, false
   local job, timer, restore, stop_event, match_event
   local scan_error

   local function cleanup()
      if stopped then return end
      stopped = true
      if timer then timer:stop(); timer:close() end
      if job then pcall(vim.fn.jobstop, job) end
      if stop_event then pcall(vim.api.nvim_del_autocmd, stop_event) end
      if match_event then pcall(vim.api.nvim_del_autocmd, match_event) end
   end

   local publish
   local function queue_publish()
      if stopped or (timer and timer:is_active()) then return end
      timer = timer or vim.uv.new_timer()
      local delay = finished and 0 or (published == nil and 100 or 1000)
      -- Do not overlap MiniPick's asynchronous construction of string items.
      if publishing then delay = 100 end
      timer:start(delay, 0, vim.schedule_wrap(function() publish() end))
   end

   publish = function()
      if stopped or not pick.is_picker_active() then return end
      if publishing then return queue_publish() end
      local name = finished and (scan_error and 'Files (scan error)' or 'Files')
         or ('Files (scanning: %d)'):format(#items)
      pick.set_picker_opts({ source = { name = name } })
      if published == #items then return end

      local matches = pick.get_picker_matches() or {}
      restore = { current = matches.current_ind, marked = matches.marked_inds or {}, tick = pick.get_querytick() }
      published, publishing = #items, true
      -- Published tables must stay immutable while MiniPick consumes them.
      pick.set_picker_items(vim.list_slice(items))
   end

   stop_event = vim.api.nvim_create_autocmd('User', { pattern = 'MiniPickStop', once = true, callback = cleanup })
   match_event = vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniPickMatch',
      callback = function()
         if stopped then return end
         if publishing then
            if #(pick.get_picker_items() or {}) ~= published then return end
            publishing = false
            -- MiniPick first seeds every item as a match, then applies the query.
            -- Restoring here would redraw that temporary, unfiltered list.
            return
         end
         if not restore then return end
         if restore.applied and restore.tick ~= pick.get_querytick() then restore = nil; return end
         if restore.tick == pick.get_querytick() and restore.current then
            pcall(pick.set_picker_match_inds, { restore.current }, 'current')
         end
         if #restore.marked > 0 then pick.set_picker_match_inds(restore.marked, 'marked') end
         restore.applied = true
      end,
   })

   local function fail(message)
      scan_error = message
      vim.notify('File scan: ' .. message, vim.log.levels.WARN)
   end

   local function start()
      if stopped or not pick.is_picker_active() then return end
      local ok, id = pcall(vim.fn.jobstart, command, {
         cwd = pick.get_picker_opts().source.cwd,
         on_stdout = function(_, data)
            if stopped or not data or #data == 0 then return end
            data[1] = pending .. data[1]
            for i = 1, #data - 1 do
               if data[i] ~= '' then items[#items + 1] = data[i] end
            end
            pending = data[#data]
            if #items > (published or 0) then queue_publish() end
         end,
         on_stderr = function(_, data)
            if stopped then return end
            stderr = (stderr .. table.concat(data or {}, '\n')):sub(1, 600)
         end,
         on_exit = function(_, code)
            if stopped then return end
            job, finished = nil, true
            if pending ~= '' then items[#items + 1], pending = pending, '' end
            if code > 1 then fail(vim.trim(stderr) ~= '' and vim.trim(stderr) or ('rg exited with code ' .. code)) end
            if timer then timer:stop() end
            queue_publish()
         end,
      })
      if ok and id > 0 then
         job = id
      else
         finished = true
         fail(ok and ('could not start ' .. command[1]) or tostring(id))
         publish()
      end
   end

   local ok, result = pcall(pick.start, {
      source = { name = 'Files (scanning)', cwd = cwd, items = vim.schedule_wrap(start) },
   })
   cleanup()
   if not ok then error(result) end
   return result
end

return M
