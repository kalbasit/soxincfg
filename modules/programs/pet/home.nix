{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  cfg = config.soxincfg.programs.pet;
in
{
  config = mkIf cfg.enable {
    programs.pet = {
      enable = true;

      snippets = [
        #
        # Helpers
        #

        {
          description = "ssh-exit-git-github.com";
          command = "ssh -O exit git@github.com";
        }
        {
          description = "swm-tmux-kill-server";
          command = "swm tmux kill-server --vim-exit";
        }

        #
        # Kubernetes
        #

        {
          description = "kubectl get secret in plain text";
          command = "${pkgs.kubectl}/bin/kubectl get secret -o json <secret name> | jq '.data|map_values(@base64d)' -";
        }

        #
        # Nix and NixOS
        #

        {
          description = "nix-collect-garbage";
          command = "sudo nix-collect-garbage --delete-older-than <days>d";
          tag = [ "nix" ];
        }

        {
          description = "nix-diff /run/current-system result";
          command = "nix run nixpkgs#nix-diff \"$(nix-store -q --deriver /run/current-system)\" \"$(nix-store -q --deriver result)\"";
          tag = [
            "nix"
            "nix-diff"
          ];
        }

        {
          description = "nix-search-nix-store";
          command = "sudo nix run nixpkgs.sqlite -c sqlite3 -noheader /nix/var/nix/db/db.sqlite \"select path from ValidPaths where path like '%<search_term>%';\"";
          tag = [
            "nix"
            "nix-store"
          ];
        }

        #
        # SSH
        #

        {
          description = "ssh-to-darwin";
          command = "TERM=xterm-256color ssh -A <hostname>";
          tag = [
            "ssh"
            "mac"
            "darwin"
          ];
        }
      ];
    };
  };
}
