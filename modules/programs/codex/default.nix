{
  lib,
  mode,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options = {
    soxincfg.programs.codex.enable = lib.mkEnableOption "codex";
  };
}
