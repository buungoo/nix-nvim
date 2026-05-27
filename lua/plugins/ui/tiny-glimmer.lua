return {
  "tiny-glimmer.nvim",
  category = "core",
  event = "BufReadPost",
  after = function()
    require('tiny-glimmer').setup({
      overwrite = {
        search = {
          enabled = true,
        },
        undo = {
          enabled = true,
        },
        redo = {
          enabled = true,
        },
      },
    })
  end,
}
