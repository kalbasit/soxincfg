{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
{
  config.soxin.tools.git = mkMerge [
    {
      vscode = {
        extensions = [ pkgs.vscode-extensions.eamodio.gitlens ];
      };
    }

  ];
}
