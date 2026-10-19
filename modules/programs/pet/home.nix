{ lib, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ./home-config.nix ];

  options.soxincfg.programs.pet.enable = mkEnableOption "pet";
}
