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

  # Feed the kernel some entropy
  services.haveged.enable = true;

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
