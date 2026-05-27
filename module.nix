inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: {
  imports = [wlib.wrapperModules.neovim];

  config.settings.config_directory = ./.;

  config.package = import ./package.nix { inherit pkgs; neovim-nightly = inputs.neovim-nightly; };

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
      # inputs.blink-pairs.packages.${pkgs.system}.blink-pairs # disabled: crates.io blocking nix fetches
      kanagawa-nvim
      lazydev-nvim
      markdown-preview-nvim
      mini-clue
      mini-files
      mini-statusline
      nvim-lspconfig
      nvim-surround
      nvim-web-devicons
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
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };

  config.extraPackages = with pkgs; [
    ripgrep
    skim
  ];
}
