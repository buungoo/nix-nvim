-- Possible additions?:
-- https://github.com/hasansujon786/nvim-navbuddy

-- Collect all plugin specs from lua/plugins/ recursively.
-- Each file should return a single lze spec table.
--
-- Loading laziness (early → late):
--   VimEnter          - UI is ready, before any file is displayed
--   DeferredUIEnter   - shortly after UI loads, idle callback
--   BufReadPost       - a file buffer has been opened and read
--   BufNewFile        - a named buffer for a file that does not exist yet
--   InsertEnter       - user enters insert mode
--   CmdlineEnter      - user opens the command line (:)
--   keys = {}         - only when the mapped key is pressed
-- Keep the old picker configuration available without importing its spec.
local disabled_specs = { ['util/fzf-lua.lua'] = true }

local function load_specs(dir, prefix)
  prefix = prefix or ''
  local specs = {}
  local handle = vim.uv.fs_scandir(dir)
  if not handle then return specs end
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then break end
    local path = dir .. '/' .. name
    local relative_path = prefix .. name
    if typ == 'directory' then
      vim.list_extend(specs, load_specs(path, relative_path .. '/'))
    elseif name:match('%.lua$') and not disabled_specs[relative_path] then
      local ok, spec = pcall(dofile, path)
      if ok and spec then
        table.insert(specs, spec)
      end
    end
  end
  return specs
end

-- Resolve lua/ directory from this file's location
local lua_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
nixInfo.lze.load(load_specs(lua_dir .. '/plugins'))
