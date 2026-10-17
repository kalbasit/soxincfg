{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.mosh;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable { home.packages = [ pkgs.mosh ]; };
}
