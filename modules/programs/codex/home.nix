{
  lib,
  ...
}:

{
  imports = [ ./home-config.nix ];

  options = {
    soxincfg.programs.codex.enable = lib.mkEnableOption "codex";
  };
}
