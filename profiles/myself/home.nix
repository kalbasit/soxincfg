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
      "bitbucket.org" = {
        extraOptions = {
          IdentityFile =
            "~/.ssh/per-host/bitbucket.org_rsa";
        };
      };

      "gitlab.com" = {
        extraOptions = {
          IdentityFile =
            "~/.ssh/per-host/gitlab.com_rsa";
        };
      };

      "serial.nasreddine.com" = {
        extraOptions = {
          IdentityFile =
            "~/.ssh/per-host/serial.nasreddine.com_rsa";
        };
      };

      "serial" = {
        extraOptions = {
          IdentityFile =
            "~/.ssh/per-host/serial.nasreddine.com_rsa";
        };
      };
    };
  };
}
