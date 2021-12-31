{ config, home-manager, lib, mode, ... }:

let
  inherit (lib) mkMerge optionalAttrs;
in
{
  config = mkMerge [
    {
      soxin.programs.rbrowser.browsers = {
        "vivaldi@ulta" = home-manager.lib.hm.dag.entryAfter [ "vivaldi@personal" ] { };
        "firefox@ulta" = home-manager.lib.hm.dag.entryAfter [ "vivaldi@ulta" ] { };
        "chromium@ulta" = home-manager.lib.hm.dag.entryAfter [ "firefox@ulta" ] { };
      };
    }

    (optionalAttrs (mode == "NixOS") (
      let
        yl_home = config.users.users.yl.home;
        owner = config.users.users.yl.name;
        sopsFile = ./secrets.sops.yaml;
      in
      {
        sops.secrets._aws_configure_profile_ulta_sh = { inherit owner sopsFile; mode = "0500"; };
        sops.secrets._zsh_profiles_ulta_zsh = { inherit owner sopsFile; path = "${yl_home}/.zsh/profiles/ulta.zsh"; };
      }
    ))
  ];
}
