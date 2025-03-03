channels:

let
  inherit (channels.nixpkgs) lib system;
  inherit (lib) findSingle filterAttrs platforms;

  pkgs = { };

  hasElement = list: elem: (findSingle (x: x == elem) "none" "multiple" list) != "none";
in
filterAttrs (name: pkg: hasElement (pkg.meta.platforms or platforms.all) system) pkgs
