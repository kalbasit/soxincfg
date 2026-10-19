{
  lib,
  ...
}:

{
  imports = [ ];

  options = {
    soxincfg.programs.codex.enable = lib.mkEnableOption "codex";
  };
}
