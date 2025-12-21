{
  inputs,
  pkgs,
}:

let
  inherit (pkgs.lib) findSingle filterAttrs;

  pkgs' = {
    unbound-cache-exporter = pkgs.callPackage ./unbound-cache-exporter { };
  };

  hasElement = list: elem: (findSingle (x: x == elem) "none" "multiple" list) != "none";
in
(filterAttrs (name: pkg: hasElement pkg.meta.platforms pkgs.stdenv.hostPlatform.system) pkgs')
// {
  nvix = import ./nvix { inherit inputs pkgs; };
}
