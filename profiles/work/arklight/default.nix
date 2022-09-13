{ config, home-manager, lib, mode, ... }:

let
  inherit (lib)
    optionals
    ;

  inherit (home-manager.lib.hm.dag)
    entryAfter
    ;
in
{
  imports =
    [ ]
    ++ optionals (mode == "NixOS") [ ./nixos.nix ];

  config = {
    soxin.programs.rbrowser.browsers = {
      "chromium@arklight" = entryAfter [ "chromium@personal" ] { };
    };
  };
}
