{ config, lib, pkgs, ... }:

with lib;

{
  # Enable the installation of my neovim
  # TODO: Need a minimal neovim with just my keybindings
  # soxincfg.programs.neovim.enable = true;
  environment.systemPackages = with pkgs; [ neovim ];

  # Enable TailScale for zero-config VPN service.
  services.tailscale.enable = true;

  # Enable SSH server
  soxin.services.openssh.enable = true;

  # Enable eternal-terminal
  networking.firewall.allowedTCPPorts = singleton config.services.eternal-terminal.port;
  services.eternal-terminal.enable = true;

  # Setup my keyboard layout
  soxin.settings.keyboard = {
    layouts = [
      { console = { keyMap = "colemak"; }; }
    ];
  };
}
