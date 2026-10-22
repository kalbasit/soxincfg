{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  imports = [ ./darwin-config.nix ];

  options.soxincfg.programs.iterm2.enable = mkEnableOption "Install and configure iTerm2";
}
