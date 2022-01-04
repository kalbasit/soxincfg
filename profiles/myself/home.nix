{ config, lib, ... }:

let
  inherit (lib)
    concatStringsSep
    ;

  yl_home = config.users.users.yl.home;
in
{
  home.file = {
    ".ssh/per-host/bitbucket.org_rsa.pub".text = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFfgG34BchsSeKncvO/vysGK2VNweC5ZJQuiVZD9FRSL9PxNYQq68D8PY9DMI+HqF64g+TTDhd3hPhvie1w9If8iWjQC1hvtuQzU72KbSbTKRylgsLoBcSCwDwdvMU0gHHd1fMjhglDsMykE/Jz0mJXOF+z6i98fCB+6hjGENhESkmlTx0lJnyBQP4PjKe0hVrm3+lUe/QQ/xUDWebu3TzSssZj0dTKzlh4OTG9GRFuLaCLtXEhoFhXsgrHHhGHI3Q4hZoeZo8CP+mkBQYKBOXUBLUq16lQ4y0XwGrIZZ4+VvVOe3+X1PfNmq9f+FYilHvEKfFN0mdxBMrIU4FxC+xnKd6hMmNfeEEG3W5th2SDGcWSdUFGEZY3xCjeGk36Tzc6j/oDDbwPytU3sLX4+4x/Kb+xebIwvK6RFY5V2jXuEu9cjjEXPfJG9EFJFlUJDpApsnr1KUA8mlxUW4duhMgX/K/sGEL/O4B3MSPbLi9hl+rg/ABL5JlWC42Vtt6TqUua4LANIzPbYBFXZCVwKf7FtJuzeAtKqsCTVWJMcFHzsI7UKW6fuUlCyh+Vtvpl2ZVTboutuBVAqV38iv6tt/CYPeM8Kxlk6Z8O9sfJlMtAPGcDw/6IG9ihoSruARSn8YJ4EEEETe0b1GFjb76b3HyCKhCH0vth9fbc8d3Ud2qrQ== bitbucket.org
    '';

    ".ssh/per-host/serial.nasreddine.com_rsa.pub".text = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCp/KlF/8dqGXPvwe86+nHkBaNQ9Y6MqWxGethvZUXEaaigKRXaz1h45XbaUy0yvQetzPnVM/6bL2j2zdxyOSVvfpxJG0UgsVu5Y+HPw5KDVLB/tpgi6JdLsfUJBFJt48dL3vKFUB/PXzmFx7YKFxHO3S9GIYUHvQ70G64zMWcx3DIZh9/ARWTSb8HjtwB7qhKu0v2p+q7JDvkx5b7yirVGkeTXW7WI0xNbC8L/mp3eWKs+DohHPQSgwW0nt6ZgpXdVoei/031Ekf76NmQ75jl1EHkyyXMN9k1hr/23ZbDvAPkptdjLus3XV0qJZ/TeLQcCmXx5c4llaXZZypDt9WDxgihvTVcwX9FVtT/qzlOAMrVNAQUE5zSTfqxrPf2gkQts88HbSIyLFou+bfrqhbdh9A/ID1594y3456ASfK7Cjekxz4CRtxiQ/4wWys4jOgRawBWNXLtDMIqgEK+cEtHlSHps7FuUa2/VlnuU2zG4H7RmPadNn5wnoiPryAzEdOACiP13YXXvSKjApu+ncNDLQFA960oWpOuZR3gqJlJPLAHqzfBEjXwKvlQUsqW61HeEdM+gV0P/yJ91TIiBtttOmbSpS3wJn+abykSICTLOcSH4goUWup5CnpP8YHntqgT0FZON7Z0QILySMf5h1uLi7T2xiibp7DXGu/Hy/om6aQ== serial.nasreddine.com
    '';

    ".ssh/per-host/unifi.nasreddine.com_rsa.pub".text = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDyp3rYy4usJEHjPz6qCBCka9kalkpoLg8UUMJg5GDq4xWn0cUCBjGseO08Ua/eT2fYOuBRjzza6EhRCoGfbtsycMeKcXIVhGsbezveteXzYZoR3m9MGGzQEqBi56F4MtKJ3dleGroww85uEEg8LozPPwYZk+rXNpAFhIbI+DwfPy0jOWkOvRCPRKxrGKnY2e+x8LyJzIQe5VpRxk5yqoWVemTwz9ybBsAlQ9DudnMeh82kHnU5wgbMqEw9yF9OSFXVLGMI8A0afrmLyDYAKQ/GiOX6UQqBpsPkcnLs0tyeLnLvH73dUbdkln0yAGPguPAxMoXalfVR0Vy4Usr0GVkkbeJbouLtkARIbbQwj1JvTXVIHuASWxJz73/b5hcLWTxBb/LTWQHykoGQnNEabA5dQ0b6JXOqWN7Zz/+314DIhRo0NKJKjpwZTLe3ZN16AnaJD5Ls/RP9+ZtLq5m7ztGbttSOMTsYUF4JM3oXJRYOj0jmnN02LlrHLv9BGO5aX1NGvJDgke9HAVDf2+I5gIOcq8d812qPmQl0MoeFeuHjkpZ0d/UIr22gAOANmWfittW6uPtN9pOfkSKzJAeo7eg2UrhjNppEqbdvQ5JbhxPZc6fvBRF4lSNKPwDUSyWkRGWGn6KjoVgha13ail/htWlP+ivrxkmcOcJVoF8Rh5nDRQ== unifi.nasreddine.com
    '';
  };

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
