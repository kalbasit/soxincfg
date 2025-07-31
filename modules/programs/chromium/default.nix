# TODO(high): Surfingkeys must be composed of two files, the main one and the colemak bindings.
{
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    optionals
    ;
in
{
  imports =
    optionals (mode == "NixOS") [ ./nixos.nix ] ++ optionals (mode == "home-manager") [ ./home.nix ];

  options.soxincfg.programs.chromium.enable = mkEnableOption "Install and configure Chromium";
  options.soxincfg.programs.chromium.surfingkeys.enable =
    mkEnableOption "Install and configure Surfingkeys";
}
