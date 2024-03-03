{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    ;

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
        # Nix and NixOS
        #

        {
          description = "nixos-system-list-generations";
          command = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
          tag = [ "nixos" ];
        }

        {
          description = "nixos-system-delete-old-generations";
          command = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old";
          tag = [ "nixos" ];
        }

        {
          description = "nix-collect-garbage";
          command = "sudo nix-collect-garbage --delete-older-than <days>d && nix-store --gc && sudo nixos-rebuild switch";
          tag = [ "nix" ];
        }

        {
          description = "nix-diff /run/current-system result";
          command = "nix run nixpkgs.nix-diff -c nix-diff \"$(nix-store -q --deriver /run/current-system)\" \"$(nix-store -q --deriver result)\"";
          tag = [ "nix" "nix-diff" ];
        }

        {
          description = "nix-review pr";
          command = "nix-review pr <prnumber>";
          tag = [ "nix" "nix-review" ];
        }

        {
          description = "nix-search-nix-store";
          command = "sudo nix run nixpkgs.sqlite -c sqlite3 -noheader /nix/var/nix/db/db.sqlite \"select path from ValidPaths where path like '%<search_term>%';\"";
          tag = [ "nix" "nix-store" ];
        }

        #
        # SSH
        #

        {
          description = "ssh-to-darwin";
          command = "TERM=xterm-256color ssh -A <hostname>";
          tag = [ "ssh" "mac" "darwin" ];
        }
      ];
    };
  };
}
