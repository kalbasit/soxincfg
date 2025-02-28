{
  mode,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.soxin.services.networkmanager;
in
{
  options = {
    soxin.services.networkmanager = {
      enable = mkEnableOption ''
        Whether to enable NetworkManager.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      networking.networkmanager.enable = true;

      programs.nm-applet.enable = true;

      soxincfg.settings.users.groups = [ "networkmanager" ];
    })
  ]);
}
