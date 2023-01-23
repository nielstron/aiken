# Update with 'nix run github:cargo2nix/cargo2nix'
{
  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [cargo2nix.overlays.default];
        };

        rustPkgs = pkgs.rustBuilder.makePackageSet {
          rustVersion = "1.61.0";
          packageFun = import ./Cargo.nix;
        };

      in rec {
        packages = {
          aiken = (rustPkgs.workspace.aiken {}).bin;
          default = packages.aiken;
        };
        devShell = pkgs.devshell.mkShell {
          commands = [{
            name = "aiken";
            category = "Tools for aiken development";
            command =
              "cargo run --";
          }
          {
            name = "uplc";
            category = "Tools for aiken development";
            command =
              "cargo run -- uplc";
          }
          ];
        };
      }
    );
}