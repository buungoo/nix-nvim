return {
  "incline.nvim",
  category = "core",
  event = "BufReadPost",
  before = function()
    vim.cmd.packadd("nvim-web-devicons")
    vim.cmd.packadd("nvim-navic")
  end,
  after = function()
    local devicons = require('nvim-web-devicons')
    local navic = require('nvim-navic')

    -- navic tracks the cursor's LSP symbol path (class > method > ...), which we
    -- append to the incline winbar below. setup() also registers the
    -- NavicIcons*/NavicText/NavicSeparator highlight groups used when rendering.
    navic.setup()

    -- Feed navic every document-symbol-capable client. Handle both clients that
    -- attach after incline loads (LspAttach) and any that attached before it.
    local function attach(client, buf)
      if client and client:supports_method('textDocument/documentSymbol') then
        navic.attach(client, buf)
      end
    end
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
      end,
    })
    for _, client in ipairs(vim.lsp.get_clients()) do
      for buf in pairs(client.attached_buffers or {}) do
        attach(client, buf)
      end
    end

    require('incline').setup({
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
          filename = '[No Name]'
        end
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified
        local res = {
          ft_icon and { ' ', ft_icon, ' ', guifg = ft_color } or '',
          ' ',
          { filename, gui = modified and 'bold,italic' or 'bold' },
        }
        -- Only the focused window has a meaningful cursor symbol path.
        if props.focused then
          for _, item in ipairs(navic.get_data(props.buf) or {}) do
            res[#res + 1] = {
              { ' › ', group = 'NavicSeparator' },
              { item.icon, group = 'NavicIcons' .. item.type },
              { item.name, group = 'NavicText' },
            }
          end
        end
        res[#res + 1] = ' '
        return res
      end,
    })
  end,
}
