{
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption optionals;
in
{
  imports = [ ./darwin-config.nix ];

  options.soxincfg.settings.nix.distributed-builds.enable =
    mkEnableOption "Configure Nix distributed-builds";
}
