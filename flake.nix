{
  description = "Bungos nvim config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  inputs.wrappers.inputs.nixpkgs.follows = "nixpkgs";

  inputs.blink-cmp.url = "github:Saghen/blink.cmp";
  inputs.blink-cmp.inputs.nixpkgs.follows = "nixpkgs";

  inputs.plugins-blink-lib = {
    url = "github:Saghen/blink.lib";
    flake = false;
  };

  inputs.plugins-tiny-cmdline = {
    url = "github:rachartier/tiny-cmdline.nvim";
    flake = false;
  };

  inputs.plugins-nvim-window = {
    url = "gitlab:yorickpeterse/nvim-window";
    flake = false;
  };

  inputs.plugins-line-number-change-mode = {
    url = "github:sethen/line-number-change-mode.nvim";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
    fullModule = {pkgs, ...}: {
      imports = [module];
      extraPackages = with pkgs; [
        nixd
        alejandra
        lua-language-server
        stylua
      ];
    };
    fullWrapper = wrappers.lib.evalModule fullModule;
  in {
    wrapperModules = {
      neovim = module;
      default = self.wrapperModules.neovim;
    };
    wrappers = {
      neovim = wrapper.config;
      neovim-full = fullWrapper.config;
      default = self.wrappers.neovim;
    };
    overlays = {
      neovim = final: prev: {neovim = self.wrappers.neovim.wrap {pkgs = final;};};
      default = self.overlays.neovim;
    };
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        nvim = self.wrappers.neovim.wrap {inherit pkgs;};
        nvimf = self.wrappers.neovim-full.wrap {inherit pkgs;};
        default = self.packages.${system}.nvim;
      }
    );
    nixosModules = {
      default = self.nixosModules.neovim;
      neovim = wrappers.lib.getInstallModule {
        name = "neovim";
        value = module;
      };
    };
    homeModules = {
      default = self.homeModules.neovim;
      neovim = self.nixosModules.neovim;
    };

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixd
            alejandra
            lua-language-server
          ];
        };
      }
    );

    templates = {
      nix = {
        path = ./templates/nix;
        description = "Nix dev shell with nixd and alejandra";
      };
      lua = {
        path = ./templates/lua;
        description = "Lua dev shell with lua-language-server and stylua";
      };
    };
  };
}
