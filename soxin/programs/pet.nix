{ config, pkgs, lib, mode, ... }:

with lib;

{
  options.soxin.programs.pet.enable = mkEnableOption "pet";

  config = mkIf config.soxin.programs.pet.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.zsh.initExtra = ''
        # setup pet
        function pet_select() {
          BUFFER=$(${pkgs.pet}/bin/pet search --query "$LBUFFER")
          CURSOR=$#BUFFER
          zle redisplay
        }
        function pet_prev() {
          PREV=$(fc -lrn | head -n 1)
          sh -c "${pkgs.pet}/bin/pet new $(printf %q "$PREV")"
        }
        if [[ -o interactive ]]; then
          zle -N pet_select
          stty -ixon
          bindkey '^p' pet_select
        fi
      '';

      home.packages = with pkgs; [ pet ];
    })
  ]);
}
