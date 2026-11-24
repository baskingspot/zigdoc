{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.follows = "baskingspot/flake-parts";
    baskingspot = {
      url = "github:baskingspot/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Generates build.zig.zon.nix (`just zon2nix`): the Zig dependencies,
    # transitive ones included, as fixed-output fetches for the package.
    zon2nix = {
      url = "github:jcollie/zon2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # imports and inputsFrom below mirror each other, including the
      # toolchain version: pick that once, in the import.
      imports = with inputs.baskingspot.flakeModules; [
        base
        docs
        zig."0.16"
      ];

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        {
          packages = rec {
            zigdoc = pkgs.callPackage ./nix/package.nix { };
            default = zigdoc;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.devShells.base
              config.devShells.docs
              config.devShells."zig-0-16"
            ];

            packages = [
              inputs.zon2nix.packages.${system}.zon2nix
            ];
          };
        };
    };
}
