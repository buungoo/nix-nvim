{
  description = "Bungos nvim config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.blink-cmp = {
    url = "github:Saghen/blink.cmp";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.blink-indent = {
    url = "github:buungoo/blink.indent";
    flake = false;
  };
  # inputs.blink-pairs = {
  #   url = "github:Saghen/blink.pairs";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  inputs.plugins-blink-lib = {
    url = "github:Saghen/blink.lib";
    flake = false;
  };
  inputs.plugins-line-number-change-mode = {
    url = "github:sethen/line-number-change-mode.nvim";
    flake = false;
  };
  inputs.plugins-nvim-window = {
    url = "gitlab:yorickpeterse/nvim-window";
    flake = false;
  };
  inputs.plugins-tiny-cmdline = {
    url = "github:rachartier/tiny-cmdline.nvim";
    flake = false;
  };
  inputs.neovim-nightly = {
    url = "github:nix-community/neovim-nightly-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
    fullModule = {pkgs, ...}: {
      imports = [module];
      runtimePkgs = with pkgs; [
        # Containers
        docker-language-server

        # Just
        just
        just-lsp

        # Nix
        nixd
        alejandra

        # Lua
        lua-language-server
        stylua

        # C/C++
        clang-tools

        # GLSL
        glsl_analyzer

        # C#
        roslyn-ls

        # JS/TS
        typescript-language-server
        prettier

        # Python
        pyrefly
        ruff

        # Rust
        rust-analyzer
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
        fvim = self.wrappers.neovim-full.wrap {inherit pkgs;};
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

    # For development of this package
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            just
            just-lsp
            alejandra
            lua-language-server
            nixd
            stylua
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
        description = "Lua dev shell with lua-language-server";
      };
      cpp = {
        path = ./templates/cpp;
        description = "C/C++ dev shell with clangd and clang-tools";
      };
      csharp = {
        path = ./templates/csharp;
        description = "C# dev shell with roslyn-ls and dotnet SDK";
      };
      js = {
        path = ./templates/js;
        description = "JS/TS dev shell with typescript-language-server and prettier";
      };
      python = {
        path = ./templates/python;
        description = "Python dev shell with pyrefly";
      };
      rust = {
        path = ./templates/rust;
        description = "Rust dev shell with rust-analyzer";
      };
      glsl = {
        path = ./templates/glsl;
        description = "GLSL dev shell with glsl_analyzer and glslang";
      };
    };
  };
}
