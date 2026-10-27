local M = {}

function M.incoming_calls()
  local pick = require('mini.pick')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local params_by_client = {}
  local clients = vim.lsp.get_clients({ bufnr = buf })
  local pending, candidates = 0, {}

  for _, client in ipairs(clients) do
    if client:supports_method('textDocument/prepareCallHierarchy', buf) then
      local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
      pending = pending + 1
      client:request('textDocument/prepareCallHierarchy', params, function(err, result)
        if not err and result then
          if result.uri then result = { result } end
          vim.list_extend(candidates, result)
        end
        pending = pending - 1
        if pending ~= 0 then return end
        if #candidates == 0 then
          vim.notify('No call hierarchy available', vim.log.levels.INFO)
          return
        end
        vim.ui.select(candidates, {
          prompt = 'Call hierarchy item',
          format_item = function(item) return item.name end,
        }, function(selected)
          if not selected or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then return end
          local client_for_item
          for _, c in ipairs(clients) do
            if c:supports_method('callHierarchy/incomingCalls', buf) then client_for_item = c; break end
          end
          if not client_for_item then
            vim.notify('No incoming calls provider', vim.log.levels.WARN)
            return
          end
          client_for_item:request('callHierarchy/incomingCalls', { item = selected }, function(call_err, calls)
            if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then return end
            if call_err or not calls or #calls == 0 then
              vim.notify(call_err and tostring(call_err) or 'No incoming calls found', vim.log.levels.INFO)
              return
            end
            local items = {}
            for _, call in ipairs(calls) do
              local item = call.from
              local uri = item.uri
              local path = vim.uri_to_fname(uri)
              local range = (call.fromRanges or {})[1] or item.selectionRange
              local lnum = range.start.line + 1
              local col = vim.str_byteindex(item.name, item.name:len(), client_for_item.offset_encoding)
              local text = item.name
              items[#items + 1] = {
                path = path, lnum = lnum, col = range.start.character + 1,
                text = string.format('%s:%d:%d: %s', vim.fn.fnamemodify(path, ':.'), lnum, range.start.character + 1, text),
              }
            end
            pick.start({ source = { name = 'Incoming Calls', items = items, choose = pick.default_choose, preview = pick.default_preview } })
          end, buf)
        end)
      end, buf)
    end
  end
  if pending == 0 then vim.notify('No call hierarchy provider', vim.log.levels.INFO) end
end

return M
