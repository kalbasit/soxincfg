{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
{
  config.soxin.programmingLanguages.go = (
    mkMerge [
      {
        vscode = {
          extensions = [ pkgs.vscode-extensions.golang.Go ];
        };
      }

    ]
  );
}
