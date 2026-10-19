{
  lib,
  ...
}:

{
  imports = [ ./home-config.nix ];

  options = {
    soxincfg.programs.zed.enable = lib.mkEnableOption "zed";
  };
}
