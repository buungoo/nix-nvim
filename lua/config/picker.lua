local M = {}
local preview, hints = {}, {}
local grep_name = 'Grep (2+ chars; regex -- glob)'
local hint_entries = {
  fuzzy = {
    { 'fzy', 'fuzzy', { { 0, 1 }, { 3, 5 } } },
    { '^pre', 'prefix', { { 0, 3 } } },
    { 'fix$', 'suffix', { { 3, 6 } } },
    { "'str", 'substring', { { 3, 6 } } },
    { '^exact$', 'exact', { { 0, 5 } } },
    { '!tmp', 'tmp', { { 0, 3, 'PickerHintExcluded' } } },
  },
  grep = {
    { '^pre', 'prefix', { { 0, 3 } } },
    { 'fix$', 'suffix', { { 3, 6 } } },
    { 'a|b', 'b', { { 0, 1 } } },
    { '\\bword\\b', 'a word!', { { 2, 6 } } },
    { '-- *.lua', 'init.lua', { { 0, 8 } } },
    { '-- !test/*', 'test/a.lua', { { 0, 10, 'PickerHintExcluded' } } },
  },
}

local function hint_lines(kind, width)
  local lines, spans = { '' }, {}
  for _, entry in ipairs(hint_entries[kind or 'fuzzy']) do
    local text = entry[1] .. ' ' .. entry[2]
    local row = #lines
    local separator = lines[row] == '' and '' or '   '
    if vim.fn.strdisplaywidth(lines[row] .. separator .. text) > width and lines[row] ~= '' then
      lines[#lines + 1], separator = '', ''
      row = #lines
    end
    local col = #lines[row] + #separator
    lines[row] = lines[row] .. separator .. text
    spans[#spans + 1] = { row - 1, col, col + #entry[1], 'PickerHintKey' }
    local example_col = col + #entry[1] + 1
    for _, range in ipairs(entry[3] or {}) do
      spans[#spans + 1] = { row - 1, example_col + range[1], example_col + range[2], range[3] or 'NucleoMatchPerfect' }
    end
  end
  return lines, spans
end

-- Preserve the 60% preview; the lower 40% includes the query syntax legend.
function M.layout()
  local height = math.max(vim.o.lines - vim.o.cmdheight, 6)
  local split = math.min(math.max(math.floor(0.6 * height), 3), height - 3)
  local width = math.max(vim.o.columns - 2, 1)
  local hint_height = math.min(math.max(#hint_lines('fuzzy', width), #hint_lines('grep', width)), 4, height - split - 3)
  local common = {
    relative = 'editor', anchor = 'NW', col = 0,
    width = width, border = 'rounded',
  }
  local top = vim.tbl_extend('force', common, { row = 0, height = split - 2 })
  local bottom = vim.tbl_extend('force', common, { row = split + hint_height, height = height - split - hint_height - 2 })
  local legend = hint_height > 0 and vim.tbl_extend('force', common, { row = split, col = 1, height = hint_height, border = 'none' }) or nil
  return top, bottom, legend
end

local function close_preview()
  for _, pane in ipairs({ preview, hints }) do
    if pane.win and vim.api.nvim_win_is_valid(pane.win) then vim.api.nvim_win_close(pane.win, true) end
  end
  preview, hints = {}, {}
end

local function update_hints(config)
  if not config then
    if hints.win and vim.api.nvim_win_is_valid(hints.win) then vim.api.nvim_win_close(hints.win, true) end
    hints.win = nil
    return
  end
  local changed = hints.width ~= config.width or hints.height ~= config.height
  if not (hints.win and vim.api.nvim_win_is_valid(hints.win)) then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'picker-hints'
    hints.win = vim.api.nvim_open_win(buf, false, vim.tbl_extend('force', config, {
      focusable = false, style = 'minimal', noautocmd = true, zindex = 250,
    }))
    vim.wo[hints.win].winhighlight = 'NormalFloat:MiniPickNormal,EndOfBuffer:MiniPickNormal'
    vim.wo[hints.win].wrap = false
    changed = true
  else
    vim.api.nvim_win_set_config(hints.win, config)
  end
  if not changed then return end
  hints.width, hints.height = config.width, config.height
  local lines, spans = hint_lines(hints.kind, config.width)
  local truncated = #lines > config.height
  lines = vim.list_slice(lines, 1, config.height)
  while #lines < config.height do lines[#lines + 1] = '' end
  -- Clip exceptionally narrow terminals rather than wrapping into the prompt.
  for i, line in ipairs(lines) do lines[i] = vim.fn.strcharpart(line, 0, config.width) end
  local buf = vim.api.nvim_win_get_buf(hints.win)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local ns = vim.api.nvim_create_namespace('PickerHints')
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, line in ipairs(lines) do
    vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #line, hl_group = 'PickerHintText' })
  end
  for _, span in ipairs(spans) do
    local line = lines[span[1] + 1]
    if line and span[2] < #line then
      vim.api.nvim_buf_set_extmark(buf, ns, span[1], span[2], { end_col = math.min(span[3], #line), hl_group = span[4], priority = 110 })
    end
  end
  if truncated then
    vim.api.nvim_buf_set_extmark(buf, ns, #lines - 1, 0, { virt_text = { { '…', 'PickerHintText' } }, virt_text_pos = 'right_align' })
  end
end

local function update_preview()
  local pick = require('mini.pick')
  if not pick.is_picker_active() then return end
  local config, _, legend = M.layout()
  update_hints(legend)
  if not (preview.win and vim.api.nvim_win_is_valid(preview.win)) then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    config = vim.tbl_extend('force', config, {
      focusable = false, style = 'minimal', noautocmd = true,
      zindex = 250, title = ' Preview ', title_pos = 'center',
    })
    preview.win = vim.api.nvim_open_win(buf, false, config)
    vim.wo[preview.win].winhighlight = 'NormalFloat:MiniPickNormal,FloatBorder:PickerPreviewBorder'
    vim.wo[preview.win].wrap = false
    vim.wo[preview.win].scrolloff = 0
  else
    vim.api.nvim_win_set_config(preview.win, config)
  end

  local item = (pick.get_picker_matches() or {}).current
  if preview.item ~= item or not preview.initialized then
    preview.item, preview.initialized = item, true

    -- Fresh scratch buffers avoid stale syntax/highlights and respect the
    -- source.preview contract. Replacing the previous one wipes it automatically.
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    vim.api.nvim_win_set_buf(preview.win, buf)
    if item ~= nil then pick.get_picker_opts().source.preview(buf, item) end
  end

  -- Apply after the buffer change: minimal float styling resets gutter options
  -- when switching buffers, not just when the floating window is first opened.
  local target = pick.get_picker_state().windows.target
  for _, option in ipairs({ 'number', 'relativenumber', 'numberwidth', 'signcolumn', 'statuscolumn', 'cursorline', 'cursorlineopt' }) do
    vim.wo[preview.win][option] = vim.wo[target][option]
  end
end

local function scroll_preview(keys)
  if preview.win and vim.api.nvim_win_is_valid(preview.win) then
    vim.api.nvim_win_call(preview.win, function() vim.cmd('normal! ' .. keys) end)
  end
end

function M.setup()
  local pick, nucleo = require('mini.pick'), require('nucleo')
  -- mlua must not retain a short-lived item-processing coroutine as its host
  -- state. Initialize on the main Lua thread before allowing native calls.
  local native_ready = false
  local function init_native() native_ready = nucleo.filter({}, '') ~= nil end
  if coroutine.running() == nil then
    init_native()
  else
    vim.schedule(init_native)
  end
  pick.setup({
    window = {
      config = function() local _, bottom = M.layout(); return bottom end,
      prompt_prefix = '    ', prompt_caret = ' ',
    },
    source = {
      match = function(stritems, inds, query)
        if hints.kind ~= 'fuzzy' then hints.kind, hints.width = 'fuzzy', nil end
        local matches = native_ready and nucleo.filter(stritems, table.concat(query))
        return matches or pick.default_match(stritems, inds, query)
      end,
      show = function(buf, items, query)
        pick.default_show(buf, items, {}, { show_icons = true })
        if not native_ready or not nucleo.highlight(buf, table.concat(query)) then
          pick.default_show(buf, items, query, { show_icons = true })
        end
        update_preview()
      end,
    },
    mappings = {
      caret_start = '<C-a>',
      caret_end = '<C-e>',
      move_up = '<C-k>',
      move_down = '<C-j>',
      -- Preview is always visible above; do not replace the results with it.
      toggle_preview = '',
      mark = '<Tab>',
      mark_all = '', -- Ctrl+A moves to the start of the query instead.
      preview_down = { char = '<S-Down>', func = function() scroll_preview('\004') end },
      preview_up = { char = '<S-Up>', func = function() scroll_preview('\021') end },
    },
  })

  local group = vim.api.nvim_create_augroup('PickerPreview', { clear = true })
  vim.api.nvim_create_autocmd('User', { group = group, pattern = 'MiniPickStart', callback = function()
    hints.kind = pick.get_picker_opts().source.name == grep_name and 'grep' or 'fuzzy'
    hints.width = nil
    update_preview()
  end })
  vim.api.nvim_create_autocmd('User', { group = group, pattern = 'MiniPickStop', callback = close_preview })
  vim.api.nvim_create_autocmd('VimResized', { group = group, callback = update_preview })

  local function set_highlights()
    local c = require('plugins.ui.themes.palette')
    vim.api.nvim_set_hl(0, 'MiniPickBorder', { fg = c.picker_preview_border })
    vim.api.nvim_set_hl(0, 'PickerPreviewBorder', { fg = c.picker_preview_border })
    vim.api.nvim_set_hl(0, 'MiniPickBorderText', { fg = c.picker_header, bold = true })
    vim.api.nvim_set_hl(0, 'MiniPickPrompt', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'MiniPickPromptPrefix', { fg = c.picker_info, bold = true })
    vim.api.nvim_set_hl(0, 'MiniPickPromptCaret', { fg = c.search_bg, bg = c.picker_match, bold = true })
    vim.api.nvim_set_hl(0, 'PickerHintKey', { fg = c.picker_info, bold = true })
    vim.api.nvim_set_hl(0, 'PickerHintText', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'PickerHintExcluded', { fg = vim.api.nvim_get_hl(0, { name = 'NucleoMatchWeak', link = false }).fg, strikethrough = true })
  end
  set_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = function() vim.schedule(set_highlights) end })

  local ok, clue = pcall(require, 'mini.clue')
  if ok then vim.list_extend(clue.config.clues, { { mode = 'n', keys = '<Leader>s', desc = '+search' } }) end

  -- Keep :Pick using the same file/grep/directory sources as the keybindings.
  pick.registry.files = function(opts) return M.files(opts.cwd) end
  pick.registry.grep_live = M.grep
  pick.registry.directories = M.directories
end

function M.files(cwd)
  local command = { 'rg', '--files', '--hidden', '--no-ignore', '--color=never' }
  -- Match the exclusions from the retained fzf-lua configuration. Filter at
  -- enumeration time rather than passing build/binary artifacts to the matcher.
  local exclusions = {
    '*.o', '*.so', '*.dylib', '*.a', '*.dll', '*.exe', '*.bin', '*.pdf',
    '*.zip', '*.tar', '*.gz', '*.cache', '*.aip', '*.pak', '*.ttf',
    '*.nrproj', '*.pdb', '*.Up2Date', '.git', 'node_modules',
  }
  for _, glob in ipairs(exclusions) do vim.list_extend(command, { '--glob', '!' .. glob }) end
  return require('mini.pick').builtin.cli({ command = command }, { source = { name = 'Files', cwd = cwd } })
end

function M.directories()
  return require('mini.pick').builtin.cli({ command = { 'find', '.', '-type', 'd', '-not', '-path', '*/.*' } }, {
    source = {
      name = 'Directories',
      choose = function(item)
        if not item then return end
        local state = require('mini.pick').get_picker_state()
        local path = vim.fs.joinpath(require('mini.pick').get_picker_opts().source.cwd, item)
        -- Run after the picker closes so mini.files receives focus normally.
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(state.windows.target) then vim.api.nvim_set_current_win(state.windows.target) end
          require('mini.files').open(path, true)
        end)
      end,
    },
  })
end

function M.grep_word()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  return M.grep('\\b' .. vim.fn.escape(word, '\\.^$|?*+()[]{}') .. '\\b')
end

function M.grep(initial_pattern)
  local pick = require('mini.pick')
  local timer, process, querytick = vim.uv.new_timer(), nil, nil
  local scope_globs, refine_name, refine_count = '', nil, 0
  local stopped = false
  local function parse_query()
    -- Use the original query (mini.pick can lowercase the match argument).
    local query = table.concat(pick.get_picker_query())
    local pattern, globs = query:match('^(.-)%s+%-%-%s+(.*)$')
    if not pattern then
      globs = query:match('^%-%-%s+(.*)$')
      pattern = globs and '' or query
    end
    return pattern, vim.trim(scope_globs .. ' ' .. (globs or ''))
  end
  local function cancel()
    timer:stop()
    if process then process:kill(); process = nil end
  end
  local function cleanup()
    if stopped then return end
    stopped = true
    cancel()
    timer:close()
  end
  local stop_event = vim.api.nvim_create_autocmd('User', { pattern = 'MiniPickStop', once = true, callback = cleanup })
  local match = function()
    if stopped then return end
    if hints.kind ~= 'grep' then hints.kind, hints.width = 'grep', nil end
    local tick = pick.get_querytick()
    if querytick == tick then return end
    querytick = tick
    cancel()
    local set_opts = { do_match = false, querytick = tick }
    pick.set_picker_items({}, set_opts)
    local pattern, globs = parse_query()
    local files_only = pattern == '' and globs ~= ''
    if not files_only and vim.fn.strchars(pattern) < 2 then return end
    timer:start(100, 0, vim.schedule_wrap(function()
      if stopped or not pick.is_picker_active() or pick.get_querytick() ~= tick then return end
      -- File filters can be chosen before any content search, without reading
      -- every matching file's contents just to populate the initial results.
      local command = files_only and { 'rg', '--files', '--color=never' } or {
        'rg', '--column', '--line-number', '--no-heading', '--color=never',
        '--smart-case', '--field-match-separator', '\\x00',
      }
      for glob in globs:gmatch('%S+') do vim.list_extend(command, { '--glob', glob }) end
      vim.list_extend(command, files_only and { '--', '.' } or { '--', pattern, '.' })
      process = pick.set_picker_items_from_cli(command, {
        spawn_opts = { cwd = pick.get_picker_opts().source.cwd }, set_items_opts = set_opts,
      })
    end))
  end
  local function refine()
    if not stopped then
      local pattern, globs = parse_query()
      if pattern == '' then
        if globs == '' then return end
        -- Keep the selected file filters while clearing the prompt for grep.
        cancel()
        scope_globs, querytick = globs, nil
        pick.set_picker_opts({ source = { name = grep_name .. ' [-- ' .. scope_globs .. ']' } })
        pick.set_picker_query({})
        return
      end
    end

    -- Content results still refine with the configured nucleo matcher, as in
    -- mini.pick's native action, but first stop pending grep work.
    local items = (pick.get_picker_matches() or {}).all or {}
    refine_name = refine_name or pick.get_picker_opts().source.name
    refine_count = refine_count + 1
    cleanup()
    local suffix = refine_count == 1 and '' or (' ' .. refine_count)
    pick.set_picker_opts({ source = {
      name = refine_name .. ' (Refine' .. suffix .. ')',
      match = pick.config.source.match or pick.default_match,
    } })
    pick.set_picker_query({})
    pick.set_picker_items(items)
  end
  local start_event
  if type(initial_pattern) == 'string' and initial_pattern ~= '' then
    start_event = vim.api.nvim_create_autocmd('User', { pattern = 'MiniPickStart', once = true, callback = function()
      pick.set_picker_query(vim.fn.split(initial_pattern, '\\zs'))
    end })
  end
  local ok, result = pcall(pick.start, {
    source = { name = grep_name, items = {}, match = match },
    mappings = {
      refine = '',
      grep_refine = { char = pick.config.mappings.refine, func = refine },
    },
  })
  cleanup()
  pcall(vim.api.nvim_del_autocmd, stop_event)
  if start_event then pcall(vim.api.nvim_del_autocmd, start_event) end
  if not ok then error(result) end
  return result
end

function M.lsp(scope)
  require('mini.pick') -- Ensure the frontend is configured before mini.extra.
  return require('mini.extra').pickers.lsp({ scope = scope })
end

-- mini.extra does not support call hierarchy. Neovim already collects the
-- locations for this method, so feed its on_list result into the same frontend.
function M.incoming_calls()
  local pick = require('mini.pick')
  vim.lsp.buf.incoming_calls({
    on_list = function(list)
      local items = vim.tbl_map(function(entry)
        local path = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)
        return {
          path = path, lnum = entry.lnum, col = entry.col,
          text = string.format('%s:%d:%d: %s', vim.fn.fnamemodify(path, ':.'), entry.lnum, entry.col, entry.text or ''),
        }
      end, list.items)
      pick.start({ source = { name = list.title or 'Incoming Calls', items = items } })
    end,
  })
end

return M
