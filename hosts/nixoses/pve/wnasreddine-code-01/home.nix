{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.code
  ];

  home.stateVersion = "25.05";

  # agent-mesh and its broker come from the claude-code module. The archive
  # sweep does not: session transcripts upload to a store that cannot delete,
  # so it is switched on knowingly rather than inherited. Redaction runs before
  # any byte leaves the machine, and the backlog was reviewed before this went
  # on. This host is the one that runs it first.
  soxincfg.programs.claude-code.agent-mesh.archive.enable = true;
}
