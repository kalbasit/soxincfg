{
  config,
  lib,
  ...
}:

let
  am = config.soxincfg.programs.claude-code.agent-mesh;
in
{
  # The same secret as ./nixos.nix, declared the other way round.
  #
  # sops is wired per platform here: NixOS hosts get sops-nix's system module and
  # decrypt with the host key, while nix-darwin hosts declare secrets inside
  # home-manager and decrypt with the user's age key. So this is a duplicate
  # declaration rather than a shared one -- but of the same key, in the same file,
  # for the same path, so an agent on either platform reads its broker password
  # from where it expects to.
  #
  # Guarded the straightforward way, unlike the NixOS half: here the module's own
  # config is the one that was set, so there is no boundary to read across.
  config = lib.mkIf (am.enable && am.broker.host != null) {
    sops.secrets._agent_mesh_mqtt_password = {
      sopsFile = ./secrets.sops.yaml;
      path = "${config.home.homeDirectory}/.config/agent-mesh/mqtt-password";
      mode = "0400";
    };
  };
}
