{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ];

  options.soxincfg.programs.iterm2.enable = mkEnableOption "Install and configure iTerm2";
}
