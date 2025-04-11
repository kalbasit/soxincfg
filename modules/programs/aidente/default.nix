{ lib, mode, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.programs.aidente.enable = mkEnableOption "Install and configure AIDente";
}
