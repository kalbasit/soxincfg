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
    soxincfg.programs = {
      # the entire reason this host exists
      claude-code.enable = true;

      # shell parity with the other machines
      fzf.enable = true;
      git.enable = true;
      ssh.enable = true;
      starship.enable = true;
      swm.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
  };
}
