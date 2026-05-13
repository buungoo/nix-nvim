inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  config.settings.config_directory = ./.;
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
      kanagawa-nvim
      hlchunk-nvim
      flash-nvim
      fzf-lua
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      lazydev-nvim
      inputs.blink-cmp.packages.${pkgs.system}.blink-cmp
      (pkgs.vimUtils.buildVimPlugin {
        pname = "blink-lib";
        version = "latest";
        src = inputs.plugins-blink-lib;
      })
      colorful-menu-nvim
    ];
  };

  config.extraPackages = with pkgs; [
    skim
  ];
}
