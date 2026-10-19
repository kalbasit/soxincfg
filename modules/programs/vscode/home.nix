{
  lib,
  ...
}:

{
  imports = [ ./home-config.nix ];

  options = {
    soxincfg.programs.vscode.enable = lib.mkEnableOption "vscode";
  };
}
