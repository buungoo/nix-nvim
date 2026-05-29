return {
  "docker_compose_language_service",
  category = "core",
  ft = "yaml.docker-compose",
  beforeAll = function()
    vim.filetype.add({
      filename = {
        ["compose.yaml"] = "yaml.docker-compose",
        ["compose.yml"] = "yaml.docker-compose",
        ["docker-compose.yaml"] = "yaml.docker-compose",
        ["docker-compose.yml"] = "yaml.docker-compose",
      },
      pattern = {
        [".*/compose%.ya?ml"] = "yaml.docker-compose",
        [".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
      },
    })
  end,
  after = function()
    vim.lsp.config("docker_compose_language_service", {
      cmd = { "docker-language-server", "start", "--stdio" },
      filetypes = { "yaml.docker-compose" },
      get_language_id = function(_, ft)
        if ft == "yaml.docker-compose" then
          return "dockercompose"
        end
        return ft
      end,
    })
    vim.lsp.enable("docker_compose_language_service")

    require("config.format").register_conform("yaml.docker-compose", { "prettier" })
  end,
}
