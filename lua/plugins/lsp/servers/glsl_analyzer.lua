return {
  "glsl_analyzer",
  category = "core",
  ft = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
  after = function()
    vim.lsp.config("glsl_analyzer", {})
    vim.lsp.enable("glsl_analyzer")
  end,
}
