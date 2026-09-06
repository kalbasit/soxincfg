{ soxincfg }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  homePath = config.home.homeDirectory;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.personal
    soxincfg.nixosModules.profiles.neovim.full
    soxincfg.nixosModules.profiles.workstation.darwin.local
  ];

  home.stateVersion = "24.11";

  # Configure Nushell that can be used as a login shell.
  home.shell.enableNushellIntegration = true;
  programs.nushell = {
    enable = true;

    environmentVariables = config.home.sessionVariables;

    extraEnv = ''
      # Convert PATH from string to list
      $env.PATH = ($env.PATH | split row (char esep))

      # Add paths using std path add (prepends by default)
      use std/util "path add"

      # Standard UNIX paths (add first = lower priority)
      path add "/usr/local/bin"

      # Homebrew (Apple Silicon)
      path add "/opt/homebrew/sbin"
      path add "/opt/homebrew/bin"

      # Nix paths (add last = higher priority)
      path add "/nix/var/nix/profiles/default/bin"
      path add "/run/current-system/sw/bin"
      path add "/etc/profiles/per-user/wnasreddine/bin"
      path add ($env.HOME | path join ".nix-profile" "bin")
      path add ($env.HOME | path join ".local" "bin")
    '';

    shellAliases = {
      g = "git";
      k = "kubectl";
      serve_this = "${pkgs.python3}/bin/python -m http.server"; # Use port 8000 by default
    };
  };

  # agent-mesh, its plugin, and the broker on prod0 all come from the
  # claude-code module now, so nothing about the mesh is stated here. The
  # archive sweep stays at its default of off, unlike wnasreddine-code-01:
  # uploading session transcripts to a store that cannot delete is a decision
  # to make on its own.

  # This machine joins the steward fleet. It is a laptop that closes, so it is
  # `sleeps` rather than `intermittent`: the suspension is predictable, and the
  # scheduler treats "will be away and come back" differently from "may not be
  # reachable at all".
  soxincfg.programs.steward = {
    enable = true;
    url = "https://steward.prod.nasreddine.com";

    # Not in the nix store and not in this repository. See the module's
    # credentialsFile description for why the token has no option of its own.
    credentialsFile = config.sops.secrets.steward_env.path;

    reliability = "sleeps";
    labels = {
      os = "darwin";
      platform = "nix-darwin";
    };
  };

  sops = {
    # Also decrypts the broker credential the module declares for agent-mesh.
    age.keyFile = "${homePath}/.config/sops/age/soxincfg.txt";

    # This host's steward credential. Host-scoped rather than module-scoped so
    # it is encrypted to saturn alone: a credential issued per host is not
    # worth much if every host can decrypt every other's.
    #
    # The file holds `STEWARD_TOKEN=...` and is sourced at launch, so the token
    # never enters the job definition or the nix store.
    secrets.steward_env.sopsFile = ./secrets.sops.yaml;
  };
}
