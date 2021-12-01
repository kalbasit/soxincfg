{ config, lib, mode, pkgs, ... }:

with lib;
let
  cfg = config.soxincfg.programs.onlykey;
in
{
  options.soxincfg.programs.onlykey = {
    enable = mkEnableOption "programs.onlykey";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxincfg.programs.ssh = {
        enableSSHAgent = mkDefault true;
      };
    }

    (optionalAttrs (mode == "home-manager") {
      home.packages = with pkgs; [ onlykey onlykey-agent onlykey-cli ];
    })

    (optionalAttrs (mode == "NixOS") (
      let
        yl_home = config.users.users.yl.home;
        owner = config.users.users.yl.name;
        sopsFile = ./secrets.sops.yaml;
        id_ed25519_sk_rk_path = "${yl_home}/.ssh/id_ed25519_sk_rk";
      in
      {
        hardware.onlykey.enable = true;
        sops.secrets._ssh_id_ed25519_sk_rk = { inherit owner sopsFile; path = id_ed25519_sk_rk_path; };

        soxincfg.programs.ssh = {
          identitiesOnly = mkDefault true;
          identityFiles = singleton id_ed25519_sk_rk_path;
        };
      }
    ))
  ]);
}
