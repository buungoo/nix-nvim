vim.loader.enable()
do
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function (_, default) return default end
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  end
end

-- Custom lze handler: adds a "category" field to plugin specs.
-- Use `category = "general"` in a spec to tie it to a Nix spec group.
-- If that group's `enable` is false in module.nix, the plugin won't load.
-- The mapping from spec names to their enable state lives in settings.cats (see module.nix).
nixInfo.lze.register_handlers {
  {
    spec_field = "category",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name and type(plugin.category) == "string" then
        plugin.enabled = nixInfo(false, "settings", "cats", plugin.category)
      end
      return plugin
    end,
  },
}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keys')
require('config.autocmds')
require('plugins')
