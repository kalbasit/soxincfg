{
  lib,
  mode,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options = {
    soxincfg.programs.claude-code.enable = lib.mkEnableOption "claude-code";
  };
}
