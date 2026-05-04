{
  lib,
  mode,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options = {
    soxincfg.programs.t3code.enable = lib.mkEnableOption "t3code";
  };
}
