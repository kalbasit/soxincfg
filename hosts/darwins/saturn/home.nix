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

  # agent-mesh: durable agent identity, shared memory across machines, and a
  # federated work queue. Enabled per-host rather than in a profile, so each
  # machine joins the mesh deliberately.
  #
  # Messaging falls back to the shared store whenever the broker is
  # unreachable, so the mesh works either way and the broker is a latency
  # choice rather than a dependency.
  soxincfg.programs.claude-code = {
    agent-mesh = {
      enable = true;

      # Left off here, unlike wnasreddine-code-01: archiving uploads session
      # transcripts to a store that cannot delete, so it is a decision to make
      # on its own rather than a side effect of joining the mesh.
      archive.enable = false;

      # The broker on prod0. The password comes from this module's own sops
      # secret, decrypted with the user's age key -- see sops.age.keyFile below.
      broker.host = "192.168.54.3";
    };
  };

  sops = {
    age.keyFile = "${homePath}/.config/sops/age/soxincfg.txt";
  };
}
