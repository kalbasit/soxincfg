{
  config,
  pkgs,
  ...
}:

let
  homePath = config.soxincfg.settings.users.user.home;
  owner = config.soxincfg.settings.users.user.name;
  sopsFile = ./home.sops.yaml;
in
{
  config = {
    environment.systemPackages = [ pkgs.python3 ];
    services = {
      tailscale.enable = true;
    };

    sops.secrets = {
      _ssh_id_ed25519 = {
        inherit owner sopsFile;
        path = "${homePath}/.ssh/id_ed25519";
      };
    };
  };
}
