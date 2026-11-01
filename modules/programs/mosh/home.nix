{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./options.nix ];

  config = lib.mkIf config.soxincfg.programs.mosh.enable {
    home.packages = [ pkgs.mosh ];
  };
}
