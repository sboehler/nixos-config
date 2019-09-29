{ pkgs, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      niv = (import sources.niv {}).niv;
      lorri = (import sources.lorri {});

      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ghc865 = pkgs.haskell.packages.ghc865.override {
            overrides = self: super: {
              beans = self.callPackage ./beans.nix {};
            };
          };
        };
      };

      haskellPackages = haskell.packages.ghc865;
    };
  };

  allowUnfree = true;
}
