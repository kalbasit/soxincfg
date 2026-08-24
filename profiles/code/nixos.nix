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

      # The broker password agents authenticate with. Decrypted to a file the
      # user can read and nothing else can, and *named* from agent-mesh's config
      # rather than copied into it -- config.toml is world-readable, so a password
      # written there would undo what this is for.
      _agent_mesh_mqtt_password = {
        inherit owner sopsFile;
        path = "${homePath}/.config/agent-mesh/mqtt-password";
        mode = "0400";
      };
    };
  };
}
