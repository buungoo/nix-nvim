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
      blink-cmp
      colorful-menu-nvim
      conform-nvim
      fidget-nvim
      flash-nvim
      fzf-lua
      gitsigns-nvim
      hlchunk-nvim
      incline-nvim
      inputs.blink-pairs.packages.${pkgs.stdenv.hostPlatform.system}.blink-pairs
      kanagawa-nvim
      lazydev-nvim
      markdown-preview-nvim
      mini-clue
      mini-files
      mini-statusline
      neogit
      nvim-navic
      nvim-lspconfig
      nvim-surround
      nvim-web-devicons
      roslyn-nvim
      satellite-nvim
      tiny-glimmer-nvim

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
    pkgs.glsl_analyzer
    pkgs.just-lsp
    (import ./nix/skim.nix { inherit pkgs; })
  ];
}
