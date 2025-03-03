{ lib, mode, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = optionals (mode == "home-manager") [ ./home.nix ];

  options.soxincfg.programs.pet.enable = mkEnableOption "pet";
}
