{ config, lib, mode, ... }:


let
  inherit (lib)
    mkIf
    mkMerge
    optionalAttrs
    ;

  cfg = config.soxincfg.programs.onlykey;

  home = config.users.users.yl.home;
  owner = config.users.users.yl.name;
  sopsFile = ./secrets.sops.yaml;
in
{
  config = optionalAttrs (mode == "NixOS") (mkIf cfg.enable (mkMerge [
    { hardware.onlykey.enable = true; }

    (mkIf cfg.ssh-support.enable {
      sops.secrets._ssh_id_ed25519_sk_rk = {
        inherit owner sopsFile;
        path = "${home}/.ssh/id_ed25519_sk_rk";
      };
    })
  ]));
}
