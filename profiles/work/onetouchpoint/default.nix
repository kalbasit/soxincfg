{ config, home-manager, lib, mode, ... }:

let
  inherit (lib)
    optionals
    ;

  inherit (home-manager.lib.hm.dag)
    entryAnywhere
    ;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin.programs.rbrowser.browsers = {
      "chromium@onetouchpoint" = entryAnywhere { };
    };
  };
}
