# TODO(high): Surfingkeys must be composed of two files, the main one and the colemak bindings.
{
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    optionals
    ;
in
{
  imports = [ ./nixos-config.nix ];

  options.soxincfg.programs.chromium.enable = mkEnableOption "Install and configure Chromium";
  options.soxincfg.programs.chromium.surfingkeys.enable =
    mkEnableOption "Install and configure Surfingkeys";
}
