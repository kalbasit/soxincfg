{
  config,
  lib,
  mode,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.soxincfg.programs.secretive;
in
{
  imports = optionals (mode == "nix-darwin") [ ./darwin.nix ];

  options.soxincfg.programs.secretive = {
    enable = mkEnableOption "the secretive SSH agent";
  };
}
