return {
  "glsl_analyzer",
  category = "core",
  ft = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
  after = function()
    vim.lsp.config("glsl_analyzer", {})
    require("config.lsp").enable("glsl_analyzer")
  end,
}
