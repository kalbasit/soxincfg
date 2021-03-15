{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.dbeaver;

  yl_home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
in
{
  options.soxincfg.programs.dbeaver = {
    enable = mkEnableOption "programs.dbeaver";
  };
  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      home.packages = with pkgs; [
        dbeaver
      ];
    })

    (optionalAttrs (mode == "NixOS") {
      sops.secrets.credentials-config-json = {
        inherit owner;
        format = "binary";
        sopsFile = ./credentials-config.json.sops;
        path = "${yl_home}/.local/share/DBeaverData/workspace6/General/.dbeaver/credentials-config.json";
      };

      sops.secrets.data-sources-json = {
        inherit owner;
        format = "binary";
        sopsFile = ./data-sources.json.sops;
        path = "${yl_home}/.local/share/DBeaverData/workspace6/General/.dbeaver/data-sources.json";
      };
    })
  ]);
}
