{
  config,
  lib,
  hostType,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.t3code;
in
{
  imports = lib.optionals (hostType == "NixOS") [ ./home-nixos.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.t3code
    ];
  };
}
