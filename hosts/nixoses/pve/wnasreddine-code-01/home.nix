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
    # sops-nix on NixOS decrypts to /run/secrets/<name>. Written out rather
    # than read from config.sops, because this is the home-manager tree and the
    # secret is declared in the NixOS one.
    credentialsFile = "/run/secrets/steward_env";

    reliability = "always_on";
    labels = {
      os = "linux";
      platform = "nixos";
    };
  };
}
