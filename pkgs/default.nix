channels@{ ... }:

let
  inherit (channels.nixpkgs) callPackage lib system;
  inherit (lib) findSingle filterAttrs platforms;

  pkgs = {
    terraform-providers-unifi = callPackage ./terraform-provider-unifi.nix { };
  };

  hasElement = list: elem:
    (findSingle (x: x == elem) "none" "multiple" list) != "none";
in
filterAttrs (name: pkg: hasElement (pkg.meta.platforms or platforms.all) system) pkgs
