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
    ++ optionals (mode == "NixOS") [ ./nixos.nix ]
    ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin.programs.rbrowser.browsers = {
      "vivaldi@keeptruckin" = entryAfter [ "vivaldi@personal" ] { };
      "firefox@keeptruckin" = entryAfter [ "vivaldi@keeptruckin" ] { };
      "chromium@keeptruckin" = entryAfter [ "firefox@keeptruckin" ] { };
    };
  };
}
