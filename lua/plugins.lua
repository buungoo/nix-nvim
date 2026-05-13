-- Collect all plugin specs from lua/plugins/ recursively.
-- Each file should return a single lze spec table.
local function load_specs(dir)
  local specs = {}
  local handle = vim.uv.fs_scandir(dir)
  if not handle then return specs end
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then break end
    local path = dir .. '/' .. name
    if typ == 'directory' then
      vim.list_extend(specs, load_specs(path))
    elseif name:match('%.lua$') then
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
