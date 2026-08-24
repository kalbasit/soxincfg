{
  config,
  soxincfg,
  ...
}:

let
  homePath = config.soxincfg.settings.users.user.home;
in
{
  imports = [
    soxincfg.nixosModules.profiles.wsl-gaming
  ];

  networking.hostName = "proteus";

  sops = {
    age.keyFile = "${homePath}/.config/sops/age/keys.txt";
  };

  # load home-manager configuration
  home-manager.users."${config.soxincfg.settings.users.userName}" = import ./home.nix {
    inherit soxincfg;
  };

  system.stateVersion = "26.05";
}
