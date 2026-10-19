{
  config,
  pkgs,
  lib,
  soxinLib,
  ...
}:

with lib;
let
  cfg = config.soxin.programs.vscode;
in
{
  options = {
    soxin.programs.vscode = soxinLib.mkSoxinModule {
      inherit config;
      name = "vscode";
      includeProgrammingLanguages = true;
      includeTools = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.vscode = mkMerge [
        { inherit (cfg) enable; }

        { extensions = flatten (map (v: v.extensions) cfg.programmingLanguages); }

      ];
    }
  ]);
}
