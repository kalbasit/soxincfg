{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  imports = [ ];

  options.soxincfg.programs.iterm2.enable = mkEnableOption "Install and configure iTerm2";
}
