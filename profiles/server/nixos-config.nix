{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) singleton;
in
{
  environment.homeBinInPath = true;

  # mosh, and its UDP ports.
  programs.mosh.enable = true;
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];

  services = {
    fwupd.enable = true;

    # Feed the kernel some entropy
    haveged.enable = true;

    # Enable TailScale for zero-config VPN service.
    tailscale.enable = true;
  };

  # Setup my keyboard layout
  soxin.settings.keyboard = {
    layouts = [
      {
        console = {
          keyMap = "colemak";
        };
      }
    ];
  };
}
