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
      php74 = pkgs.callPackage ./image.nix { php = pkgs.php74; };
      php80 = pkgs.callPackage ./image.nix { php = pkgs.php80; };
      php81 = pkgs.callPackage ./image.nix { php = pkgs.php81; };
      php82 = pkgs.callPackage ./image.nix { php = pkgs.php82; };
      php83 = pkgs.callPackage ./image.nix { php = pkgs.php83; };
    });
  };
}
