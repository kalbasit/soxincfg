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

  # This machine joins the steward fleet. It is a VM that does not suspend, so
  # it is the one host long work can be placed on without expecting it to
  # vanish mid-flight.
  soxincfg.programs.steward = {
    enable = true;
    url = "https://steward.prod.nasreddine.com";

    # Not in the nix store and not in this repository. See the module's
    # credentialsFile description for why the token has no option of its own.
    credentialsFile = "/run/secrets/steward-env";

    reliability = "always_on";
    labels = {
      os = "linux";
      platform = "nixos";
    };
  };
}
