# Soxin v1's library (MIT, see ../LICENSE): the option types and
# mkSoxinModule its modules use, built with soxincfg's nixpkgs and
# home-manager. The modules get it as the `soxinLib` argument.
inputs:

let
  self = {
    lib = {
      modules = import ./modules (inputs // { inherit self; });
      mkSoxinModule = import ./mk-soxin-module.nix (inputs // { inherit self; });
    };
  };
in
self.lib
