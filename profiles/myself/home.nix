{ config, ... }:

let
  yl_home = config.users.users.yl.home;
in
{
  programs.ssh = {
    extraConfig = ''
      Include ~/.ssh/config_include_myself
    '';

    matchBlocks = {
      "gitlab.com" = {
        extraOptions = {
          IdentityFile =
            "~/.ssh/per-host/gitlab.com_rsa";
        };
      };
    };
  };
}
