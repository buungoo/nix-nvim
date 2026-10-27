return {
  'mini.extra',
  category = 'core',
  on_require = 'mini.extra',
  after = function() require('mini.extra').setup() end,
}
