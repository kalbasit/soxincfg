{
  config,
  lib,
  ...
}:

let
  user = config.soxincfg.settings.users.user;

  # The module is configured on the home-manager side -- that is where
  # claude-code lives -- but a sops secret has to be declared on the NixOS side,
  # because soxin gives sops-nix's module to NixOS hosts and the two option trees
  # do not see each other. So the intent is read across the boundary rather than
  # duplicated in the host's system config, where it would drift.
  hm = config.home-manager.users.${user.name}.soxincfg.programs.claude-code or null;
  am = if hm == null then null else hm.agent-mesh;

  wanted = am != null && am.enable && am.broker.host != null;
in
{
  # Declared only when a broker is actually configured. sops-nix validates its
  # manifest at build time, so declaring this on a host that has no broker would
  # fail that host's build over a key it never needed.
  config = lib.mkIf wanted {
    sops.secrets._agent_mesh_mqtt_password = {
      owner = user.name;
      sopsFile = ./secrets.sops.yaml;
      path = "${user.home}/.config/agent-mesh/mqtt-password";
      mode = "0400";
    };
  };
}
