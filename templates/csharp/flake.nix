{
  description = "C# development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            dotnet-sdk
            omnisharp-roslyn
          ];
        };
      }
    );
  };
}
