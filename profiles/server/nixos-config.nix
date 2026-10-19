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

  services.fwupd.enable = true;

  # Feed the kernel some entropy
  services.haveged.enable = true;

  # mosh, and its UDP ports.
  programs.mosh.enable = true;
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];

  # Enable TailScale for zero-config VPN service.
  services.tailscale.enable = true;

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
