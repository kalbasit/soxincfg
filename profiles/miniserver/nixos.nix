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

  # Enable the installation of my neovim
  # TODO: Need a minimal neovim with just my keybindings
  # soxincfg.programs.neovim.enable = true;
  environment.systemPackages = with pkgs; [ neovim ];

  # Enable TailScale for zero-config VPN service.
  services.tailscale.enable = true;

  # Enable eternal-terminal
  # TODO: I have not used this. Do I need it?
  # networking.firewall.allowedTCPPorts = singleton config.services.eternal-terminal.port;
  # services.eternal-terminal.enable = true;

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
