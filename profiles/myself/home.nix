{ config, lib, ... }:

let
  inherit (lib)
    concatStringsSep
    ;

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
          IdentityFile = "~/.ssh/per-host/bitbucket.org_rsa";
        };
      };

      "gitlab.com" = {
        extraOptions = {
          IdentityFile = "~/.ssh/per-host/gitlab.com_rsa";
        };
      };

      "serial.nasreddine.com" = {
        extraOptions = {
          IdentityFile = "~/.ssh/per-host/serial.nasreddine.com_rsa";
        };
      };

      "serial" = {
        extraOptions = {
          IdentityFile = "~/.ssh/per-host/serial.nasreddine.com_rsa";
        };
      };

      "unifi-usg" = {
        hostname = "192.168.10.1";
        extraOptions = {
          IdentityFile = "~/.ssh/per-host/unifi.nasreddine.com_rsa";
          # Unifi is still using hmac-sha1, enabling it only for these hosts.
          MACs = "+hmac-sha1";
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
        user = "admin";
      };

      "unifi-switch" = {
        hostname = "192.168.10.44";
        extraOptions = {
          IdentityFile = "~/.ssh/per-host/unifi.nasreddine.com_rsa";
          # Unifi is still using hmac-sha1, enabling it only for these hosts.
          MACs = "+hmac-sha1";
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
        user = "admin";
      };

      "unifi-ap0" = {
        hostname = "192.168.10.218";
        extraOptions = {
          IdentityFile = "~/.ssh/per-host/unifi.nasreddine.com_rsa";
          # Unifi is still using hmac-sha1, enabling it only for these hosts.
          MACs = "+hmac-sha1";
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
        user = "admin";
      };
    };
  };
}
