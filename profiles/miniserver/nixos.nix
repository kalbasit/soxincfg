{
  pkgs,
  ...
}:

{
  environment.homeBinInPath = true;

  # Feed the kernel some entropy
  services.haveged.enable = true;

  # Install packages
  environment.systemPackages = [
    pkgs.binutils # for strings
    pkgs.dnsutils # for dig
    pkgs.screen
    pkgs.duf # du replacement on steroids
    pkgs.ncdu
    pkgs.file
    pkgs.gnupg
    pkgs.jq
    pkgs.killall
    pkgs.nix-zsh-completions
    pkgs.unzip
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
