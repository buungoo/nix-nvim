inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: {
  imports = [wlib.wrapperModules.neovim];

  config.settings.config_directory = ./.;

  config.package = import ./nix/neovim.nix { inherit pkgs; neovim-nightly = inputs.neovim-nightly; };

  config.hosts.node.nvim-host.enable = false;
  config.hosts.python3.nvim-host.enable = false;
  config.hosts.ruby.nvim-host.enable = false;

  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  config.specs.lze = with pkgs.vimPlugins; [
    lze
    {
      data = lzextras;
      name = "lzextras";
    }
  ];

  config.specs.core = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      aerial-nvim
      # Keep Blink V2, but skip its expensive release-mode Rust test build.
      (inputs.blink-cmp.packages.${pkgs.stdenv.hostPlatform.system}.blink-cmp.overrideAttrs (old: {
        env = old.env // {
          fuzzy_lib = old.env.fuzzy_lib.overrideAttrs (_: {
            doCheck = false;
          });
        };
      }))
      colorful-menu-nvim
      conform-nvim
      fidget-nvim
      flash-nvim
      # Retained as an inactive alternative; its Lua spec is not imported.
      fzf-lua
      gitsigns-nvim
      hlchunk-nvim
      incline-nvim
      image-nvim
      inputs.blink-pairs.packages.${pkgs.stdenv.hostPlatform.system}.blink-pairs
      kanagawa-nvim
      lazydev-nvim
      markdown-preview-nvim
      mini-clue
      mini-files
      mini-extra
      (mini-pick.overrideAttrs (old: {
        # Keep cursor movement native and draw the caret over the next character,
        # rather than adding a cell which looks like a space inside the query.
        patches = (old.patches or []) ++ [
          (pkgs.writeText "mini-pick-prompt.patch" ''
            --- a/lua/mini/pick.lua
            +++ b/lua/mini/pick.lua
            @@ -828 +828,3 @@
                caret_right = '<Right>',
            +    caret_start = "",
            +    caret_end = "",
            @@ -2659 +2661,6 @@
            -    local prompt = { { prompt_prefix, 'MiniPickPromptPrefix' }, { prompt_caret, 'MiniPickPromptCaret' } }
            +    local caret_text = prompt_caret
            +    if after_caret ~= "" then
            +      caret_text = vim.fn.strcharpart(after_caret, 0, 1)
            +      after_caret = vim.fn.strcharpart(after_caret, 1)
            +    end
            +    local prompt = { { prompt_prefix, 'MiniPickPromptPrefix' }, { caret_text, 'MiniPickPromptCaret' } }
            @@ -2757 +2764,3 @@
               caret_right = function(picker, _) H.picker_move_caret(picker, 1)  end,
            +  caret_start = function(picker, _) picker.caret = 1 end,
            +  caret_end = function(picker, _) picker.caret = #picker.query + 1 end,
          '')
        ];
      }))
      mini-statusline
      neogit
      nvim-navic
      nvim-lspconfig
      nvim-surround
      nvim-web-devicons
      roslyn-nvim
      satellite-nvim
      tiny-glimmer-nvim
      (import ./nix/nucleo.nix { inherit pkgs; src = inputs.nucleo; })

      # From non-flake inputs
      (pkgs.vimUtils.buildVimPlugin {
        pname = "blink.indent";
        version = "latest";
        src = inputs.blink-indent;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "line-number-change-mode-nvim";
        version = "latest";
        src = inputs.plugins-line-number-change-mode;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-window";
        version = "latest";
        src = inputs.plugins-nvim-window;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tiny-cmdline-nvim";
        version = "latest";
        src = inputs.plugins-tiny-cmdline;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "smart-paste";
        version = "latest";
        src = inputs.smart-paste;
      })
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
        # Parsers used by this config's configured filetypes/plugins.
        bash
        c
        cpp
        c_sharp
        glsl
        javascript
        just
        lua
        markdown
        markdown_inline
        nix
        objc
        powershell
        python
        rust
        tsx
        typescript
        yaml
      ]))
    ];
  };

  config.runtimePkgs = [
    pkgs.ripgrep
    pkgs.imagemagick
    pkgs.glsl_analyzer
    pkgs.just-lsp
  ];
}
