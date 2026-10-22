{
  config,
  pkgs,
  lib,
  soxinLib,
  ...
}:

with lib;

# TODO: submit this module upstream to home-manager
let
  cfg = config.soxin.programs.less;

in
{
  options.soxin.programs.less = soxinLib.mkSoxinModule {
    inherit config;
    name = "less";
    includeKeyboardLayout = true;
    extraOptions = {
      quitIfOneScreen = mkOption {
        type = types.bool;
        default = true;
        description = "Causes less to automatically exit if the entire file can be displayed on the first screen.";
      };

      colors = mkOption {
        type = types.bool;
        default = true;
        description = "Enable colored output by allowing only ANSI color escape sequences to be written raw.";
      };

      ignoreCase = mkOption {
        type = types.bool;
        default = true;
        description = "Search case-insensitive";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { }
  ]);
}
