{
  description = "kamera development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # go.mod requires go >= 1.25; use the current nixpkgs toolchain
        go = pkgs.go;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            go
            pkgs.gopls
            pkgs.gotools # goimports, etc.
            pkgs.golangci-lint
            pkgs.golangci-lint-langserver
            pkgs.delve
            pkgs.mockgen
            pkgs.gnumake
            pkgs.jq
            pkgs.graphviz
          ];

          # Keep the Go toolchain pinned to the one provided by the flake.
          GOTOOLCHAIN = "local";

          shellHook = ''
            export GOPATH="''${GOPATH:-$HOME/go}"
            export PATH="$PWD/bin:$GOPATH/bin:$PATH"
          '';
        };

        formatter = pkgs.nixfmt;
      }
    );
}
