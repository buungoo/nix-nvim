return {
  "blink.cmp",
  category = "core",
  event = { "InsertEnter", "CmdlineEnter" },
  before = function()
    vim.cmd.packadd("colorful-menu.nvim")
  end,
  after = function()
    require("blink.cmp").setup({
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-c>"] = { "cancel", "fallback" },
        ["<C-k>"] = { "snippet_forward", "fallback" },
        ["<C-j>"] = { "snippet_backward", "show_signature", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        keyword = { range = "full" },
        trigger = {
          show_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
        },

        list = {
          selection = {
            preselect = function(ctx)
              return ctx.mode ~= "cmdline"
            end,
            auto_insert = true,
          },
        },

        ghost_text = {
          enabled = true,
        },

        menu = {
          scrollbar = false,
          border = "rounded",
          direction_priority = { "n", "s" },
          auto_show = function(ctx) return ctx.mode ~= "cmdline" end,
          draw = {
            treesitter = { "lsp" },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 50,
          window = {
            border = "rounded",
          },
        },
      },

      signature = {
        enabled = true,
        trigger = {
          show_on_insert_on_trigger_character = true,
        },
        window = {
          border = "rounded",
        },
      },

      cmdline = {
        enabled = true,
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          menu = {
            auto_show = true,
          },
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lsp = {
            async = true,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    })
  end,
}
