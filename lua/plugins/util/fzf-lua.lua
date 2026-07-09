return {
  "fzf-lua",
  category = "core",
  event = "DeferredUIEnter",
  keys = {
    { "<leader>sf", function() require("fzf-lua").files() end,                                                                                               desc = "Find Files" },
    { "<leader>sF", function() require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") }) end,                                                               desc = "Find Files (current dir)" },
    -- query_delay debounces rg, --min-query-length gates it until 2+ chars:
    -- skim drives live_grep via `--interactive --cmd` and drains rg's output on
    -- its UI thread, so an empty/1-char query greps the whole repo and freezes it.
    { "<leader>sg", function() require("fzf-lua").grep({ rg_glob = true, search = "", query_delay = 100, fzf_opts = { ["--delimiter"] = ":", ["--nth"] = "3..", ["--min-query-length"] = "2" } }) end, desc = "Grep Files" },
    { "<leader>sb", function() require("fzf-lua").buffers() end,                                                                                             desc = "Find Buffers" },
    {
      "<leader>sd",
      function()
        require("fzf-lua").fzf_exec("find . -type d -not -path '*/.*'", {
          prompt = "Directories> ",
          actions = {
            ["default"] = function(selected)
              require("mini.files").open(selected[1], true)
            end,
          },
        })
      end,
      desc = "Find Directory"
    },
    -- {
    --   "<leader>sd",
    --   function()
    --     require("fzf-lua").fzf_exec("find . -type d -not -path '*/.*'", {
    --       prompt = "Directories> ",
    --       actions = {
    --         ["default"] = function(selected)
    --           vim.cmd.cd(selected[1])
    --         end,
    --       },
    --     })
    --   end,
    --   desc = "Change Directory"
    -- },
  },
  after = function()
    local c = require('plugins.ui.themes.palette')

    vim.api.nvim_set_hl(0, "FzfLuaBorder", { fg = c.picker_border })
    vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { fg = c.picker_preview_border })
    vim.api.nvim_set_hl(0, "FzfLuaTitle", { fg = c.picker_header, bold = true })
    vim.api.nvim_set_hl(0, "FzfLuaHeaderText", { fg = c.picker_header })
    vim.api.nvim_set_hl(0, "FzfLuaFzfMatch", { fg = c.picker_match, bold = true })
    vim.api.nvim_set_hl(0, "FzfLuaFzfInfo", { fg = c.picker_info })
    vim.api.nvim_set_hl(0, "FzfLuaFzfPointer", { fg = c.picker_match })
    vim.api.nvim_set_hl(0, "FzfLuaFzfMarker", { fg = c.picker_match })

    local ok, miniclue = pcall(require, 'mini.clue')
    if ok then
      vim.list_extend(miniclue.config.clues, {
        { mode = 'n', keys = '<Leader>s', desc = '+search' },
      })
    end

    require("fzf-lua").setup({
      fzf_bin = "sk",
      fzf_opts = { ["--tiebreak"] = "score" },
      files = {
        hidden = true,
        no_ignore = true,
        fzf_opts = { ["--algo"] = "fzy" },
        file_ignore_patterns = {
          "%.o$", "%.so$", "%.dylib$", "%.a$", "%.dll$",
          "%.exe$", "%.bin$", "%.pdf$", "%.zip$",
          "%.tar$", "%.gz$", "%.cache$",
          "%.aip$", "%.pak$", "%.ttf$", "%.nrproj$", "%.pdb$", "%.Up2Date$",
          "/%.git/", "/node_modules/",
        },
      },
      winopts = {
        fullscreen = true,
        border = "rounded",
        preview = {
          layout = "vertical",
          vertical = "up:60%",
          border = "rounded",
          scrollbar = false,
        },
      },
    })
  end,
}
