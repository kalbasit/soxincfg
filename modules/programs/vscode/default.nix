{
  lib,
  mode,
  ...
}:

{
  imports = lib.optional (mode == "home-manager") ./home.nix;

  options = {
    soxincfg.programs.vscode.enable = lib.mkEnableOption "vscode";
  };
}
