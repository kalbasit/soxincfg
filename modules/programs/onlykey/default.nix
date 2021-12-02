{ config, lib, mode, pkgs, ... }:


let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    optionalAttrs
    singleton
    ;

  cfg = config.soxincfg.programs.onlykey;
in
{
  options.soxincfg.programs.onlykey = {
    enable = mkEnableOption "programs.onlykey";

    ssh-support = {
      enable = mkEnableOption "Whether to enable SSH support with OnlyKey.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxincfg.programs.ssh = {
        enableSSHAgent = mkDefault cfg.ssh-support.enable;
      };
    }

    (optionalAttrs (mode == "home-manager") {
      home.packages = [ pkgs.onlykey pkgs.onlykey-agent pkgs.onlykey-cli ];
    })

    (optionalAttrs (mode == "NixOS") {
      hardware.onlykey.enable = true;
    })

    (mkIf cfg.ssh-support.enable (optionalAttrs (mode == "home-manager") {
      soxincfg.programs.ssh = {
        identitiesOnly = mkDefault true;
        identityFiles = singleton "~/.ssh/id_ed25519_sk_rk";
      };
    }))

    (mkIf cfg.ssh-support.enable (optionalAttrs (mode == "NixOS") {
      sops.secrets._ssh_id_ed25519_sk_rk =
        let
          yl_home = config.users.users.yl.home;
          owner = config.users.users.yl.name;
          sopsFile = ./secrets.sops.yaml;
        in
        {
          inherit owner sopsFile;
          path = "${yl_home}/.ssh/id_ed25519_sk_rk";
        };
    })
    )
  ]);
}
