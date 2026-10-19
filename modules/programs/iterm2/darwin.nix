{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ./darwin-config.nix ];

  options.soxincfg.programs.iterm2.enable = mkEnableOption "Install and configure iTerm2";
}
