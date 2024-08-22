{
  description = "💡 dokieli is a clientside editor for decentralised article publishing, annotations and social interactions ";

  inputs = {
    nixpkgs.url = "github:feathecutie/nixpkgs/fix-fetch-yarn-deps";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./package.nix { };
      }
    );
}
