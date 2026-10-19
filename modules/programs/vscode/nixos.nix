{
  lib,
  ...
}:

{
  imports = [ ];

  options = {
    soxincfg.programs.vscode.enable = lib.mkEnableOption "vscode";
  };
}
