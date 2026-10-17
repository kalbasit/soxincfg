{ config, lib, ... }:

let
  cfg = config.soxincfg.programs.fzf;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;

      # TODO: Why was git piped to ag?
      # programs.fzf.defaultCommand = ''(${config.programs.ssh.package}/bin/git ls-tree -r --name-only HEAD || ${pkgs.silver-searcher}/bin/ag --hidden --ignore .git -g "")'';
      defaultCommand = "${config.programs.ssh.package}/bin/git ls-tree -r --name-only HEAD";
    };
  };
}
