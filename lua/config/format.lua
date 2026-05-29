local M = {}

local handlers = {}

local function as_list(value)
  return type(value) == "table" and value or { value }
end

function M.register(filetypes, formatter)
  for _, ft in ipairs(as_list(filetypes)) do
    handlers[ft] = formatter
  end
end

function M.register_conform(filetypes, formatter_names, opts)
  vim.cmd.packadd("conform.nvim")

  local formatters_by_ft = {}
  for _, ft in ipairs(as_list(filetypes)) do
    formatters_by_ft[ft] = formatter_names
  end

  require("conform").setup({
    formatters_by_ft = formatters_by_ft,
  })

  M.register(filetypes, function()
    require("conform").format(vim.tbl_extend("force", {
      async = false,
      lsp_fallback = true,
    }, opts or {}))
  end)
end

function M.format()
  local formatter = handlers[vim.bo.filetype]
  if formatter then
    return formatter()
  end

  return vim.lsp.buf.format({ async = true })
end

return M
