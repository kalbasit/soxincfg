{
  lib,
  mode,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options = {
    soxincfg.programs.swm.enable = lib.mkEnableOption "swm";
  };
}
