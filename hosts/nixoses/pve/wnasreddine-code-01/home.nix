{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.code
  ];

  home.stateVersion = "25.05";

  # agent-mesh: durable agent identity, shared memory across machines, and a
  # federated work queue. Enabled here first rather than in profiles/code, so
  # this host is the one that finds out what breaks.
  #
  # The archive sweep is deliberately left off: it uploads session transcripts
  # to a store with no delete, so it is turned on once, knowingly, and not as a
  # side effect of enabling the plugin.
  soxincfg.programs.claude-code = {
    marketplaces.kalbasit.repo = "kalbasit/marketplace";
    plugins = [ "agent-mesh@kalbasit" ];
    agent-mesh.enable = true;
  };
}
