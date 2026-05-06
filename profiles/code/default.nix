{
  lib,
  mode,
  soxincfg,
  ...
}:

let
  inherit (lib) optionals;
in
{
  imports = [
    soxincfg.nixosModules.profiles.myself
    soxincfg.nixosModules.profiles.neovim.full
  ]
  ++ optionals (mode == "NixOS") [ ./nixos.nix ]
  ++ optionals (mode == "home-manager") [ ./home.nix ];

  config = {
    soxin = {
      programs = {
        less.enable = true;
      };

      services = {
        openssh.enable = true;
      };

      virtualisation = {
        docker.enable = true;
      };
    };

    soxincfg = {
      programs = {
        claude-code.enable = true;
        codex.enable = true;
        fzf.enable = true;
        git.enable = true;
        pet.enable = true;
        ssh.enable = true;
        starship.enable = true;
        t3code.enable = true;
        tmux.enable = true;
        zsh.enable = true;
      };

      settings = {
        nix.distributed-builds.enable = true;
        networking.nextdns.enable = true;
      };
    };
  };
}
