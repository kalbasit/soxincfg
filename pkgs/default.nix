{
  callPackage,
  lib,
  system,
  ...
}:

let
  inherit (lib) findSingle filterAttrs;

  pkgs = {
    unbound-cache-exporter = callPackage ./unbound-cache-exporter { };
  };

  hasElement = list: elem: (findSingle (x: x == elem) "none" "multiple" list) != "none";
in
filterAttrs (name: pkg: hasElement pkg.meta.platforms system) pkgs
