{ lib, hostType, ... }:

let
  inherit (lib) optionals;
in
{
  imports =
    optionals (hostType == "nix-darwin") [ ./home-darwin.nix ]
    ++ optionals (hostType == "qubes-os") [ ./home-qubes.nix ];

  config = {
    home.file = {
      ".ssh/per-host/bitbucket.org_rsa.pub".text = ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFfgG34BchsSeKncvO/vysGK2VNweC5ZJQuiVZD9FRSL9PxNYQq68D8PY9DMI+HqF64g+TTDhd3hPhvie1w9If8iWjQC1hvtuQzU72KbSbTKRylgsLoBcSCwDwdvMU0gHHd1fMjhglDsMykE/Jz0mJXOF+z6i98fCB+6hjGENhESkmlTx0lJnyBQP4PjKe0hVrm3+lUe/QQ/xUDWebu3TzSssZj0dTKzlh4OTG9GRFuLaCLtXEhoFhXsgrHHhGHI3Q4hZoeZo8CP+mkBQYKBOXUBLUq16lQ4y0XwGrIZZ4+VvVOe3+X1PfNmq9f+FYilHvEKfFN0mdxBMrIU4FxC+xnKd6hMmNfeEEG3W5th2SDGcWSdUFGEZY3xCjeGk36Tzc6j/oDDbwPytU3sLX4+4x/Kb+xebIwvK6RFY5V2jXuEu9cjjEXPfJG9EFJFlUJDpApsnr1KUA8mlxUW4duhMgX/K/sGEL/O4B3MSPbLi9hl+rg/ABL5JlWC42Vtt6TqUua4LANIzPbYBFXZCVwKf7FtJuzeAtKqsCTVWJMcFHzsI7UKW6fuUlCyh+Vtvpl2ZVTboutuBVAqV38iv6tt/CYPeM8Kxlk6Z8O9sfJlMtAPGcDw/6IG9ihoSruARSn8YJ4EEEETe0b1GFjb76b3HyCKhCH0vth9fbc8d3Ud2qrQ== bitbucket.org
      '';

      ".ssh/per-host/cronus_ed25519.pub".text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDMWCJ+hjoFsZdUzOzlQ1xZKngq/OnoBflf3fsemK4s Cronus - ChromeOS 2024-10-23
      '';

      ".ssh/per-host/gitlab.com_rsa.pub".text = ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDd2xrIB5Tml5+r2jpsFxK6nSo0D7w32Naxj1eEUYQsLU+SucvkhprhctL3su7NeFvO9W9q4M0nSF2JdgDTFccvsIMChtjJ6CbpP3mw2wpFgSWSBLGt3wDMPac9OYZ2I225gDjczZb1K3t4pkrdqBbjjWnPdEX0HE3tSf6f3+v0eKYP2fbHk/7rvDafwF9wnG9A6hHZ6DAQuxnkUMxMfEfXSuZIS/s+5ZLO/jJULipcrQ/4bS31b0zwM7wESSXE7ErkorsH0LqDCZCIEUWoXXZNJlOtoGrSxCzJ7APKR/hHxMayUsucgPjxGLg+lCzMuMrkLbnXdsSlEWNULi8LHIzeUjQccFIpz8NGdTksW6BEFWhOG1G1txGT0bD+YS8LvabL0IBS6ocakTPEGGt1dGGGXVydD0TKIen7Fd/TpxyOE0uJTR6jHpv97aG7lI/1tv3NvC+PbcfGYA089mIR0gdip4M48BkiARI7goUXQ65FSxJ+mpiKiuK9Quu0bJW4sUZhQL93/GzS8iaZLL/9rbkApo0IvVwtqdI8Y3KulaEOOvsttbJJsQ7ppQ0r9PeSRYJjZc1AchbbitPw2iX1NM06ctiONxujm4KBvV0wQ2JGXmX4N4zznu1CIdu0wrNMfgF9Yo/F9Sb0eVcFw61xNfr9mtno2VUz2CjhZBRq0NpRtw== gitlab.com
      '';

      ".ssh/per-host/hermes-gl-mt3000.bigeye-bushi.ts.net_ed25519.pub".text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLQj0aTkBIM3rSvwDJCnW/Jv/VXNEzymYO6t/w18QVf hermes-gl-mt3000.bigeye-bushi.ts.net
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
        Include ~/.ssh/config_include_personal
      '';
    };
  };
}
