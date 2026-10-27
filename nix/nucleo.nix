{pkgs, src}: let
  version = "0.1.0-${builtins.substring 0 7 src.rev}";
  extension = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
  native = pkgs.rustPlatform.buildRustPackage {
    pname = "nucleo-nvim-native";
    inherit version src;
    cargoHash = "sha256-Db08NnIyQNZ3jmULxKvMrTHSyySKKLgC0b6zkx0bNec=";
    # Keep Lua references bounded while converting large file lists to Rust.
    patches = [./patches/nucleo-large-inputs.patch];

    # mlua's module feature leaves Lua symbols for Neovim to resolve. Unit
    # tests exercise the matcher without linking a standalone Lua module.
    cargoTestFlags = ["--lib" "--no-default-features"];

    installPhase = ''
      runHook preInstall
      install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/libnucleo_nvim${extension} \
        $out/lib/libnucleo_nvim${extension}
      runHook postInstall
    '';
  };
in
  pkgs.vimUtils.buildVimPlugin {
    pname = "nucleo.nvim";
    inherit version src;
    # The upstream loader looks under target/release relative to Cargo.toml.
    # Populate that path at build time; never invoke Cargo in the Nix store.
    postInstall = ''
      mkdir -p $out/target/release
      cp ${native}/lib/libnucleo_nvim${extension} $out/target/release/
    '';
  }
