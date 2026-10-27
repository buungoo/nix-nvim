return {
  "mini.files",
  category = "core",
  on_require = "mini.files",
  keys = {
    { "-", function() require('config.files').open_parent() end, mode = { "n" }, desc = 'Open parent directory' },
    { "_", function() require('mini.files').open(vim.fn.getcwd(), true) end, mode = { "n" }, desc = 'Open cwd' },
  },
  after = function() require('config.files').setup() end,
}
