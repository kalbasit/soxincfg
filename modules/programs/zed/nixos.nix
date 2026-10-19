{
  lib,
  ...
}:

{
  imports = [ ];

  options = {
    soxincfg.programs.zed.enable = lib.mkEnableOption "zed";
  };
}
