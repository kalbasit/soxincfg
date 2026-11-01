{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.settings.macos-defaults;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.activation.screenshots-directory = lib.hm.dag.entryAnywhere ''
      run mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots
    '';
  };
}
