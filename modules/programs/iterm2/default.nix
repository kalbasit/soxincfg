{ lib, mode, ... }:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports =
    optionals (mode == "home-manager") [ ./home-manager.nix ]
    ++ optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.programs.iterm2.enable = mkEnableOption "Install and configure iTerm2";
}
