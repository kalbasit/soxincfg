{ config, lib, ... }:

let
  inherit (lib) mkIf singleton;

  cfg = config.soxin.virtualisation.docker;
in
{
  config = mkIf cfg.enable { homebrew.casks = singleton "docker-desktop"; };
}
