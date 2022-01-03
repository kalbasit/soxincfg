{ config, home-manager, lib, mode, ... }:

let
  inherit (lib) mkMerge optionalAttrs;
in
{
  config = mkMerge [
    {
      soxin.programs.rbrowser.browsers = {
        "vivaldi@arklight" = home-manager.lib.hm.dag.entryAfter [ "vivaldi@personal" ] { };
        "firefox@arklight" = home-manager.lib.hm.dag.entryAfter [ "vivaldi@arklight" ] { };
        "chromium@arklight" = home-manager.lib.hm.dag.entryAfter [ "firefox@arklight" ] { };
      };
    }

    (optionalAttrs (mode == "NixOS") (
      let
        yl_home = config.users.users.yl.home;
        owner = config.users.users.yl.name;
        sopsFile = ./secrets.sops.yaml;
      in
      {
        sops.secrets._zsh_profiles_arklight_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/arklight.zsh"; };
      }
    ))
  ];
}
