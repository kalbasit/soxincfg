{ soxincfg }:

{
  imports = [
    soxincfg.nixosModules.profiles.code
  ];

  home.stateVersion = "25.05";

  # agent-mesh itself comes from the claude-code module, which enables it
  # wherever Claude Code is enabled. What is host-specific is below.
  soxincfg.programs.claude-code.agent-mesh = {
    # Session transcripts upload to a store that cannot delete, so this is
    # switched on knowingly rather than inherited: redaction runs before any
    # byte leaves the machine, and the backlog was reviewed before this went on.
    archive.enable = true;

    # The broker on prod0. Agents authenticate as their own scoped account, so
    # they cannot touch the topics the house runs on.
    broker.host = "192.168.54.3";
  };
}
