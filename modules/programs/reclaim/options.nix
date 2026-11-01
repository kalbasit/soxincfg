{ lib, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.soxincfg.programs.reclaim = {
    enable = mkEnableOption "reclaim, which frees disk space held by stale stories and caches";

    storyManager = {
      package = mkOption {
        type = types.package;
        description = "Package providing the story manager CLI that reclaim drives.";
      };

      name = mkOption {
        type = types.str;
        default = "swm";
        description = "Name of the story manager's executable and of its data and runtime directories.";
      };
    };
  };
}
