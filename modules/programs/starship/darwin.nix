{ config, lib, ... }:

let
  cfg = config.soxincfg.programs.starship;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable { soxin.programs.starship.enable = true; };
}
