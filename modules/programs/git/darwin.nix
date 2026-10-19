{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.soxincfg.programs.git;

  package = pkgs.git.override { openssh = config.programs.ssh.package; };
in
{
  options.soxincfg.programs.git = {
    enable = mkEnableOption "programs.git";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.programs.git = {
        inherit package;

        enable = true;
        lfs.enable = true;
        userName = "Wael Nasreddine";
        userEmail = "wael.nasreddine@gmail.com";
      };
    }

    ({ })
  ]);
}
