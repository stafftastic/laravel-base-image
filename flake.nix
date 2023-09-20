{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }:
  let
    lib = nixpkgs.lib;
    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (system: nixpkgs.legacyPackages.${system});
  in {
    packages = eachSystem (system: let
      pkgs = pkgsFor.${system};
    in {
      default = pkgs.callPackage ./image.nix {};
    });
  };
}
