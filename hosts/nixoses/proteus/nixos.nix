{
  config,
  soxincfg,
  ...
}:

let
  homePath = config.soxincfg.settings.users.user.home;
  owner = config.soxincfg.settings.users.user.name;
  sopsFile = ./secrets.sops.yaml;
in
{
  imports = [
    soxincfg.nixosModules.profiles.wsl-gaming
  ];

  networking.hostName = "proteus";

  sops = {
    age.keyFile = "${homePath}/.config/sops/age/keys.txt";

    secrets = {
      _ssh_id_ed25519 = {
        inherit owner sopsFile;
        mode = "0400";
        path = "${homePath}/.ssh/id_ed25519";
      };
    };
  };

  # load home-manager configuration
  home-manager.users."${config.soxincfg.settings.users.userName}" = import ./home.nix {
    inherit soxincfg;
  };

  system.stateVersion = "26.05";
}
