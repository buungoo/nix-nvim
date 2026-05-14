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

  # Override neovim-unwrapped to show startup time in the intro screen
  config.package = pkgs.neovim-unwrapped.overrideAttrs (old: {
    doCheck = false;
    postPatch = (old.postPatch or "") + ''
      # Add startup time rendering using clock() directly in version.c
      sed -i '/#include "nvim\/version.h"/a #include <time.h>' src/nvim/version.c

      # Replace Uganda lines with startup time line
      sed -i 's|N_("Help poor children in Uganda!"),||' src/nvim/version.c
      sed -i 's|N_("type  :help Kuwasha<Enter>  for information "),|"⚡ startup %.1fms",|' src/nvim/version.c

      # Add startup time formatting as a separate block before do_intro_line
      sed -i '/do_intro_line(row, mesg/i\
    if (strstr(lines[i], "startup") != NULL) {\
      static double ms = 0;\
      if (ms == 0) ms = (double)clock() / (CLOCKS_PER_SEC / 1000);\
      mesg_size = snprintf(NULL, 0, lines[i], ms);\
      assert(mesg_size > 0);\
      mesg = xmallocz((size_t)mesg_size);\
      snprintf(mesg, (size_t)mesg_size + 1, lines[i], ms);\
    }' src/nvim/version.c
    '';
  });

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
      # nvim-treesitter.withAllGrammars # Or ↓ (This does the same thing but doesn't pull in nvim-treesitter [archived])
      (pkgs.vimUtils.buildVimPlugin {
        pname = "treesitter-grammars";
        version = "latest";
        src = pkgs.symlinkJoin {
          name = "treesitter-grammars";
          paths = pkgs.vimPlugins.nvim-treesitter.allGrammars;
        };
      })
      lazydev-nvim
      inputs.blink-cmp.packages.${pkgs.system}.blink-cmp
      (pkgs.vimUtils.buildVimPlugin {
        pname = "blink-lib";
        version = "latest";
        src = inputs.plugins-blink-lib;
      })
      colorful-menu-nvim
      satellite-nvim
      nvim-surround
      nvim-autopairs
      mini-files
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tiny-cmdline-nvim";
        version = "latest";
        src = inputs.plugins-tiny-cmdline;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-window";
        version = "latest";
        src = inputs.plugins-nvim-window;
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "line-number-change-mode-nvim";
        version = "latest";
        src = inputs.plugins-line-number-change-mode;
      })
    ];
  };

  config.extraPackages = with pkgs; [
    skim
  ];
}
